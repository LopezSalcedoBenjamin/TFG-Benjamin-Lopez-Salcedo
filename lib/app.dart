import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

/*
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
                LoginPopUp(context);
              },
              child: Text("Login"),
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

void LoginPopUp(BuildContext context){
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Inicio de sesión", style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 12),

              TextField(
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar")
            ),

          ],
        );
      }
  );
}

class CreateVault extends StatelessWidget{
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

class ManageVault extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
*/
