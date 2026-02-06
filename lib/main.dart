import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:nodos_inteligencia_artificial_tfg_benjamin/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NiaApp());
}

class NiaApp extends StatelessWidget {
  const NiaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //RUTA INICIAL
      initialRoute:  '/',

      //Definición de rutas
      routes: {
        '/': (context) => HomePage(), //Menú inicial de NIA
        '/CreateVault': (context) => CreateVault(), //Menú de creación de grafos
        '/ManageVaults': (context) => ManageVault(),
      },
      /*title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),*/

    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


            /*Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),*/

            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => CreateVault())
                  );
                },
                child: Text('Segunda página')),

            ElevatedButton(
              onPressed: () {
                loginPopUp(context);
              },
              child: Text("Login"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => PruebasFilePicker())
                );
              },
              child: Text("FilePicker Test"),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: /*_incrementCounter*/null,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PruebasFilePicker extends StatelessWidget {

  String? dir = "";
  List<String> folders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


            /*Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),*/

            ElevatedButton(
              onPressed: () async {
                dir = await pickFolder();
                print("Carpeta seleccionada: $dir");
                //if (folders.contains(dir)==false) folders.add(dir!);
                folders.add(dir!);
                print(folders);
              },
              child: Text("Escoger carpeta"),
            ),

            ElevatedButton(
              onPressed: () {
                createFolder("$dir", "test");
              },
              child: Text("Crear carpeta"),
            ),

            ElevatedButton(
              onPressed: () {
                createJsonFile("$dir/prueba.txt", "Lorem ipsum");
              },
              child: Text('Crear y guardar archivo')
            ),

            //Modificar archivo?

            ElevatedButton(
                onPressed: (){
                  pickFile();
                },
                child: Text('Pick File')),
            
            ElevatedButton(
              onPressed: () {

              },
              child: Text("Borrar archivo"),
            ),

            ElevatedButton(
              onPressed: () {

              },
              child: Text("Borrar carpeta"),
            ),

            ElevatedButton(
              onPressed: () async {
                saveFolders(folders);
                print("Folders: $folders \n Persistencia: ");
                final List<String> f = await loadFolders();
                print(f);
              },
              child: Text("Guardar carpetas"),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: /*_incrementCounter*/null,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void loginPopUp(BuildContext context){
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context){
        return AlertDialog( // Si no, usar un dialog simple
          insetPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 24),
          backgroundColor: Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Cabecera del PopUp
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context)
                      ),
                    ),

                    Text(
                      "Iniciar sesión",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/icons/Google_logo.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                ),
              ),

              /*
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context)
                  ),

                  Expanded(
                      child: Center(
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22
                          ),
                        ),
                      )
                  ),

                  Image.asset(
                    'assets/icons/Google_logo.png',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
               */

              Divider(
                color: Colors.grey.shade600,
                thickness: 3,
                height: 1,
              ),

              SizedBox(height: 16),

              //Campo correo electrónico
              Align(
                alignment: Alignment.center,
                child: Text("Correo",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22), ),
              ),
              SizedBox(height: 4,),

              TextField(
                decoration: InputDecoration(
                  hintText: "Ejemplo@gmail.com",
                  filled: true,
                  fillColor: Color(0xFFB8B8B8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              SizedBox(height: 16),

              //Campo contraseña
              Align(
                alignment: Alignment.center,
                child: Text("Contraseña",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
              ),
              SizedBox(height: 4,),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Ejemplo_Contraseña",
                  filled: true,
                  fillColor: Color(0xFFB8B8B8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 10)
                ),
              ),

              SizedBox(height: 20,),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0D0C2D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                    child: Text(
                      "Iniciar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                ),
              ),

              SizedBox(height: 15,),

              Divider(
                color: Colors.grey.shade600,
                thickness: 3,
                height: 1,
              ),

              SizedBox(height: 15,),

              //Registro

              Text("¿No tienes cuenta?",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), ),

              SizedBox(height: 10,),

              SizedBox(
                width: 175,
                child: ElevatedButton(
                    onPressed: () => registerPopUp(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB8B8B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        )
                    ),
                    child: Text(
                      "Registrate",
                      style: TextStyle( color: Colors.black87, fontSize: 20),)
                ),
              )

            ],
          ),
        );
      }
  );
}

void registerPopUp(BuildContext context) {}

//Plan de gestión de archivos (crear una clase para ello y tenerlo separado)

//Crear metodo pickFolder para escoger sitio de guardado

//Escoge un directorio por pantalla y retorna su dirección
Future<String?> pickFolder() async {
  String? folder = await FilePicker.platform.getDirectoryPath();

  if (folder != null) {
    print("Carpeta seleccionada: $folder");
  }

  return folder;
}

//Crea una carpeta en una dirección vaultPath con el nombre escogido folderName
void createFolder(String vaultPath, String folderName) {
  final dir = Directory('$vaultPath/$folderName');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

//Crear archivo json y carpeta dentro de la carpeta escogida

//Crea un archivo en la direccion path con un contenido content
Future<void> createJsonFile(String path, String content) async {
  File file = File(path);
  await file.writeAsString(content);
}

//Selecciona por pantalla un archivo y retorna su dirección
Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
  } else {
    // Usuario canceló la selección
  }
}

//Metodo de creación de txt para los nodos
//Metodo para borrar los archivos
//Olvidar -> quitar del registro de la app, se tendria que usar pickFolder para recordar

//IMPORTANTE __________________
//Metodo de llamada y recepción de texto con Google colab
//NOTA: la conexión con la IA será local descargando el modelo de huggingface y el código diseñado

//PERSISTENCIA----------------------------------------------

Future<void> saveFolders(List<String> folders) async {
  final saves = await SharedPreferences.getInstance();
  await saves.setStringList('folders', folders);
}

Future<List<String>> loadFolders() async {
  final saves = await SharedPreferences.getInstance();
  return saves.getStringList('folders') ?? [];
}


class CreateVault extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Segunda página')),
      body: Center(
        child:
            Column(
              mainAxisSize: MainAxisSize.min ,
              children: [
                Text('Logo'),
                Align(
                  alignment: Alignment.centerLeft ,
                  child: Text('Nombre'),
                ),
                Divider(color: Colors.white24, thickness: 1),
                TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                      hintText: "Graph_name",
                      filled: true,
                      fillColor: Color(0xFFB8B8B8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 10)
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft ,
                  child: Text('Localización'),
                ),
                TextField(
                  readOnly: true,
                  obscureText: false,
                  onTap: (){},
                  decoration: InputDecoration(
                      hintText: "Selecciona carpeta",
                      filled: true,
                      fillColor: Color(0xFFB8B8B8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: (){},
                    ),
                  ),
                ),
                Text('Sincronizar a la nube'),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: (){},
                        child: Text('Si')),
                    ElevatedButton(
                        onPressed: (){},
                        child: Text('No'))
                  ],
                ),
                Divider(color: Colors.white24, thickness: 1),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Crear'),
                ),
              ],
            )
      ),
    );
  }
}

/*class CreateVault extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Segunda página')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('Volver atrás'),
        ),
      ),
    );
  }
}
*/

class ManageVault extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}