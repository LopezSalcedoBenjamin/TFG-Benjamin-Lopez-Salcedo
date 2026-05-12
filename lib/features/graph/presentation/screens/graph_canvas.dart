import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/data/datasources/graph_file_datasource.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/data/datasources/graph_layout.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/NIA_input_screen.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_list.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/graph_View.dart';

import '../../../../domain/entities/graph_entity.dart';
import '../../../../domain/entities/node_entity.dart';
import 'node_menu.dart';

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

  final TransformationController _transformController = TransformationController();
  GridMode _gridMode = GridMode.dotted;
  Map<String, Offset> _positions = {};
  bool _isReloading = false;

  bool _speedDialOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _jsonFile = File("${widget.graphPath}/${widget.graphPath.split('/').last}.json");
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut,);

    WidgetsBinding.instance.addPostFrameCallback((_){
      final screenSize = MediaQuery.of(context).size;
      final double dx = -(canvasWidth/2 - screenSize.width/2);
      final double dy = -(canvasHeight/2 - screenSize.height/2);

      _transformController.value = Matrix4.translationValues(dx,dy,0);
    });

    _loadGridMode();
    _loadGraph();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformController.dispose();
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
      final file = _jsonFile;
      final jsonContent = await file.readAsString();
      final graph = GraphEntity.fromJson(jsonDecode(jsonContent));

      final positions = calcularLayout(graph.nodes, graph.edges);

      for(final node in graph.nodes){
        if(node.x == 1.0 && node.y == 1.0){
          final pos = positions[node.id]!;
          final updatedNode = node.copyWith(x: pos.dx, y: pos.dy);
          await saveNode(updatedNode, widget.graphPath);
        }
      }

      final updatedContent = await file.readAsString();
      final updatedGraph = GraphEntity.fromJson(jsonDecode(updatedContent));

      _positions.forEach((id, offset) {
        debugPrint('Nodo $id → $offset');
      });

      setState(() {
        _graph = updatedGraph;
        _nodeList = updatedGraph.nodes;
        _edgeList = updatedGraph.edges;
        _positions = positions;
      });

    } catch (e) {
      debugPrint('Error cargando grafo: $e');
    }
  }

  Future<void> _reloadPositions() async {
    if(_isReloading) return;
    _isReloading = true;
    try {
      final file = _jsonFile;
      final jsonContent = await file.readAsString();
      final graph = GraphEntity.fromJson(jsonDecode(jsonContent));

      final positions = calcularLayout(graph.nodes, graph.edges, recalculate: true);

      for (final node in graph.nodes) {
        final pos = positions[node.id]!;
        final updatedNode = node.copyWith(x: pos.dx, y: pos.dy);
        await saveNode(updatedNode, widget.graphPath);
      }

      final updatedContent = await file.readAsString();
      final updatedGraph = GraphEntity.fromJson(jsonDecode(updatedContent));

      _positions.forEach((id, offset) {
        debugPrint('Nodo $id → $offset');
      });

      setState(() {
        _graph = updatedGraph;
        _nodeList = updatedGraph.nodes;
        _edgeList = updatedGraph.edges;
        _positions = positions;
      });
    } catch (e) {
      debugPrint('Error recargando grafo: $e');
    } finally {
      _isReloading = false;
    }
  }

  void _cycleGridMode() {
    setState(() {
      _gridMode = GridMode.values[
        (_gridMode.index + 1) % GridMode.values.length
      ];
      FileManager.saveGridMode(widget.graphPath, _gridMode.name);
      debugPrint("GridMode = $_gridMode");
    });
  }

  Future<void> _loadGridMode() async {
    final modeString = await FileManager.getGridMode(widget.graphPath);
    setState(() {
      _gridMode = GridMode.values.firstWhere((e) => e.name == modeString, orElse: () => GridMode.dotted);
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
              ).then((_) async => await _loadGraph());
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _reloadPositions();
                },
              icon: Icon(Icons.refresh, color: Colors.white,),
              tooltip: "recargar grafo",
            ),

            SizedBox(width: 15.w,)
          ],
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
            : GraphView(
              gridMode: _gridMode,
              transformationController: _transformController,
              graph: _graph,
              positions: _positions,
              onNodeTap: (node){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => NodeMenu(
                      node: node,
                      graphPath: widget.graphPath,)
                    ),
                ).then((_) async => await _loadGraph());
              } ,
            ),

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
                            await _loadGraph();
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
                          _nodeList.map((n) => n.title).toList(),
                              (nodeName, nodeContent) async {
                            final n = await createNode(nodeName, widget.graphPath );
                            await addNode(n, widget.graphPath);
                            if (nodeContent.isNotEmpty) {
                              FileManager.writeContent(n.filePath, nodeContent);
                            }
                            await _loadGraph();
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
            ),

            // ___________________________________________________GRID VIEW BUTTONS___________________________________________________
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
                          MaterialPageRoute(builder: (c) => NiaInputScreen(
                              existingNodes: _graph.nodes.map((n) => n.title).toList())
                          )
                      ).then((outputNIA) async {
                        if(outputNIA == null) return;
                        if(!mounted) return;
                        final newNodes = List<Map<String,dynamic>>.from(outputNIA['nodes']);
                        final newEdges = List<Map<String,dynamic>>.from(outputNIA['edges']);
                        await fuseGraphNIA(widget.graphPath, newNodes, newEdges);
                        await _loadGraph();
                      });
                    },
                    child: Image.asset("assets/icons/NIA_button.png")
                ),

                SizedBox(width: 64.w),

                InkWell(
                  onTap: () async {
                    AppDialogs.showSearchInGraph(
                        context,
                        _nodeList,
                        (id){
                          final pos = _positions[id]!;
                          final screenSize = MediaQuery.of(context).size;

                          final double dx = -(pos.dx - screenSize.width / 2);
                          final double dy = -(pos.dy - screenSize.height / 2);

                          _transformController.value = Matrix4.translationValues(dx, dy, 0);
                        }
                    );
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


