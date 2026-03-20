import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../consts.dart';
import '../widgets/image_picker.dart';

class ManageGraph extends StatefulWidget {
  @override
  State<ManageGraph> createState() => _ManageGraphState();
//State<StatefulWidget> createState() {
// TODO: implement createState
//throw UnimplementedError();
//}
}

class _ManageGraphState extends State<ManageGraph>{

  File? _imgLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Crear grafo',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          //-------- FONDO --------
          Container(color: g2),
          Opacity(opacity: 0.15,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background_vertical.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [g1,Colors.transparent]).withOpacity(0.1),
            ),
          ),

          //-------- CONTENIDO --------

          SafeArea(
            child: Column(
                children: [

                  SizedBox(height: 50),

                  LogoPicker(onImageSelected: (img){
                    setState(() => _imgLogo = img);
                  }),

                  Text("Imagen", style: TextStyle(color: Colors.white, fontSize: 25),),

                  SizedBox(height: 20,),

                  Divider(
                    color: Colors.white38,
                    thickness: 5,
                    indent: 30,
                    endIndent: 30,
                  ),

                  SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Nombre del grafo", style: TextStyle(color: Colors.white, fontSize: 25),),

                        TextField(
                          decoration: InputDecoration(
                            hintText: "Inserte nombre",
                            filled: true,
                            fillColor: button1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),

                        SizedBox(height: 20,),

                        Text("Localización", style: TextStyle(color: Colors.white, fontSize: 25),),
                        Text("Escoge una carpeta para tu nuevo grafo", style: TextStyle(color: Colors.white, fontSize: 15),),

                        SizedBox(height: 10,),

                        ElevatedButton(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: button1,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5))
                            ),
                            child: Text("Escoge",style: TextStyle(color: Colors.white54, fontSize: 15),)
                        ),


                      ],
                    ),
                  ),

                  SizedBox(height: 25,),

                  Divider(
                    color: Colors.white38,
                    thickness: 5,
                    indent: 30,
                    endIndent: 30,
                  ),

                  SizedBox(height: 25,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                    child:
                    ElevatedButton(
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mainPurple,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5))
                        ),
                        child: Text("Crear",style: TextStyle(color: Colors.white, fontSize: 25),)
                    ),
                  ),

                ]
            ),
          ),
        ],
      ),
    );
  }

}