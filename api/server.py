from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from gpt4all import GPT4All
import json
import logging
import time
import os
import networkx as nx
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from datetime import datetime
from fastapi.responses import StreamingResponse
import asyncio

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

model = GPT4All(
    "qwen2.5-coder-7b-instruct-q4_0.gguf",
    model_path=os.path.join(os.path.expanduser("~"), ".cache", "gpt4all"),
    device="cuda"
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(BASE_DIR, "pruebas/logs"), exist_ok=True)
os.makedirs(os.path.join(BASE_DIR, "pruebas/json"), exist_ok=True)

logging.basicConfig(
    filename=os.path.join(BASE_DIR, "pruebas/logs/procesar.log"),
    level=logging.INFO,
    format="%(asctime)s - %(message)s"
)

class TextoEntrada(BaseModel):
    historia: str

def normalizar_relacion(rel: dict) -> dict | None:
    resultado = {}
    for k, v in rel.items():
        k_lower = k.lower().strip()
        if k_lower.endswith("1"):
            resultado["personaje1"] = v
        elif k_lower.endswith("2"):
            resultado["personaje2"] = v
        elif any(x in k_lower for x in ["relacion", "relation", "tipo"]):
            resultado["tipoRelacion"] = v
    if all(k in resultado for k in ["personaje1", "personaje2", "tipoRelacion"]):
        return resultado
    return None
    
def expandir_relacion(rel: dict) -> list[dict]:
    separadores = [" Y ", " y ", " E ", " e ", " and ", " AND ", ", "]
    
    p1 = rel["personaje1"]
    p2 = rel["personaje2"]
    tipo = rel["tipoRelacion"]
    
    # Detectar si personaje1 es un grupo
    nombres1 = [p1]
    for sep in separadores:
        if sep in p1:
            nombres1 = [n.strip() for n in p1.split(sep)]
            break
    
    # Detectar si personaje2 es un grupo
    nombres2 = [p2]
    for sep in separadores:
        if sep in p2:
            nombres2 = [n.strip() for n in p2.split(sep)]
            break
    
    # Generar un par por cada combinación
    resultado = []
    for n1 in nombres1:
        for n2 in nombres2:
            if n1 != n2:  # Evitar autorelaciones
                resultado.append({
                    "personaje1": n1,
                    "personaje2": n2,
                    "tipoRelacion": tipo
                })
    return resultado

def convertir_formato_app(json_final: dict) -> dict:
    relaciones = json_final["relaciones"]
    nodos_huerfanos = json_final.get("nodos_huerfanos", [])
    
    # Recuperar lista de nodos
    nodos_set = set()
    for r in relaciones:
        nodos_set.add(r["personaje1"])
        nodos_set.add(r["personaje2"])
        
    for n in nodos_huerfanos:
        nodos_set.add(n)
    
    # Construir lista de nodos
    nodos = []
    for i, nombre in enumerate(nodos_set):
        nodos.append({
        "id": f"{i+1}",
        "title": nombre,
        })
    
    # Construir lista de edges/relaciones
    edges = []
    for r in relaciones:
        edges.append({
        "node1": r["personaje1"],
        "node2": r["personaje2"],
        "type": r["tipoRelacion"]
        })
    
    return{"nodes": nodos, "edges": edges}

def generar_grafo(json_final: dict, nombre_prueba: str, timestamp: str):
    relaciones = json_final["relaciones"]
    huerfanos = json_final["nodos_huerfanos"]

    nombres = set()
    for r in relaciones:
        nombres.add(r["personaje1"])
        nombres.add(r["personaje2"])

    nombres.update(huerfanos)

    G = nx.DiGraph()
    G.add_nodes_from(list(nombres))
    for r in relaciones:
        G.add_edge(r["personaje1"], r["personaje2"], label=r["tipoRelacion"])

    plt.figure(figsize=(12, 8))
    pos = nx.spring_layout(G, k=2, iterations=10)
    nx.draw(G, pos, with_labels=True, node_color='skyblue', node_size=2000, font_size=9, font_weight='bold')
    edge_labels = nx.get_edge_attributes(G, 'label')
    nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, font_color='red', font_size=7)
    plt.title(f"Grafo de relaciones — {nombre_prueba}")
    plt.axis('off')

    os.makedirs(os.path.join(BASE_DIR, "pruebas/grafos"), exist_ok=True)
    grafo_filename = os.path.join(BASE_DIR, f"pruebas/grafos/{nombre_prueba}_{timestamp}.png")
    plt.savefig(grafo_filename, bbox_inches='tight', dpi=150)
    plt.close()

    logging.info(f"[{nombre_prueba}] Grafo guardado: {grafo_filename}")
    print(f"[{nombre_prueba}] Grafo guardado en {grafo_filename}")

