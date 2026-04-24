import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/main_menu.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/alert_manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/image_picker.dart';
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

  static void showDeleteGraphDialog(BuildContext context, String path){
    showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
          backgroundColor: backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text("ELIMINAR", style: TextStyle(color: redAlert, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                Divider(
                  color: Colors.grey,
                  thickness: 3.r,
                  indent: 20.w,
                  endIndent: 20.w,
                ),

                SizedBox(height: 10.h,),

                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        Text(
                          "BORRAR el grafo hará que se pierda toda la información.",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                        Text(
                          "Esto borrará la carpeta con su contenido.",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    )
                ),

                SizedBox(height: 20.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Text(
                    '¿Estás seguro de eliminar "${path.split('/').last}"?',
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
                            await FileManager.purgeFromFavorites(path);
                            await FileManager.removeGraphs(path);
                            await FileManager.deleteDirectory(Directory(path));
                            if(!context.mounted) return;
                            AlertHelper.showSnakbar(context, 'Se ha ELIMINADO la carpeta "${path.split('/').last}"', 5, redAlert, Colors.white);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (c) => MainMenu()),
                                    (route) => false
                            );
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
        )
    );
  }

  static void showForgetGraphDialog(BuildContext context, String path){
    showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
          backgroundColor: backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text("OLVIDAR", style: TextStyle(color: redAlert, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                Divider(
                  color: Colors.grey,
                  thickness: 3.r,
                  indent: 20.w,
                  endIndent: 20.w,
                ),

                SizedBox(height: 10.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        Text(
                          "Olvidar el grafo lo quitará de la app sin perder datos.",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                        Text(
                          "Abrir su carpeta en el menú inicial hará que vuelva.",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    )
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
                            await FileManager.purgeFromFavorites(path);
                            await FileManager.removeGraphs(path);
                            if(!context.mounted) return;
                            AlertHelper.showSnakbar(context, 'Se ha olvidado la carpeta "${path.split('/').last}"', 5, redAlert, Colors.white);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (c) => MainMenu()),
                                (route) => false
                            );
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text("Renombrar grafo", style: TextStyle(color: mainPurple, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                    ),

                    Divider(
                      color: Colors.grey,
                      thickness: 3.r,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),

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
                          if (Directory('$parent/${nameGraphController.text}').existsSync()) {
                            setState(() {
                              nameColor = redAlert;
                              exist = true;
                            });
                            return;
                          }else {
                            exist = false;
                          }

                          Navigator.pop(dialogContext);
                          final l = await FileManager.loadFavorites();
                          final String newPath = await FileManager.renameDirectory(path, nameGraphController.text);
                          FileManager.renameFile('$newPath/$oldName.json', '${nameGraphController.text}.json');
                          if (l.contains(path)) await FileManager.toggleFavorite(newPath);
                          await FileManager.purgeFromFavorites(path);
                          await FileManager.removeGraphs(path);
                          await FileManager.saveGraphs(newPath);
                          if(!context.mounted) return;
                          AlertHelper.showSnakbar(context, 'Grafo renombrado a: "${nameGraphController.text}"', 3, backgroundWhite, Colors.black);
                          onConfirm(nameGraphController.text);
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text("Cambiar logo", style: TextStyle(color: mainPurple, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                    ),

                    Divider(
                      color: Colors.grey,
                      thickness: 3.r,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),

                    SizedBox(height: 10.h,),

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
                                }else{
                                  AlertHelper.showSnakbar(context, 'Logo predeterminado seleccionado', 3, backgroundWhite, Colors.black);
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text("Reubicar grafo", style: TextStyle(color: mainPurple, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                    ),

                    Divider(
                      color: Colors.grey,
                      thickness: 3.r,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),

                    SizedBox(height: 5.h,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                      child: Column(
                        children: [
                          Text(
                              'Localización actual del grafo:'
                              ,style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold)
                          ),

                          SizedBox(height: 5.h,),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                            child: RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: '"${path.substring(0,path.lastIndexOf('/'))}/',style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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

                    if (newPath != null) ...[
                      if(exist) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h)
                          ,child:Column(
                          children: [
                            Text("Seleccione una carpeta válida", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                            Text(
                              'Ya existe una carpeta con el mismo nombre en la ubicación escogida',
                              style: TextStyle(color: redAlert, fontWeight: FontWeight.bold, fontSize: 15.sp),
                              textAlign: TextAlign.center,
                            ),
                          ],)
                        ),
                      ]else Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                        child: Column(
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
                    ]
                    else Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                      child: Text("Escoge una nueva carpeta", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
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
                            "Cambiar carpeta",
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

                          final l = await FileManager.loadFavorites();
                          final selectedPath = await FileManager.moveDirectory(path, newPath!);

                          if (l.contains(path)){
                            await FileManager.toggleFavorite(selectedPath);
                          }
                          await FileManager.purgeFromFavorites(path);
                          await FileManager.removeGraphs(path);
                          await FileManager.saveGraphs(selectedPath);
                          if(!context.mounted)return;
                          onConfirm(selectedPath);
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: colorAppBar,
                      elevation: 0,
                      centerTitle: true,
                      title: Text("Crear Nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                    ),

                    Divider(
                      color: Colors.grey,
                      thickness: 3.r,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),

                    //Nombre del Nodo
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                      child: Text("Nombre: ", style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),)
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
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                        child: Text("Contenido: ", style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),)
                    ),

                    SizedBox(height: 10.h,),

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
                                nameColor = redAlert;
                                empty = true;
                              });
                              return;
                            }

                            if(nodeList.any((n) => n.title == nodeNameController.text)){
                              setState(() {
                                nameColor = redAlert;
                                exist = true;
                              });
                              return;
                            }

                            Navigator.pop(dialogContext);
                            if(!context.mounted) return;

                            if(nodeContentController.text.isEmpty){
                              AlertHelper.showSnakbar(context, 'Nodo creado sin contenido', 3, backgroundWhite, Colors.black);
                            }else{
                              AlertHelper.showSnakbar(context, 'Se ha creado el nodo: ${nodeNameController.text}', 3, backgroundWhite, Colors.black);
                            }
                            onConfirm(nodeNameController.text, nodeContentController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainPurple,
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
            )
        ),
    );
  }

  static void showCreateEdgeDialog(){

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: redAlert,
                  elevation: 0,
                  centerTitle: true,
                  title: Text("Eliminar nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                ),

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
                      "Eliminar el nodo lo borrará del grafo junto a su contenido y todas las relaciones con otros nodos.",
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.justify,
                    ),
                ),

                SizedBox(height: 20.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Text(
                    '¿Estás seguro de eliminar "${node.title}"?',
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
        )
    );
  }

  static void showDeleteEdgeDialog(){

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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: colorAppBar,
                      elevation: 0,
                      centerTitle: true,
                      title: Text("Renombrar Nodo", style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),

                    ),

                    Divider(
                      color: Colors.grey,
                      thickness: 3.r,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),

                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                        child: Text("Nombre actual:\n${node.title} ", style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),)
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

                            onConfirm(nodeNameController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainPurple,
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