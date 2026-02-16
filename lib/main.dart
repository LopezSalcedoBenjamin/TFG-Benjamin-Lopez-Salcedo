import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:nodos_inteligencia_artificial_tfg_benjamin/app.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file_Manager.dart';

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
                dir = await FileManager.pickFolder();
                print("Carpeta seleccionada: $dir");
                //if (folders.contains(dir)==false) folders.add(dir!);
                folders.add(dir!);
                print(folders);
              },
              child: Text("Escoger carpeta"),
            ),

            ElevatedButton(
              onPressed: () {
                FileManager.createFolder("$dir", "test");
              },
              child: Text("Crear carpeta"),
            ),

            ElevatedButton(
              onPressed: () {
                FileManager.createFile("$dir/prueba.txt", "Lorem ipsum");
              },
              child: Text('Crear y guardar archivo')
            ),

            //Modificar archivo?

            ElevatedButton(
                onPressed: (){
                  FileManager.pickFile();
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
                FileManager.saveFolders(folders);
                print("Folders: $folders \n Persistencia: ");
                final List<String> f = await FileManager.loadFolders();
                print(f);
              },
              child: Text("Guardar carpetas"),
            ),

            ElevatedButton(
                onPressed: () async{

                },
                child: Text("Carpetas principales")
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

//_________________________________________________________________________________________________________________________Cambiar los placeholder
void createMainFiles (Directory dir, String graphName) async{
  //crear la carpeta principal
  FileManager.createFolder(dir.path, graphName);
  Directory graphDir = Directory("${dir.path}/$graphName");

  //Crear los contenidos de la carpeta
  FileManager.createFolder(graphDir.path, "nodes}");
  Directory genericNodeDir = Directory("${graphDir.path}/nodes}");
  NodeEntity n1 = new NodeEntity(id: '0001', title: 'Push Me', x: 5, y: 0, filePath: "${genericNodeDir.path}/Push ME");
  NodeEntity n2 = new NodeEntity(id: '0002', title: 'Welcome', x: -5, y: 0, filePath: "${genericNodeDir.path}/Welcome");
  FileManager.createFile("${genericNodeDir.path}/${n1.title}.txt", "content");
  FileManager.createFile("${genericNodeDir.path}/${n2.title}.txt", "content");
  FileManager.createFile("$dir/$graphName.json", "content");
  //AÑADIR IMAGEN

  //AÑADIR AL GRAFO
}

NodeEntity genNode (String name, Directory dir, String content){
  Directory nodeDir = Directory("${dir.path}/nodes}");
  FileManager.createFile("$nodeDir.path/name.txt",content);
  NodeEntity n = new NodeEntity(id: "", title: name, x: 1, y: 1, filePath: "$nodeDir.path/name.txt"); //PROBLEMA CON EL ID y las posiciones___________________________________________
  return n;
}

void genEdge (){

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