def extraer_nodos_adicionales(text: str, nodos_existentes: set, nombre_prueba: str = "nodos") -> list:
    
    print(f"[{nombre_prueba} Procesando nombres...]")
    
    prompt = (
    """Del siguiente texto extrae únicamente los nombres propios de personajes en formato JSON """
    """con plantilla ({ "personajes": ["nombre1", "nombre2"] }). """
    """Solo nombres propios de personas, sin descripciones ni cargos. Texto: """
    + text + ". Json:"
    )
    
    output = model.generate(
        prompt=prompt,
        n_predict=512,
        temp=0,
        top_k=40,
        top_p=0.9,
        repeat_penalty=1.2
    )
    
    print(f"[{nombre_prueba} Nombres procesados]")
    
    try:
        inicio_json = output.find('{')
        profundidad = 0
        fin_json = -1
        for idx, char in enumerate(output[inicio_json:], start=inicio_json):
            if char == '{':
                profundidad += 1
            elif char == '}':
                profundidad -= 1
                if profundidad == 0:
                    fin_json = idx + 1
                    break
        
        data = json.loads(output[inicio_json:fin_json])
        nuevos = [p for p in data["personajes"] if p not in nodos_existentes]
        return nuevos
    except:
        return []
    

def procesar_texto(text: str, nombre_prueba: str):
    text = text.strip()
    if not text.endswith('.'):
        text += '.'
    textSplit = [s.strip() for s in text.split('.') if s.strip() != '']
    textPrompt = []
    chunk_size = 4

    for i in range(0, len(textSplit), chunk_size):
        chunk = textSplit[i:i + chunk_size]
        ts = '. '.join(chunk) + '.'
        textPrompt.append(ts)

    todas_las_relaciones = []
    errores = 0
    inicio = time.time()

    for i, t in enumerate(textPrompt):
        # Progreso del proceso
        progreso = round(((i+1)/len(textPrompt))*100)
        
        prompt = (
            """Extrae las relaciones entre pares de personajes del siguiente texto en formato JSON """
            """con plantilla ({ "relaciones": [{"personaje1": ,"personaje2": ,"tipoRelacion": }] }). """
            """Reglas: """
            """1) Si varios personajes realizan la misma acción, crea una relación separada por cada par. """
            """2) Incluye relaciones implícitas de parentesco, jerarquía o pertenencia (ejemplo: padre de, trabaja para). """
            """3) El tipoRelacion debe ser corto, máximo 4 palabras. """
            """Texto: """
            + t + ". Json:"
        )
        
        output = model.generate(
            prompt=prompt,
            n_predict=2048,
            temp=0.2,
            top_k=40,
            top_p=0.9,
            repeat_penalty=1.2
        )
        
        print(f"[{nombre_prueba} Procesando chunk {i+1}/{len(textPrompt)} - {progreso}%]")
        
        try:
            # Extraer solo el primer JSON válido del output
            inicio_json = output.find('{')
        
            # Buscar el cierre correcto del array y objeto raíz
            profundidad = 0
            fin_json = -1
            for idx, char in enumerate(output[inicio_json:], start=inicio_json):
                if char == '{':
                    profundidad += 1
                elif char == '}':
                    profundidad -= 1
                    if profundidad == 0:
                        fin_json = idx + 1
                        break
        
            if inicio_json == -1 or fin_json == -1:
                raise json.JSONDecodeError("No se encontró JSON", output, 0)
    
            json_str = output[inicio_json:fin_json]
            data = json.loads(json_str)
            for rel in data["relaciones"]:
                normalizada = normalizar_relacion(rel)
                if normalizada:
                    expandidas = expandir_relacion(normalizada)
                    todas_las_relaciones.extend(expandidas)

        except json.JSONDecodeError as e:
            errores += 1
            logging.error(f"[{nombre_prueba}] Chunk {i+1} - JSONDecodeError: {e} | Output: {output}")
            print(f"[ERROR JSONDecodeError] Chunk {i+1}: {e}")
            print(f"[OUTPUT problemático] {output}")

    tiempo_total = round(time.time() - inicio, 2)
    nodos_existentes = set()
    for r in todas_las_relaciones:
        nodos_existentes.add(r["personaje1"])
        nodos_existentes.add(r["personaje2"])
        
    nodos_huerfanos = extraer_nodos_adicionales(text,nodos_existentes)

    # Guardar JSON de salida
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    json_filename = os.path.join(BASE_DIR, f"pruebas/json/{nombre_prueba}_{timestamp}.json")
    json_final = {"relaciones": todas_las_relaciones, "nodos_huerfanos": nodos_huerfanos}
    with open(json_filename, "w", encoding="utf-8") as f:
        json.dump(json_final, f, indent=2, ensure_ascii=False)
        
    # JSON formato app
    app_filename = os.path.join(BASE_DIR, f"pruebas/json/{nombre_prueba}_{timestamp}_app.json")
    json_app = convertir_formato_app(json_final)
    with open(app_filename, "w", encoding="utf-8") as f:
        json.dump(json_app, f, indent=2, ensure_ascii=False)

    # Log resumen
    logging.info(
        f"[{nombre_prueba}] Chunks: {len(textPrompt)} | "
        f"Relaciones: {len(todas_las_relaciones)} | "
        f"Nodos: {len(nodos_existentes) + len(nodos_huerfanos)} | "
        f"Errores: {errores} | "
        f"Tiempo: {tiempo_total}s | "
        f"JSON: {json_filename}"
    )
    
    print(f"[{nombre_prueba}] Completado en {tiempo_total}s — {len(nodos_existentes)} nodos - {len(nodos_huerfanos)} huerfanos - {len(todas_las_relaciones)} relaciones — {errores} errores")
    generar_grafo(json_final, nombre_prueba, timestamp)

    return json_final

