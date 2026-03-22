
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/create_graph.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/manage_graph.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/alert_manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';

class MainMenu extends StatefulWidget {
  @override
  State<MainMenu> createState() => _MainMenuState();
  //State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
  //}
}

class _MainMenuState extends State<MainMenu>{

  List<String> _graphs = [];
  List<String> _favorites = [];
  final int itemSize = 70;

  @override
  void initState() {
    super.initState();
    _loadGraphs();
  }

  Future<void> _loadGraphs() async {
    final graphs = await FileManager.loadFolders();
    final favorites = await FileManager.loadFavorites();
    final sortedGraphs = [
      ...favorites.where((f) => graphs.contains(f)),
      ...graphs.where((g) => !favorites.contains(g))
    ];
    setState((){
      _graphs = sortedGraphs;
      _favorites = favorites;
    });
  }

  Future<bool> _tryGraph(String path) async{
    bool verify = false;
    if(await File("$path/${path.split("/").last}.json").exists() && await Directory("$path/nodes").exists()){
      verify = true;
    }
    return verify;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
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

                  SizedBox(height: 50.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                    child: Center(
                      child:
                      Image.asset("assets/icons/NIA_logo_v1.2.png",height: 150.h),
                    ),
                  ),

                  Divider(
                    color: Colors.white38,
                    thickness: 3.r,
                    indent: 30.w,
                    endIndent: 30.w,

                  ),

                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.settings, color: Colors.white70, size: 30.r,),
                        ),
                        IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.help, color: Colors.white70, size: 30.r,),
                        )
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 70.w),
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (c) => CreateGraph())
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: button1,
                                minimumSize: Size(double.infinity, 50.r),
                                shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle, color: Colors.white, size: 30.r,),
                                SizedBox(width: 10.w,),
                                SizedBox(
                                    width: 150.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text("Crear grafo", style: TextStyle(color: Colors.white, fontSize: 22.sp),)],
                                    )
                                ),
                              ],
                            )
                        ),

                        SizedBox(height: 15.h,),

                        ElevatedButton(
                            onPressed: () async {
                              final String? folderGraph = await FileManager.pickFolder();
                              if (folderGraph == null) return;

                              if (await _tryGraph(folderGraph) == false){
                                AlertHelper.showSnakbar(
                                    context,
                                    'La carpeta "${folderGraph.split("/").last}" no es válida o no contiene la estructura del grafo',
                                    5,
                                    redAlert,
                                    Colors.white);
                                return;
                              }
                              if (await File("$folderGraph/logo.png").exists() == false) {
                                AlertHelper.showSnakbar(
                                    context,
                                    'Carpeta añadida sin archivo "logo.png", puedes añadir un logo más tarde',
                                    5,
                                    backgroundWhite,
                                    Colors.black);
                              }

                              await FileManager.saveFolders(folderGraph);
                              await _loadGraphs();
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: button1,
                                minimumSize: Size(double.infinity, 50.r),
                                shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded, color: Colors.white, size: 30.r,),
                                SizedBox(width: 10.w,),
                                SizedBox(
                                    width: 150.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text("Abrir carpeta", style: TextStyle(color: Colors.white, fontSize: 22.sp),),],
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.h,),

                  Divider(
                    color: Colors.white38,
                    thickness: 3.r,
                    indent: 30.w,
                    endIndent: 30.w,
                  ),

                  SizedBox(height: 15.h,),

                  Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 60.w),
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: (){},
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: button3,
                                  minimumSize: Size(double.infinity, 50.r),
                                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 30.r,),
                                  SizedBox(width: 10.w,),
                                  SizedBox(
                                    width: 150.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text("Recientes", style: TextStyle(color: Colors.white, fontSize: 22.sp),),],
                                    )
                                  ),
                                ],
                              )
                          )
                        ],
                      )
                  ),

                  SizedBox(height: 15.h,),

                  SizedBox(
                    height: 250.h,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 50.w),
                      itemCount: _graphs.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                              children: [
                                Container(
                                  width: itemSize.w,
                                  height: itemSize.h,
                                  decoration: BoxDecoration(
                                    color: button1,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: Colors.white24, width: 2.w),
                                  ),
                                  child: File("${_graphs[index]}/logo.png").existsSync()
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.file(
                                        File("${_graphs[index]}/logo.png"),
                                        fit: BoxFit.cover,
                                        width: itemSize.w, height: itemSize.h,
                                        alignment: Alignment.center,
                                      ),
                                    )
                                      : Icon(Icons.image_not_supported, size: 40.r, color: Colors.white54),
                                ),

                                SizedBox(width: 10.w,),

                                Expanded(
                                    child: Container(
                                      height: itemSize.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.r),
                                        border: Border.all(color: Colors.white24, width: 2.w),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: (){},
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: button3,
                                                  minimumSize: Size(double.infinity, double.infinity),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsets.all(18.r),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(12.r),
                                                        bottomLeft: Radius.circular(12.r),
                                                      )
                                                  )
                                              ),
                                              child: Text(
                                                _graphs[index].split("/").last.length > 25
                                                    ? "${_graphs[index].split("/").last.substring(0, 25)}..."
                                                    : _graphs[index].split("/").last,
                                                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            width: (itemSize/2).w,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: () async {
                                                        await FileManager.toggleFavorites(_graphs[index]);
                                                        await _loadGraphs();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor: button1,
                                                          minimumSize: Size.zero,
                                                          padding: EdgeInsets.zero,
                                                          fixedSize: Size((itemSize/2).h, (itemSize/2).h),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(12.r),
                                                            )
                                                          )
                                                      ),
                                                      child: Icon(
                                                          _favorites.contains(_graphs[index])
                                                              ? Icons.auto_awesome
                                                              : Icons.auto_awesome_outlined,
                                                          size: 20.r,
                                                          color: _favorites.contains(_graphs[index])
                                                              ? Colors.amber
                                                              : Colors.white54
                                                      )
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (c) => ManageGraph(graphPath: _graphs[index]))
                                                        ).then((_) => _loadGraphs());
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor: button1,
                                                          minimumSize: Size.zero,
                                                          padding: EdgeInsets.zero,
                                                          fixedSize: Size((itemSize/2).h, (itemSize/2).h),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                bottomRight: Radius.circular(12.r),
                                                              )
                                                          )
                                                      ),
                                                      child: Icon(Icons.more_vert, size: 20.r, color: Colors.white54)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                ),
                              ]
                          )
                        );
                      },
                    ),
                  ),

                ],
              )
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            right: 16.w,
            child: InkWell(
              onTap: (){},
              borderRadius: BorderRadius.circular(22.r),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white, size: 40.r,),
              ),
            ),
          )
          
        ],
      ),
    );
  }
}