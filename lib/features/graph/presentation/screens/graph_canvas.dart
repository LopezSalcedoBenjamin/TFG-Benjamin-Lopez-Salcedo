import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/data/datasources/graph_file_datasource.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/NIA_screen.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_list.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../domain/entities/graph_entity.dart';
import '../../../../domain/entities/node_entity.dart';
import '../../../../permission_service.dart';

class GraphCanvas extends StatefulWidget {
  final String graphPath;
  const GraphCanvas({super.key, required this.graphPath});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> with SingleTickerProviderStateMixin{

  late File _jsonFile;
  late GraphEntity _graph = GraphEntity(nodes: [], edges: []);
  List<NodeEntity> _nodeList = [];
  List<EdgeEntity> _edgeList = [];

  String _jsonDEBUG = '';

  bool _speedDialOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _jsonFile = File("${widget.graphPath}/${widget.graphPath.split('/').last}.json");
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut,);
    _loadJson();
    _loadGraph();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent && _speedDialOpen) {
      _toggleSpeedDial();
    }
  }

  Future<void> _loadGraph() async{
    try {
      final String jsonContent;
      final file = _jsonFile;
      jsonContent = await file.readAsString();

      final graph = GraphEntity.fromJson(jsonDecode(jsonContent));

      setState(() {
        _graph = graph;
        _nodeList = graph.nodes;
        _edgeList = graph.edges;
      });

      _loadJson();

    } catch (e) {
      debugPrint('Error cargando grafo: $e');
    }
  }

  //DEBUG, ELIMINAR MAS TARDE
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
        setState(() => _jsonDEBUG = 'Sin permiso de almacenamiento');
        return;
      }
    }

    final graphName = widget.graphPath.split('/').last;
    final file = File('${widget.graphPath}/$graphName.json');

    if (!await file.exists()) {
      setState(() => _jsonDEBUG = 'ERROR: Archivo no encontrado en ${file.path}');
      return;
    }

    try {
      final content = await file.readAsString();
      setState(() => _jsonDEBUG = content);
    } catch (e) {
      setState(() => _jsonDEBUG = 'ERROR: $e');
    }
  }

  void _toggleSpeedDial(){
    setState(() => _speedDialOpen = !_speedDialOpen);
    if(_speedDialOpen){
      _animationController.forward();
    }else {
      _animationController.reverse();
    }
  }

  Widget _buildDialOption({required String label, required IconData icon, required String heroTag, required VoidCallback onPressed,}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //Etiqueta del botón
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        //Botón flotante
        FloatingActionButton.small(
          heroTag: heroTag,
          backgroundColor: button2,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80.h,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.graphPath.split('/').last, style: TextStyle(color: Colors.white),),
              Text(
                "Nodos: ${_graph.nodes.length} | Relaciones: ${_graph.edges.length}",
                style: TextStyle(color: Colors.white24, fontSize: 14.sp),)
            ],
          ),
          backgroundColor: colorAppBar,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.chrome_reader_mode_outlined, size: 35.r,),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => NodeList(graphPath: widget.graphPath,))
              ).then((_) => _loadGraph());
            },
          ),
        ),

        backgroundColor: blackGraph1,

        body: Stack(
          children: [
            Center(
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
                          //_jsonDEBUG,
                          "hola",
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                )
            ),

            Positioned(
              bottom: 35.h,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: _expandAnimation,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDialOption(
                      label: 'Relación',
                      icon: Icons.share,
                      heroTag: 'relacion',
                      onPressed: () {
                        AppDialogs.showCreateEdgeDialog(
                          context,
                          _nodeList,
                          _edgeList,
                          null,
                          null,
                          (newEdge) async{
                            await addEdge(newEdge, widget.graphPath);
                            _loadGraph();
                          }
                        );
                      },
                    ),
                    SizedBox(width: 20.w),
                    _buildDialOption(
                      label: 'Nodo',
                      icon: Icons.circle_outlined,
                      heroTag: 'nodo',
                      onPressed: () {
                        AppDialogs.showCreateNodeDialog(
                          context,
                          _nodeList,
                              (nodeName, nodeContent) async {
                            final n = await createNode(nodeName, widget.graphPath );
                            await addNode(n, widget.graphPath);
                            if (nodeContent.isNotEmpty) {
                              FileManager.writeContent(n.filePath, nodeContent);
                            }
                            _loadGraph();
                            _loadJson();
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: mainPurple,
          onPressed: _toggleSpeedDial,
          child: AnimatedRotation(
            turns: _speedDialOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white),
          ),
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
      ),
    );
  }
}