@app.post("/procesar")
async def procesar(entrada: TextoEntrada):
    return procesar_texto(entrada.historia, nombre_prueba="manual")
    
@app.post("/procesar_archivo")
async def procesar_archivo(archivo: UploadFile = File(...)):
    nombre_prueba = os.path.splitext(archivo.filename)[0]  # nombre sin extensión
    contenido = await archivo.read()
    text = contenido.decode("utf-8")
    return procesar_texto(text, nombre_prueba=nombre_prueba)
    
@app.post("/procesar_stream")
async def procesar_stream(entrada: TextoEntrada):
    async def event_generator():
        
        nombre_prueba = "stream"
        
        # Preparación del texto input
        text = entrada.historia.strip()
        if not text.endswith('.'):
            text += '.'
        textSplit = [s.strip() for s in text.split('.') if s.strip() != '']
        textPrompt = []
        chunk_size = 4
        for i in range(0, len(textSplit), chunk_size):
            chunk = textSplit[i:i + chunk_size]
            ts = '. '.join(chunk) + '.'
            textPrompt.append(ts)

        todas_las_relaciones = []
        errores = 0
        total = len(textPrompt)
        inicio = time.time()
        
        # JSON de relaciones
        for i, t in enumerate(textPrompt):
            
            # Progreso del proceso
            progreso = round(((i + 1) / total) * 100)
            yield f"data: {{\"tipo\": \"progreso\", \"valor\": {progreso}, \"chunk\": {i+1}, \"total\": {total}}}\n\n"
            await asyncio.sleep(0)
            
            print(f"[{nombre_prueba} Procesando chunk {i+1}/{len(textPrompt)} - {progreso}%]")

            prompt = (
                """Extrae las relaciones entre pares de personajes del siguiente texto en formato JSON """
                """con plantilla ({ "relaciones": [{"personaje1": ,"personaje2": ,"tipoRelacion": }] }). """
                """Reglas: """
                """1) Si varios personajes realizan la misma acción, crea una relación separada por cada par. """
                """2) Incluye relaciones implícitas de parentesco, jerarquía o pertenencia (ejemplo: padre de, trabaja para). """
                """3) El tipoRelacion debe ser corto, máximo 4 palabras. """
                """Texto: """
                + t + ". Json:"
            )

            output = model.generate(
                prompt=prompt,
                n_predict=2048,
                temp=0.2,
                top_k=40,
                top_p=0.9,
                repeat_penalty=1.2
            )

            try:
                
                # Extraer solo el primer JSON válido del output
                inicio_json = output.find('{')
                
                # Buscar el cierre correcto del array y objeto raíz
                profundidad = 0
                fin_json = -1
                for idx, char in enumerate(output[inicio_json:], start=inicio_json):
                    if char == '{':
                        profundidad += 1
                    elif char == '}':
                        profundidad -= 1
                        if profundidad == 0:
                            fin_json = idx + 1
                            break
                
                if inicio_json == -1 or fin_json == -1:
                    raise json.JSONDecodeError("No se encontró JSON", output, 0)
                
                data = json.loads(output[inicio_json:fin_json])
                for rel in data["relaciones"]:
                    normalizada = normalizar_relacion(rel)
                    if normalizada:
                        expandidas = expandir_relacion(normalizada)
                        todas_las_relaciones.extend(expandidas)
            
            except json.JSONDecodeError as e:
                errores += 1
                logging.error(f"[{nombre_prueba}] Chunk {i+1} - JSONDecodeError: {e} | Output: {output}")
                print(f"[ERROR JSONDecodeError] Chunk {i+1}: {e}")
                print(f"[OUTPUT problemático] {output}")

        # Nodos huérfanos
        yield f"data: {{\"tipo\": \"fase\", \"mensaje\": \"Buscando personajes adicionales...\"}}\n\n"
        await asyncio.sleep(0)
        
        tiempo_total = round(time.time() - inicio, 2)
        nodos_existentes = set()
        for r in todas_las_relaciones:
            nodos_existentes.add(r["personaje1"])
            nodos_existentes.add(r["personaje2"])
        nodos_huerfanos = extraer_nodos_adicionales(entrada.historia, nodos_existentes)

        # Guardar JSONs
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        json_final = {"relaciones": todas_las_relaciones, "nodos_huerfanos": nodos_huerfanos}
        json_filename = os.path.join(BASE_DIR, f"pruebas/json/manual_{timestamp}.json")
        with open(json_filename, "w", encoding="utf-8") as f:
            json.dump(json_final, f, indent=2, ensure_ascii=False)

        # JSON formato app
        json_app = convertir_formato_app(json_final)
        app_filename = os.path.join(BASE_DIR, f"pruebas/json/manual_{timestamp}_app.json")
        with open(app_filename, "w", encoding="utf-8") as f:
            json.dump(json_app, f, indent=2, ensure_ascii=False)


        # Log resumen
        logging.info(
            f"[{nombre_prueba}] Chunks: {len(textPrompt)} | "
            f"Relaciones: {len(todas_las_relaciones)} | "
            f"Nodos: {len(nodos_existentes) + len(nodos_huerfanos)} | "
            f"Errores: {errores} | "
            f"Tiempo: {tiempo_total}s | "
            f"JSON: {json_filename}"
        )
        
        print(f"[{nombre_prueba}] Completado en {tiempo_total}s — {len(nodos_existentes)} nodos - {len(nodos_huerfanos)} huerfanos - {len(todas_las_relaciones)} relaciones — {errores} errores")
        generar_grafo(json_final, "stream", timestamp)
        
        # Mensaje final con el resultado
        resultado_str = json.dumps(json_app, ensure_ascii=False)
        yield f"data: {{\"tipo\": \"resultado\", \"datos\": {resultado_str}}}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")