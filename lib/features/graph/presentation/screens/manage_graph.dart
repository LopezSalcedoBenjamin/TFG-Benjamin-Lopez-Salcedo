import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/main_menu.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/alert_manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import '../../../../consts.dart';
import '../../../../data/datasources/graph_file_datasource.dart';
import '../widgets/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageGraph extends StatefulWidget {

  final String graphPath;
  const  ManageGraph({super.key, required this.graphPath});

  @override
  State<ManageGraph> createState() => _ManageGraphState();
}

class _ManageGraphState extends State<ManageGraph>{

  File? _imgLogo;
  late String _locGraph;
  late String _graphName;

  @override
  void initState() {
    super.initState();
    _graphName =  widget.graphPath.split("/").last;
    _locGraph = widget.graphPath;
    final logoFile = File("$_locGraph/logo.png");
    _imgLogo = logoFile.existsSync() ? logoFile : null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(

          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            title: Text('Gestionar grafo',style: TextStyle(color: Colors.white)),
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

                      Container(
                        width: 130.w,
                        height: 130.h,
                        decoration: BoxDecoration(
                          color: button1,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white24, width: 2.w),
                        ),
                      child: _imgLogo != null && _imgLogo!.existsSync()
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.file(_imgLogo!,
                            fit: BoxFit.cover,
                            width: 130.w, height: 130.h,
                            alignment: Alignment.center,
                            ),
                          )
                          : Icon(Icons.image_not_supported, size: 40.r, color: Colors.white54),
                      ),

                      SizedBox(height: 10.h,),

                      Text(
                        _graphName.split("/").last.length > 25
                            ? '"${_graphName.split("/").last.substring(0, 25)}..."'
                            : '"${_graphName.split("/").last}"',
                        style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("El grafo se ecuentra guardado en:", style: TextStyle(color: Colors.white70, fontSize: 14.sp), ),
                            Text(
                              _locGraph.substring(0, (_locGraph.lastIndexOf('/'))),
                              style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 5.h,),

                      Divider(
                        color: Colors.white38,
                        thickness: 3.r,
                        indent: 30.w,
                        endIndent: 30.w,
                      ),

                      SizedBox(height: 20.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ElevatedButton(
                                onPressed: (){
                                  AppDialogs.showRenameDialog(
                                      context,
                                      _locGraph,
                                      _graphName,
                                      (newName){
                                        setState((){
                                          _graphName = newName;
                                          final newPath = '${_locGraph.substring(0, _locGraph.lastIndexOf('/'))}/$newName';
                                          _locGraph = newPath;
                                          final logoFile = File('$newPath/logo.png');
                                          _imgLogo = logoFile.existsSync() ? logoFile : null;
                                        });
                                      }
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: button1,
                                    minimumSize: Size(double.infinity, 50.r),
                                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                                ),
                                child: Text(
                                  "Renombrar grafo",
                                  style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                )
                            ),

                            ElevatedButton(
                                onPressed: (){
                                  AppDialogs.showChangeLogoDialog(
                                      context,
                                      File('$_locGraph/logo.png'),
                                      (newLogo){
                                        setState(() {
                                          _imgLogo = newLogo.existsSync() ? newLogo : null;
                                          if (newLogo.existsSync()) {
                                            FileManager.copyImage(newLogo, _locGraph);
                                            imageCache.clear();
                                            imageCache.clearLiveImages();
                                          }
                                        });
                                      }
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: button1,
                                    minimumSize: Size(double.infinity, 50.r),
                                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                                ),
                                child: Text(
                                  "Cambiar logo",
                                  style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                )
                            ),

                            ElevatedButton(
                                onPressed: () {
                                  AppDialogs.showChangeLocationDialog(
                                      context,
                                      _locGraph,
                                      (newPath){
                                        setState((){
                                          _graphName = newPath.split('/').last;
                                          _locGraph = newPath;
                                          final logoFile = File('$newPath/logo.png');
                                          _imgLogo = logoFile.existsSync() ? logoFile : null;
                                        });
                                      }
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: button1,
                                    minimumSize: Size(double.infinity, 50.r),
                                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                                ),
                                child: Text(
                                  "Cambiar localizacion",
                                  style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                )
                            ),

                          ],
                        ),
                      ),

                      SizedBox(height: 15.h,),

                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                          child: Column(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    if (!mounted) return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (c) => MainMenu())             //CAMBIAR A SHOWGRAPH_________________________________________________________
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: mainPurple,
                                      minimumSize: Size(double.infinity, 50.r),
                                      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                                  ),
                                  child: Text("Abrir grafo",style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),)
                              ),

                            ],
                          )

                      ),

                      SizedBox(height: 20.h,),

                      Divider(
                        color: Colors.white38,
                        thickness: 3.r,
                        indent: 30.w,
                        endIndent: 30.w,
                      ),

                      SizedBox(height: 20.h,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                        child:
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AppDialogs.showForgetGraphDialog(context, _locGraph);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redAlert,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Olvidar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),

                              SizedBox(
                                width: 10.w,
                              ),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AppDialogs.showDeleteGraphDialog(context, _locGraph);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redAlert,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Eliminar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                      )

                    ]
                ),
              ),
            ],
          ),
        )
    );
  }

}
