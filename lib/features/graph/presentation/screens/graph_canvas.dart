import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/data/datasources/graph_file_datasource.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/NIA_input_screen.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_list.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/graph_View.dart';
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

  GridMode _gridMode = GridMode.dotted;

  bool _speedDialOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _jsonFile = File("${widget.graphPath}/${widget.graphPath.split('/').last}.json");
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut,);
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

    } catch (e) {
      debugPrint('Error cargando grafo: $e');
    }
  }

  void _cycleGridMode() {
    setState(() {
      _gridMode = GridMode.values[
        (_gridMode.index + 1) % GridMode.values.length
      ];
      debugPrint("GridMode = $_gridMode");
    });
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

            // ___________________________________________________GRAPH CANVAS___________________________________________________
            _graph.nodes.isEmpty?
                Center(
                  child: Text(
                    'Todavía no hay nodos en este grafo',
                    style: TextStyle(color: Colors.white38, fontSize: 16.sp),
                  ),
                )
            : GraphView(gridMode: _gridMode),

            // ___________________________________________________SPEED DIAL___________________________________________________
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
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
            ),

            // ___________________________________________________GRID VIEW BUTTON___________________________________________________
            Positioned(
                top: 12.h,
                right: 12.h,
                child: FloatingActionButton.small(
                  heroTag: 'gridMode',
                  backgroundColor: bottomBar,
                  shape: CircleBorder(),
                  onPressed: (){
                    _cycleGridMode();
                  },
                  child: Icon(Icons.remove_red_eye_outlined, color: Colors.white,),
                )
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


