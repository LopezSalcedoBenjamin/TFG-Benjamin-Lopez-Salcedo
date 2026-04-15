import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/NIA_screen.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_list.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../permission_service.dart';

class GraphCanvas extends StatefulWidget {
  final String graphPath;
  const GraphCanvas({super.key, required this.graphPath});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas>
    with SingleTickerProviderStateMixin{

  String _json = '';

  bool _speedDialOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  void _toggleSpeedDial(){
    setState(() => _speedDialOpen = !_speedDialOpen);
    if(_speedDialOpen){
      _animationController.forward();
    }else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadJson();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut,);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            icon: Icon(Icons.chrome_reader_mode_outlined, size: 35.r,),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        backgroundColor: mainPurple,
        child: const Icon(Icons.add, color: Colors.white,),
      ),

      bottomNavigationBar: BottomAppBar(
        color: bottomBar,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.r,
        height: 80.h,
        child: SizedBox(
          height: 56.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                    MaterialPageRoute(builder: (c) => NiaScreen())
                  ); //RELOAD GRAPH
                },
                child: Image.asset("assets/icons/NIA_button.png")
              ),

              SizedBox(width: 64.w),

              InkWell(
                onTap: () {

                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore, color: Colors.white),
                    Text('Explorar', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


