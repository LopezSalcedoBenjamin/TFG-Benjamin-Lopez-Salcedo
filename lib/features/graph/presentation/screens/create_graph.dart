import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/graph_canvas.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/main_menu.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/alert_manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import '../../../../consts.dart';
import '../../../../data/datasources/graph_file_datasource.dart';
import '../widgets/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGraph extends StatefulWidget {
  @override
  State<CreateGraph> createState() => _CreateGraphState();
//State<StatefulWidget> createState() {
// TODO: implement createState
//throw UnimplementedError();
//}
}

class _CreateGraphState extends State<CreateGraph>{

  File? _imgLogo;
  String? _locGraph;

  Color _hintNameColor = Colors.white54;
  Color _nameColor = Colors.white70;
  Color _locButtonColor = Colors.white70;

  final TextEditingController _nameGraphController = TextEditingController();

  @override
  void dispose() {
    _nameGraphController.dispose(); // libera memoria al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(

        resizeToAvoidBottomInset: false,
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

                    SizedBox(height: 30.h),

                    LogoPicker(onImageSelected: (img){
                      setState(() => _imgLogo = img);
                    }),

                    SizedBox(height: 10.h,),

                    Text("Logo", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),),

                    SizedBox(height: 5.h,),

                    Divider(
                      color: Colors.white38,
                      thickness: 3.r,
                      indent: 30.w,
                      endIndent: 30.w,
                    ),

                    SizedBox(height: 25.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Nombre del grafo", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),),

                          TextField(
                            onTap: () {
                              setState(() => _hintNameColor = Colors.white54);
                              setState(() => _nameColor = Colors.white70 );
                              },
                            controller: _nameGraphController,
                            style: TextStyle(color: _nameColor),
                            maxLength: 25,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(
                              counterStyle: TextStyle(
                                color: _nameGraphController.text.length >= 25 ? redAlert : Colors.white54,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "Inserte nombre...",
                              hintStyle: TextStyle(color: _hintNameColor, fontSize: 15.sp),
                              filled: true,
                              fillColor: button1,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide.none,
                              ),

                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                            ),

                            cursorColor: _nameGraphController.text.length >= 25 ? redAlert : Colors.white,
                            onChanged: (value) {
                              setState(() {});
                            },

                          ),

                          Text("Localización", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),),
                          if (_locGraph != null) ...[
                            Text("El grafo se guardará en:", style: TextStyle(color: _locButtonColor, fontSize: 14.sp),),
                            Text(_locGraph!, style: TextStyle(color: Colors.blue, fontSize: 14.sp),),
                          ]
                          else Text("Escoge una carpeta para guardar el grafo", style: TextStyle(color: _locButtonColor, fontSize: 14.sp),),

                          SizedBox(height: 10.h,),

                          ElevatedButton(
                              onPressed: () async {
                                final folder = _locGraph = await FileManager.pickDirectory();
                                setState(() => _locGraph = folder );
                                setState(() => _locButtonColor = Colors.white70 );
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: button1,
                                  minimumSize: Size(double.infinity, 50.r),
                                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                              ),
                              child: Text(
                                "Escoge",
                                style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.bold),
                              )
                          ),

                        ],
                      ),
                    ),

                    SizedBox(height: 25.h,),

                    Divider(
                      color: Colors.white38,
                      thickness: 3.r,
                      indent: 30.w,
                      endIndent: 30.w,
                    ),

                    SizedBox(height: 25.h,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                      child:
                      ElevatedButton(
                          onPressed: () async {
                            if(_nameGraphController.text.isEmpty && _locGraph == null){
                              setState(() => _hintNameColor = redAlert );
                              setState(() => _locButtonColor = redAlert );
                              AlertHelper.showSnakbar(context, "Por favor seleccione NOMBRE y una LOCALIZACIÓN", 3, redAlert, Colors.white);
                              return;
                            }
                            if(_nameGraphController.text.isEmpty){
                              setState(() => _hintNameColor = redAlert );
                              AlertHelper.showSnakbar(context, "Por favor seleccione un NOMBRE para el grafo", 3, redAlert, Colors.white);
                              return;
                            }
                            if(_locGraph == null){
                              setState(() => _locButtonColor = redAlert );
                              AlertHelper.showSnakbar(context, "Por favor selecciona una LOCALIZACIÓN para el grafo", 3, redAlert, Colors.white);
                              return;
                            }

                            if(Directory("$_locGraph/${_nameGraphController.text}").existsSync()){
                              AlertHelper.showSnakbar(
                                  context,
                                  'Ya existe un grafo o carpeta con nombre "${_nameGraphController.text}" en la ruta seleccionada. Por favor escoja un nombre o localización diferentes'
                                  , 5, redAlert, Colors.white);

                              setState(() => _nameColor = redAlert );
                              setState(() => _locButtonColor = redAlert );

                              return;
                            }

                            final newGraphPath = '$_locGraph/${_nameGraphController.text}';

                            await createGraph(_nameGraphController.text, _locGraph!, _imgLogo);
                            await FileManager.saveGraphs(newGraphPath);
                            if (!mounted) return;

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (c) => GraphCanvas(graphPath: newGraphPath))
                            );

                            if(_imgLogo == null) {
                              AlertHelper.showSnakbar(context, "Se ha seleccionado una imagen por defecto", 3, backgroundWhite, Colors.black);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: mainPurple,
                              minimumSize: Size(double.infinity, 50.r),
                              shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                          ),
                          child: Text("Crear",style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),)
                      ),

                    ),

                  ]
              ),
            ),
          ],
        ),
      )
    );
  }

}
