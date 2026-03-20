
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/create_graph.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainMenu extends StatefulWidget {
  @override
  State<MainMenu> createState() => _MainMenuState();
  //State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
  //}
}

class _MainMenuState extends State<MainMenu>{

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
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
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
                      padding:  EdgeInsets.symmetric(horizontal: 70.w),
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: (){},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: button1,
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

                  /*SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ,
                      itemBuilder: (context,index){

                      },
                    ),
                  ),*/

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