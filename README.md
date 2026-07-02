
# NIA — Nodos con Inteligencia Artificial

Aplicación móvil inteligente para la creación, gestión y visualización de grafos relacionales de personajes, con generación automática de nodos y relaciones a partir de textos narrativos mediante un modelo de inteligencia artificial local.

Trabajo de Fin de Grado — Benjamín López Salcedo Grado en Ingeniería del Software · Universidad Politécnica de Madrid · 2026

## Características

- Creación y gestión de grafos relacionales dirigidos
- Visualización interactiva de grafos en un canvas con zoom y desplazamiento
- Posicionamiento automático de nodos
- Gestión de nodos con archivos de contenido individuales para anoteciones
- Gestión de relaciones dirigidas y bidireccionales entre nodos
- Tres modos de visualización del canvas: puntos, cuadrícula y limpio
- Generación automática de grafos a partir de texto narrativo mediante IA
- Revisión, modificación y fusión de resultados generados con el grafo activo
- Seguimiento del proceso de generación en tiempo real

---

## Estructura del repositorio

```
.
├── api                     # Archivos del servidor backend
|   ├── requirements.txt    # Archivo de dependencias
|   └── server.py           # Código del servidor
├── assets                  # Assets utilizados
└── lib                     # Código fuente de la app Flutter
    ├── data/               # Datasources y layout
    ├── domain/             # Entidades del dominio
    └── features/           # Pantallas y widgets

```

---

## Requisitos previos
- Python 3.10 o superior
- GPU compatible con CUDA (recomendado) o CPU

---

## Instalación

### 1. Clona el repositorio
```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
cd tu-repositorio/api
```

### 2. Crea y activa el entorno virtual
```bash
python -m venv venv
```
**Windows:**
```bash
venv\Scripts\activate
```
**Linux/Mac:**
```bash
source venv/bin/activate
```

### 3. Instala las dependencias
```bash
pip install -r requirements.txt
```
Si dispones de GPU compatible con CUDA:
```bash
pip install gpt4all[cuda]
```

### 4. Descarga el modelo

El modelo utilizado es `qwen2.5-coder-7b-instruct-q4_0.gguf`, descargable desde [GPT4All](https://observablehq.com/@simonw/gpt4all-models) o pulsando este [link](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_0.gguf).

Una vez descargado, colócalo en:
- **Windows:** `C:\Users\<usuario>\.cache\gpt4all\`
- **Linux/Mac:** `~/.cache/gpt4all/`

> Si la carpeta `gpt4all` no existe, créala manualmente.

### 5. Inicia el servidor
```bash
uvicorn server:app --host 0.0.0.0 --port 8000
```
El servidor estará disponible en `http://localhost:8000`.

---

## Autoría

Este proyecto ha sido desarrollado como Trabajo de Fin de Grado. El código es de uso libre para fines educativos.
