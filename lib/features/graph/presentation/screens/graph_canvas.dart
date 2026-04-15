import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_list.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../permission_service.dart';

class GraphCanvas extends StatefulWidget {
  final String graphPath;
  const GraphCanvas({super.key, required this.graphPath});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {

  String _json = '';

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {

    // Ver qué versión de Android tenemos
    final android = await DeviceInfoPlugin().androidInfo;
    final sdk = android.version.sdkInt;
    debugPrint('SDK version: $sdk');

    // Ver el estado actual de cada permiso
    debugPrint('storage.isGranted: ${await Permission.storage.isGranted}');
    debugPrint('storage.isDenied: ${await Permission.storage.isDenied}');
    debugPrint('storage.isPermanentlyDenied: ${await Permission.storage.isPermanentlyDenied}');
    debugPrint('photos.isGranted: ${await Permission.photos.isGranted}');

    final tienePermiso = await PermissionService.hasStoragePermission();
    debugPrint('hasStoragePermission: $tienePermiso');

    if (!tienePermiso) {
      final concedido = await PermissionService.requestStoragePermission();
      debugPrint('requestStoragePermission resultado: $concedido');
      if (!concedido) {
        setState(() => _json = 'Sin permiso de almacenamiento');
        return;
      }
    }

    final graphName = widget.graphPath.split('/').last;
    final file = File('${widget.graphPath}/$graphName.json');

    if (!await file.exists()) {
      setState(() => _json = 'ERROR: Archivo no encontrado en ${file.path}');
      return;
    }

    try {
      final content = await file.readAsString();
      setState(() => _json = content);
    } catch (e) {
      setState(() => _json = 'ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.graphPath.split('/').last, style: TextStyle(color: Colors.white),),
        backgroundColor: colorAppBar,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
            icon: Icon(Icons.manage_search),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => NodeList(graphPath: widget.graphPath,))
              );
            },
        ),
      ),

      backgroundColor: blackGraph1,

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.graphPath,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h,),

              Text(
                _json,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            ],
          )
        )
      ),

      bottomNavigationBar: BottomNavigationBar(
          items: const<BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: bottomBar,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'School',
              backgroundColor: Colors.purple,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.pink,
            ),
          ],

      ),
    );
  }
}


