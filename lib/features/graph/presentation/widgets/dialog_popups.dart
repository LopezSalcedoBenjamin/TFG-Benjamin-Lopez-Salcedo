import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/main_menu.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/alert_manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/image_picker.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/node_search_Autocomplete.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../permission_service.dart';

class AppDialogs{

  static Future<void> showPermissionDeniedDialog(BuildContext context, bool esPermanente) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.folder_off_outlined, size: 40, color: mainPurple),
        title: const Text('Permiso necesario', style: TextStyle(color: redAlert, fontWeight: FontWeight.bold),),
        backgroundColor: backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.h),
          child: Text(
            esPermanente
                ? 'Has denegado el permiso permanentemente.\n\nPulsa "Reintentar" para volver a solicitarlo.'
                : 'Sin permiso de almacenamiento no es posible acceder a los grafos guardados.',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: redAlert),),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: mainPurple),
            icon: const Icon(Icons.settings),
            label: const Text('Reintentar'),
            onPressed: () async {
              Navigator.pop(ctx);
              final granted = await PermissionService.requestStoragePermission();
              if (!granted && context.mounted) {
                final permanent = await PermissionService.isPermanentlyDenied();
                AppDialogs.showPermissionDeniedDialog(context, permanent);
              }
            },
          ),
        ],
      ),
    );
  }

  static void showDeleteGraphDialog(BuildContext context, String graphName, Function() onConfirm){
    showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
          backgroundColor: backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: GestureDetector(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // _____________________________________________________HEADER_____________________________________________________
                  AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: redAlert,
                    elevation: 0,
                    toolbarHeight: 70.h,
                    centerTitle: true,
                    title: Text("Eliminar grafo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  ),

                  // _____________________________________________________BODY_____________________________________________________
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Text(
                              "ELIMINAR el grafo hará que se pierda toda la información.\nEsto borrará la carpeta con su contenido.",
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.justify,
                            )
                        ),

                        SizedBox(height: 10.h,),

                        Divider(
                          color: Colors.grey,
                          thickness: 3.r,
                          indent: 20.w,
                          endIndent: 20.w,
                        ),

                        SizedBox(height: 10.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            '¿Estás seguro de eliminar "${graphName}"?',
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 15.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                          child:
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AlertHelper.showSnakbar(context, 'Se ha cancelado la operación "ELIMINAR"', 3, backgroundWhite, Colors.black);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: g2,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Cancelar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),

                              SizedBox(
                                width: 10.w,
                              ),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;
                                    onConfirm();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    elevation: 0,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

  static void showForgetGraphDialog(BuildContext context, Function() onConfirm){
    showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
          backgroundColor: backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: GestureDetector(
            onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // _____________________________________________________HEADER_____________________________________________________
                  AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: redAlert,
                    elevation: 0,
                    toolbarHeight: 70.h,
                    centerTitle: true,
                    title: Text("Olvidar grafo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  ),

                  // _____________________________________________________BODY_____________________________________________________
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        SizedBox(height: 10.h,),

                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Text(
                              "OLVIDAR el grafo lo quitará de la app sin perder datos.\nAbrir su carpeta en el menú inicial hará que vuelva.",
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.justify,
                            )
                        ),

                        SizedBox(height: 10.h,),

                        Divider(
                          color: Colors.grey,
                          thickness: 3.r,
                          indent: 20.w,
                          endIndent: 20.w,
                        ),

                        SizedBox(height: 10.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            '¿Estás seguro de olvidar el grafo?',
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 15.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                          child:
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AlertHelper.showSnakbar(context, 'Se ha cancelado la operación "Olvidar"', 3, backgroundWhite, Colors.black);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: g2,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Cancelar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),

                              SizedBox(
                                width: 10.w,
                              ),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;
                                    onConfirm();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Olvidar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

  static void showRenameDialog(BuildContext context, String path, String oldName, Function(String) onConfirm){

    Color hintNameColor = Colors.black26;
    Color nameColor = mainBlue;
    bool exist = false;

    final TextEditingController nameGraphController = TextEditingController();

    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                      children: [

                        // _____________________________________________________HEADER_____________________________________________________
                        AppBar(
                          iconTheme: IconThemeData(
                            color: Colors.white
                          ),
                          backgroundColor: mainPurple,
                          elevation: 0,
                          toolbarHeight: 70.h,
                          centerTitle: true,
                          title: Text("Renombrar grafo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                        ),

                        // _____________________________________________________BODY_____________________________________________________
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(height: 10.h,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Nombre actual: ',style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                                          TextSpan(text: '"$oldName"',style: TextStyle(color: mainBlue, fontSize: 20.sp, fontWeight: FontWeight.bold))
                                        ]
                                    )
                                ),
                              ),

                              SizedBox(height: 15.h,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: TextField(
                                  onTap: () {
                                    setState(() {
                                      hintNameColor = Colors.black26;
                                      nameColor = mainBlue;
                                      exist = false;
                                    });
                                  },
                                  controller: nameGraphController,
                                  style: TextStyle(color: nameColor),
                                  maxLength: 25,
                                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  decoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      color: nameGraphController.text.length >= 25 ? redAlert : Colors.black26,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    hintText: "Inserte nuevo nombre...",
                                    hintStyle: TextStyle(color: hintNameColor, fontSize: 15.sp),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.r),
                                      borderSide: BorderSide.none,
                                    ),

                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                                  ),

                                  cursorColor: nameGraphController.text.length >= 25 ? redAlert : cursorColor,
                                  onChanged: (value) {
                                    setState(() {});
                                  },

                                ),
                              ),

                              if(exist) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h)
                                  ,child:Text(
                                  'Ya existe ese nombre en la carpeta actual',
                                  style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                  textAlign: TextAlign.center,
                                ),
                                ),
                              ],

                              SizedBox(height: 15.h,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(nameGraphController.text.isEmpty){
                                      Navigator.pop(dialogContext);
                                      if(!context.mounted) return;
                                      AlertHelper.showSnakbar(context, 'No se ha cambiado el nombre', 3, backgroundWhite, Colors.black);
                                      return;
                                    }

                                    final parent = path.substring(0, path.lastIndexOf('/'));
                                    if (Directory('$parent/${nameGraphController.text.trim()}').existsSync()) {
                                      setState(() {
                                        nameColor = redAlert;
                                        exist = true;
                                      });
                                      return;
                                    }else {
                                      exist = false;
                                    }

                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;
                                    AlertHelper.showSnakbar(context, 'Grafo renombrado a: "${nameGraphController.text.trim()}"', 3, backgroundWhite, Colors.black);
                                    onConfirm(nameGraphController.text.trim());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlue,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Cambiar nombre", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                )
                ),
              )
            )
        )
    );
  }

  static void showChangeLogoDialog(BuildContext context, File logo, Function(File) onConfirm){

    bool logoChanged = false;

    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                        iconTheme: IconThemeData(
                            color: Colors.white
                        ),
                        backgroundColor: mainPurple,
                        elevation: 0,
                        toolbarHeight: 70.h,
                        centerTitle: true,
                        title: Text("Cambiar logo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              width: 130.w,
                              height: 130.h,
                              decoration: BoxDecoration(
                                color: mainPurple,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: LogoPicker(onImageSelected: (img){
                                setState((){
                                  logo = img;
                                  logoChanged = true;
                                });
                              }),
                            ),

                            SizedBox(height: 25.h,),

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if(logo.existsSync()) await FileManager.deleteFile(logo);
                                          if (!context.mounted) return;
                                          Navigator.pop(dialogContext);
                                          onConfirm(logo);
                                          AlertHelper.showSnakbar(context, 'Se ha eliminado el logo del grafo\nLogo predeterminado seleccionado', 3, backgroundWhite, Colors.black);
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

                                    SizedBox(width: 10.w,),

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(dialogContext);
                                          if (!context.mounted) return;

                                          if(!logoChanged){
                                            AlertHelper.showSnakbar(context, 'No se ha cambiado el logo', 3, backgroundWhite, Colors.black);
                                            return;
                                          }

                                          onConfirm(logo);

                                          if(logo.existsSync()) {
                                            AlertHelper.showSnakbar(context, 'Se ha cambiado el logo del grafo', 3, backgroundWhite, Colors.black);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mainBlue,
                                          elevation: 0,
                                          minimumSize: Size(double.infinity, 50.r),
                                          padding: EdgeInsets.all(10.r),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                        ),
                                        child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                )
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            )
        )
    );
  }

  static void showChangeLocationDialog(BuildContext context, String path, Function(String) onConfirm){

    String? newPath;
    bool exist = false;

    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
                clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                        iconTheme: IconThemeData(
                            color: Colors.white
                        ),
                        backgroundColor: mainPurple,
                        elevation: 0,
                        toolbarHeight: 70.h,
                        centerTitle: true,
                        title: Text("Reubicar grafo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                              child: Column(
                                children: [
                                  Text(
                                      'Localización actual:'
                                      ,style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold)
                                  ),

                                  SizedBox(height: 5.h,),

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                    child: RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(text: '"${path.substring(0,path.lastIndexOf('/'))}/',style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                              TextSpan(text: '${path.split('/').last}"', style: TextStyle(color: Colors.blue, fontSize: 16.sp, fontWeight: FontWeight.bold))
                                            ]
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10.h,),

                            Divider(
                              color: Colors.grey,
                              thickness: 3.r,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),

                            SizedBox(height: 5.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: newPath == null ?
                              Text("Selecciona una nueva carpeta", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                                  : exist ?
                              Column(
                                children: [
                                  Text("Seleccione una carpeta válida", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  Text(
                                    'Ya existe una carpeta con el mismo nombre en la ubicación escogida',
                                    style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                    textAlign: TextAlign.center,
                                  ),
                                ],)
                                  : Column(
                                children: [
                                  Text("El grafo se guardará en:", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                    child: Text(
                                        '"$newPath"',
                                        style: TextStyle(color: Colors.blue, fontSize: 16.sp, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 15.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 0.h),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    final folder = newPath = await FileManager.pickDirectory();
                                    setState(() {
                                      newPath = folder;
                                      exist = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: mainPurple,
                                      elevation: 0,
                                      minimumSize: Size(double.infinity, 50.r),
                                      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(5.r))
                                  ),
                                  child: Text(
                                    newPath == null ?
                                    "Escoger carpeta"
                                    : "Cambiar carpeta",
                                    style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                                  )
                              ),
                            ),

                            SizedBox(height: 15.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(newPath == null){
                                    Navigator.pop(dialogContext);
                                    if(!context.mounted)return;
                                    AlertHelper.showSnakbar(context, 'No se ha escogido nueva ruta', 3, backgroundWhite, Colors.black);
                                    return;
                                  }

                                  if(Directory('$newPath/${path.split('/').last}').existsSync()){
                                    setState(() {
                                      exist = true;
                                    });
                                    return;
                                  }

                                  Navigator.pop(dialogContext);

                                  if(!context.mounted)return;
                                  onConfirm(newPath!);
                                  AlertHelper.showSnakbar(context, 'Se ha cambiado la ruta del grafo exitosamente', 3, backgroundWhite, Colors.black);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainBlue,
                                  elevation: 0,
                                  minimumSize: Size(double.infinity, 50.r),
                                  padding: EdgeInsets.all(10.r),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                ),
                                child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            )
        )
    );
  }

  static void showCreateNodeDialog(BuildContext context, List<NodeEntity> nodeList, Function(String nodeName, String nodeContent) onConfirm){

    final TextEditingController nodeNameController = TextEditingController();
    final TextEditingController nodeContentController = TextEditingController();

    Color hintNameColor = Colors.black26;
    Color nameColor = mainBlue;
    bool empty = false;
    bool exist = false;

    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: mainBlue,
                        elevation: 0,
                        toolbarHeight: 70.h,
                        centerTitle: true,
                        title: Text("Nuevo nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            //Nombre del Nodo
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Nombre: ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                )
                            ),

                            SizedBox(height: 5.h,),

                            if(empty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child:Text(
                                  'Por favor, selecciona un nombre.',
                                  style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            if(exist) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h)
                                ,child:Text(
                                'Ya existe un nodo con ese nombre.\nEscriba uno diferente.',
                                style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                textAlign: TextAlign.center,
                              ),
                              ),
                            ],

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    hintNameColor = Colors.black26;
                                    nameColor = mainBlue;
                                    exist = false;
                                    empty = false;
                                  });
                                },
                                controller: nodeNameController,
                                style: TextStyle(color: nameColor),
                                maxLength: 25,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: nodeNameController.text.length >= 25 ? redAlert : Colors.black26,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: "Inserte un nombre...",
                                  hintStyle: TextStyle(color: hintNameColor, fontSize: 15.sp),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide: BorderSide.none,
                                  ),

                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                                ),

                                cursorColor: nodeNameController.text.length >= 25 ? redAlert : cursorColor,

                              ),
                            ),

                            //Contenido del nodo

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Contenido: ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                )
                            ),

                            SizedBox(height: 5.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: TextField(
                                controller: nodeContentController,
                                cursorColor: cursorColor,
                                minLines: 1,
                                maxLines: 3,
                                style: TextStyle(color: mainBlue),
                                decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: "(Opcional)",
                                  hintStyle: TextStyle(color: Colors.black26, fontSize: 15.sp),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide: BorderSide.none,
                                  ),


                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                                ),
                              ),
                            ),

                            Divider(
                              color: Colors.grey,
                              thickness: 3.r,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //Comprobamos si se escogió un nombre
                                    if(nodeNameController.text.isEmpty){
                                      setState(() {
                                        hintNameColor = redAlert;
                                        empty = true;
                                      });
                                      return;
                                    }else{
                                      empty = false;
                                    }

                                    if(nodeList.any((n) => n.title == nodeNameController.text.trim())){
                                      setState(() {
                                        nameColor = redAlert;
                                        exist = true;
                                      });
                                      return;
                                    }else{
                                      exist = false;
                                    }

                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;

                                    if(nodeContentController.text.isEmpty){
                                      AlertHelper.showSnakbar(context, 'Nodo creado sin contenido', 3, backgroundWhite, Colors.black);
                                    }else{
                                      AlertHelper.showSnakbar(context, 'Se ha creado el nodo: ${nodeNameController.text}', 3, backgroundWhite, Colors.black);
                                    }
                                    onConfirm(nodeNameController.text.trim(), nodeContentController.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlue,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )

                          ],
                        ),
                      )

                    ],
                  ),
                ),
              )
            )
        ),
    );
  }

  static void showCreateEdgeDialog(
      BuildContext context,
      List<NodeEntity> nodeList,
      List<EdgeEntity> edgeList,
      NodeEntity? fixedOrigin,
      NodeEntity? fixedDestination,
      Function(EdgeEntity) onConfirm
      ){
    final TextEditingController originNodeController = TextEditingController();
    final TextEditingController destinationNodeController = TextEditingController();
    final TextEditingController typeController = TextEditingController();

    bool hasType = false;
    bool hasOrigin = false;
    bool hasDestination = false;
    bool exist = false;

    Color hintTypeColor = Colors.black38;
    Color hintOriginColor = Colors.black38;
    Color hintDestinationColor = Colors.black38;
    Color existColor = Colors.black;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: mainBlue,
                          elevation: 0,
                          toolbarHeight: 90.h,
                          centerTitle: true,
                          title: fixedOrigin == null && fixedDestination == null ?
                          Column(
                            children: [
                              Text("Nueva relación", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                              Text("Conecta dos nodos", style: TextStyle(color: Colors.white24, fontSize: 14.sp, fontWeight: FontWeight.bold))
                            ],
                          )
                              : fixedOrigin != null ?
                          Column(
                            children: [
                              Text("Nueva relación saliente", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                              Text("Desde este nodo a otro", style: TextStyle(color: Colors.white24, fontSize: 14.sp, fontWeight: FontWeight.bold))
                            ],
                          )
                              : Column(
                            children: [
                              Text("Nueva relación entrante", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                              Text("Desde otro nodo a este", style: TextStyle(color: Colors.white24, fontSize: 14.sp, fontWeight: FontWeight.bold))
                            ],
                          )
                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          children: [

                            //Nodo origen
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    fixedOrigin != null? "Origen - FIJO" : "Origen:",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: mainPurple, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                )
                            ),

                            SizedBox(height: 5.h,),

                            if(hasOrigin)...[
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "Por favor, escoge un nodo origen",
                                      style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                      textAlign: TextAlign.center,
                                    )
                                  )
                              ),
                            ],

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: fixedOrigin == null ?
                                NodeSearchAutocomplete(
                                  nodeList: fixedDestination == null ? nodeList
                                      : nodeList.where((n) => n.id != fixedDestination.id).toList(),
                                  nodeController: originNodeController,
                                  style: NodeSearchStyle(
                                    hintColor: hintOriginColor,
                                    textColor: existColor,
                                  ),
                                  onTap: (){
                                    setState(() {
                                      hintOriginColor = Colors.black38;
                                      existColor = Colors.black;
                                      hasOrigin = false;
                                    });
                                  },
                                )
                                    :Container(
                                    height: 60.h,
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        color: mainPurple.withAlpha(30),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: mainPurple, width: 2.w)
                                    ),
                                    child: Text(fixedOrigin.title, style: TextStyle(fontSize: 16.sp),)
                                )
                            ),

                            SizedBox(height: 10.h,),

                            Icon(
                              Icons.arrow_downward,
                              size: 32.r,
                              color: fixedOrigin != null ? mainPurple : fixedDestination != null ? mainGreen : mainBlue,
                            ),


                            //Nodo Destino

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    fixedDestination != null? "Destino - FIJO" : "Destino:",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: mainGreen, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                )
                            ),

                            SizedBox(height: 5.h,),

                            if(hasDestination)...[
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "Por favor, escoge un nodo destino",
                                        style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                        textAlign: TextAlign.center,
                                    ),
                                  )
                              ),
                            ],

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                                child: fixedDestination == null ?
                                NodeSearchAutocomplete(
                                  nodeList: fixedOrigin == null ? nodeList
                                      : nodeList.where((n) => n.id != fixedOrigin.id).toList(),
                                  nodeController: destinationNodeController,
                                  style: NodeSearchStyle(
                                    hintColor: hintDestinationColor,
                                    textColor: existColor,
                                  ),
                                  onTap: (){
                                    setState(() {
                                      hintDestinationColor = Colors.black38;
                                      existColor = Colors.black;
                                      hasDestination = false;
                                    });
                                  },
                                )
                                    :Container(
                                    height: 60.h,
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        color: mainGreen.withAlpha(30),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: mainGreen, width: 2.w)
                                    ),
                                    child: Text(fixedDestination.title, style: TextStyle(fontSize: 16.sp),)
                                )
                            ),

                            SizedBox(height: 10.h,),

                            //Tipo de relación

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Tipo de relación:",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: mainBlue, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                )
                            ),

                            SizedBox(height: 5.h,),

                            if(hasType)...[
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "Por favor, escribe el tipo de relación",
                                        style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                        textAlign: TextAlign.center,
                                    ),
                                  )
                              ),
                            ],

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Container(
                                height: 60.h,
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.black12, width: 2.w)
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.link, size: 20.r, color: hintTypeColor,),
                                    SizedBox(width: 5.w,),
                                    Expanded(
                                        child: TextField(
                                          onTap: () {
                                            setState(() {
                                              hintTypeColor = Colors.black38;
                                              existColor = Colors.black;
                                              hasType = false;
                                            });
                                          },
                                          controller: typeController,
                                          style: TextStyle(color: existColor),
                                          maxLength: 25,
                                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                          decoration: InputDecoration(
                                            counterText: "",
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: "Escribe el tipo",
                                            hintStyle: TextStyle(color: hintTypeColor, fontSize: 16.sp),
                                            suffix: Text(
                                              "${typeController.text.length}/25",
                                              style: TextStyle(
                                                  color: typeController.text.length >= 25 ? redAlert : Colors.black26,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                              )
                                            ),
                                          ),
                                          cursorColor: typeController.text.length >= 25 ? redAlert : cursorColor,
                                          onChanged: (_){
                                            setState((){});
                                          },
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if(exist)...[
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 0.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      "Ya existe una relación igual a esta\nEscoge otros nodos o cambia el tipo",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: redAlert, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                  )
                              ),
                            ],

                            Divider(
                              color: Colors.grey,
                              thickness: 3.r,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //Comprobamos nodo origen
                                    if(fixedOrigin == null){
                                      if(originNodeController.text.isEmpty){
                                        setState(() {
                                          hasOrigin = true;
                                          hintOriginColor = redAlert;
                                        });
                                        return;
                                      }
                                    }else{
                                      hasOrigin = false;
                                    }

                                    //Comprobamos nodo destino
                                    if(fixedDestination == null){
                                      if(destinationNodeController.text.isEmpty){
                                        setState(() {
                                          hasDestination = true;
                                          hintDestinationColor = redAlert;
                                        });
                                        return;
                                      }
                                    }else{
                                      hasDestination = false;
                                    }

                                    //Comprobamos tipo de relación
                                    if(typeController.text.isEmpty){
                                      setState(() {
                                        hasType = true;
                                        hintTypeColor = redAlert;
                                      });
                                      return;
                                    }else{
                                      hasType = false;
                                    }

                                    final newEdge = EdgeEntity(
                                        from: fixedOrigin != null? fixedOrigin.title : originNodeController.text.trim(),
                                        to: fixedDestination != null? fixedDestination.title : destinationNodeController.text.trim(),
                                        type: typeController.text.trim()
                                    );

                                    //Comprobamos si ya exsiste la relación

                                    if(edgeList.any(
                                            (e) => e.from == newEdge.from &&
                                                e.type == newEdge.type &&
                                                e.to == newEdge.to)
                                    ){
                                      setState(() {
                                        exist = true;
                                        existColor = redAlert;
                                      });
                                      return;
                                    }else{
                                      exist = false;
                                    }

                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;

                                    AlertHelper.showSnakbar(
                                        context,
                                        'Se ha creado la relación:\n"${newEdge.from} -> [${newEdge.type}] -> ${newEdge.to}"',
                                        3, backgroundWhite, Colors.black);

                                    onConfirm(newEdge);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlue,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )
                          ],
                        ),
                      )


                    ],
                  ),
                ),
              )
          )
      ),
    );
  }

  static void showDeleteNodeDialog(BuildContext context, NodeEntity node, Function() onConfirm ){
    showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
          backgroundColor: backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: GestureDetector(
            onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // _____________________________________________________HEADER_____________________________________________________
                  AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: redAlert,
                    elevation: 0,
                    toolbarHeight: 70.h,
                    centerTitle: true,
                    title: Text("Eliminar nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  ),

                  // _____________________________________________________BODY_____________________________________________________
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            "Eliminar el nodo lo borrará del grafo junto a su contenido y todas las relaciones con otros nodos.",
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.justify,
                          ),
                        ),

                        SizedBox(height: 10.h,),

                        Divider(
                          color: Colors.grey,
                          thickness: 3.r,
                          indent: 20.w,
                          endIndent: 20.w,
                        ),

                        SizedBox(height: 10.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            '¿Estás seguro de eliminar este nodo?',
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 15.h,),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                          child:
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AlertHelper.showSnakbar(context, 'Se ha cancelado la operación "ELIMINAR"', 3, backgroundWhite, Colors.black);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: g2,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Cancelar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),

                              SizedBox(
                                width: 10.w,
                              ),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;
                                    AlertHelper.showSnakbar(context, 'Se ha ELIMINADO el nodo "${node.title}"', 5, redAlert, Colors.white);
                                    onConfirm();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("ELIMINAR", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

  static void showDeleteEdgeDialog(BuildContext context, EdgeEntity edge, Function() onConfirm){

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: redAlert,
                          elevation: 0,
                          toolbarHeight: 70.h,
                          centerTitle: true,
                          title: Text("Eliminar relación", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Text(
                                'Eliminar la relación borrará del registro la conexión que tiene con el otro nodo.',
                                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.justify,
                              ),
                            ),

                            SizedBox(height: 10.h,),

                            Divider(
                              color: Colors.grey,
                              thickness: 3.r,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),

                            SizedBox(height: 10.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Text(
                                '¿Estás seguro de eliminar la relación?',
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 15.h,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child:
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        AlertHelper.showSnakbar(context, 'Se ha cancelado la operación "ELIMINAR"', 3, backgroundWhite, Colors.black);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: g2,
                                        elevation: 0,
                                        minimumSize: Size(double.infinity, 50.r),
                                        padding: EdgeInsets.all(10.r),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                      ),
                                      child: Text("Cancelar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10.w,
                                  ),

                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);
                                        if(!context.mounted) return;
                                        AlertHelper.showSnakbar(
                                            context,
                                            'Se ha ELIMINADO la relación\n"${edge.from} -> [${edge.type}] -> ${edge.to}"'
                                            , 5, redAlert, Colors.white);
                                        onConfirm();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        elevation: 0,
                                        minimumSize: Size(double.infinity, 50.r),
                                        padding: EdgeInsets.all(10.r),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                      ),
                                      child: Text("ELIMINAR", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          )
      ),
    );
  }

  static void showRenameNodeDialog(BuildContext context, List<NodeEntity> nodeList, NodeEntity node, Function(String nodeName) onConfirm){

    final TextEditingController nodeNameController = TextEditingController();

    Color hintNameColor = Colors.black26;
    Color nameColor = mainBlue;
    bool empty = false;
    bool exist = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (builderContext, setState) => Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              backgroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // _____________________________________________________HEADER_____________________________________________________
                      AppBar(
                        iconTheme: IconThemeData(
                            color: Colors.white
                        ),
                        backgroundColor: mainPurple,
                        elevation: 0,
                        toolbarHeight: 70.h,
                        centerTitle: true,
                        title: Text("Renombrar Nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
                      ),

                      // _____________________________________________________BODY_____________________________________________________
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 0.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Nombre actual:",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                        Text(
                                          '"${node.title}"',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: mainPurple, fontSize: 20.sp, fontWeight: FontWeight.bold),),
                                      ]
                                  ),
                                )
                            ),

                            SizedBox(height: 10.h,),

                            if(empty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h)
                                ,child:Text(
                                'Por favor, selecciona un nombre.',
                                style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                textAlign: TextAlign.center,
                              ),
                              ),
                            ],
                            if(exist) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h)
                                ,child:Text(
                                'Ya existe un nodo con ese nombre.\nEscriba uno diferente.',
                                style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                textAlign: TextAlign.center,
                              ),
                              ),
                            ],

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    hintNameColor = Colors.black26;
                                    nameColor = mainBlue;
                                  });
                                },
                                controller: nodeNameController,
                                style: TextStyle(color: nameColor),
                                maxLength: 25,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: nodeNameController.text.length >= 25 ? redAlert : Colors.black26,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: "Inserte un nuevo nombre...",
                                  hintStyle: TextStyle(color: hintNameColor, fontSize: 15.sp),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide: BorderSide.none,
                                  ),

                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                                ),

                                cursorColor: nodeNameController.text.length >= 25 ? redAlert : cursorColor,
                              ),
                            ),

                            Divider(
                              color: Colors.grey,
                              thickness: 3.r,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //Comprobamos si se escogió un nombre
                                    if(nodeNameController.text.isEmpty){
                                      setState(() {
                                        nameColor = redAlert;
                                        empty = true;
                                      });
                                      return;
                                    }

                                    if(nodeList.any((n) => n.title == nodeNameController.text.trim())){
                                      setState(() {
                                        nameColor = redAlert;
                                        exist = true;
                                      });
                                      return;
                                    }

                                    Navigator.pop(dialogContext);
                                    if(!context.mounted) return;

                                    onConfirm(nodeNameController.text.trim());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlue,
                                    elevation: 0,
                                    minimumSize: Size(double.infinity, 50.r),
                                    padding: EdgeInsets.all(10.r),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                                  ),
                                  child: Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
          )
      ),
    );
  }

  static void showModifyEdgeDialog(){

  }

  static void showUnattachedNodesDialog(){

  }

  static void loginPopUp(BuildContext context){
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

  static void registerPopUp(BuildContext context) {}
}