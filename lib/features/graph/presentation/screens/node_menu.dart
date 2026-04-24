import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/data/datasources/graph_file_datasource.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/graph_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/file_Manager.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/widget_buttons.dart';

import '../../../../consts.dart';
import '../../../../domain/entities/edge_entity.dart';

List<String> titles = <String>['Contenido', 'Relaciones'];
enum NodeOptions {rename, delete}

class NodeMenu extends StatefulWidget {
  final NodeEntity node;
  final String graphPath;
  const NodeMenu({super.key, required this.node, required this.graphPath});

  @override
  State<NodeMenu> createState() => _NodeMenuState();
}

class _NodeMenuState extends State<NodeMenu> {

  String _nodeName = "";
  bool _isEditingContent = false;
  late File _file;
  GraphEntity _graph = GraphEntity(nodes: [], edges: []);
  List<EdgeEntity> _originEdges = [];
  List<EdgeEntity> _destinationEdges = [];

  final TextEditingController _nodeContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nodeContentController.text = "Cargando ...";
    _isEditingContent = false;
    _nodeName = widget.node.title;
    _loadFile();
    _loadGraph();
  }

  Future<void> _loadGraph() async{
    try {
      final file = File("${widget.graphPath}/${widget.graphPath.split('/').last}.json");
      final graph = GraphEntity.fromJson(jsonDecode(await file.readAsString()));

      setState(() {
        _graph = graph;
        _originEdges = graph.edges.where((e) => e.from == _nodeName).toList();
        _destinationEdges = graph.edges.where((e) => e.to == _nodeName).toList();
      });

    } catch (e) {
      debugPrint('Error cargando grafo: $e');
    }
  }

  Future<void> _loadFile() async {
    try {
      _file = File(widget.node.filePath);

      if(await _file.exists()){
        final content = await _file.readAsString();
        setState(() => _nodeContentController.text = content);
      }else{
        setState(() => _nodeContentController.text = "Error: Error de lectura o archivo inexistente. \n ${_file.path}");
      }
    } catch (e) {
      debugPrint('Error cargando nodo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    const int tabsCount = 2;
    final double itemSize = 70;

    return DefaultTabController(
      initialIndex: 0,
        length: tabsCount,
        child: Scaffold(
          backgroundColor: blackGraph1,
          appBar: AppBar(
            toolbarHeight: 80.h,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.node.title, style: TextStyle(color: Colors.white),),
                Text(
                   _originEdges.isNotEmpty || _destinationEdges.isNotEmpty ?
                    "Origen: ${_originEdges.length} | Destino: ${_destinationEdges.length}"
                    : "Sin relaciones",
                  style: TextStyle(color: Colors.white24, fontSize: 14.sp),)
              ]),
            backgroundColor: colorAppBar,
            iconTheme: IconThemeData(color: Colors.white),
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
            actions: [
              PopupMenuButton<NodeOptions>(
                  color: mainPurple,
                  icon: Icon(Icons.settings, size: 30.r,),
                  onSelected: (option) async{
                    switch(option){
                      case NodeOptions.rename:
                        AppDialogs.showRenameNodeDialog(
                            context,
                            _graph.nodes.toList(),
                            widget.node,
                            (newName) async{
                              final fileExtension = _file.path.split('.').last;
                              await FileManager.renameFile(_file.path, "$newName.$fileExtension");
                              final renamedNode = NodeEntity(
                                  id: widget.node.id,
                                  title: newName,
                                  x: widget.node.x, y: widget.node.y,
                                  filePath: "${_file.path.substring(0,_file.path.lastIndexOf('/'))}/$newName.$fileExtension"
                              );
                              await updateEdges(widget.node, renamedNode, widget.graphPath);
                              await saveNode(renamedNode, widget.graphPath);

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (c) => NodeMenu(
                                    node: renamedNode,
                                    graphPath: widget.graphPath,
                                  )),
                                );
                              }
                            }
                            );
                      case NodeOptions.delete:
                        AppDialogs.showDeleteNodeDialog(
                            context,
                            widget.node,
                            () async {

                              await deleteNode(widget.node, widget.graphPath);
                              if(context.mounted) Navigator.pop(context);

                            }
                        );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<NodeOptions>(
                      value: NodeOptions.rename,
                      child: Row( children: [
                        Icon(Icons.edit, color: Colors.white, size: 22.r,),
                        SizedBox(width: 5.w,),
                        Text("Renombrar", style: TextStyle(color: Colors.white, fontSize: 14.sp),),
                      ],),
                    ),
                    PopupMenuItem<NodeOptions>(
                      value: NodeOptions.delete,
                      child: Row( children: [
                        Icon(Icons.delete, color: Colors.white, size: 22.r,),
                        SizedBox(width: 5.w,),
                        Text("Eliminar", style: TextStyle(color: Colors.white, fontSize: 14.sp),),
                      ],),
                    ),
                  ]),
              SizedBox(width: 15.w,),
            ],
            bottom: TabBar(
                labelColor: mainPurple,
                unselectedLabelColor: Colors.white24,
                dividerColor: Colors.transparent,
                tabs: <Widget>[
                  Tab(icon: const Icon(Icons.library_books), text: titles[0],),
                  Tab(icon: const Icon(Icons.device_hub), text: titles[1],),
                ]
            ),
          ),

          body: TabBarView(
              children: <Widget>[

                // ________________ CONTENIDO NODO ________________

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.r),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: Colors.white24, width: 2.w),
                            color: blackGraph2
                          ),
                          child: SingleChildScrollView(
                            child: TextField(
                              controller: _nodeContentController,
                              enabled: _isEditingContent,
                              minLines: 1,
                              maxLines: null,
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                filled: false,
                                hintText: "Nodo vacío.\nPulsa editar para escribir contenido...",
                                hintStyle: TextStyle(color: Colors.white24, fontSize: 15.sp),
                              ),
                            ),
                          ),
                        ),
                      ),


                      SizedBox(height: 5.sp),

                      ElevatedButton(
                        onPressed: () async {
                          if(_isEditingContent){
                            FileManager.writeContent(widget.node.filePath, _nodeContentController.text);
                          }
                          setState(() => _isEditingContent = !_isEditingContent);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEditingContent? mainPurple : colorAppBar,
                          elevation: 0,
                          minimumSize: Size(double.infinity, 50.r),
                          padding: EdgeInsets.all(10.r),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                        ),
                        child: _isEditingContent ?
                            Text("Guardar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold))
                            : Text("Editar texto", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold))
                      ),
                    ],
                  )
                ),

                // ________________ RELACIONES NODO ________________

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 10.h),
                  child: Column(
                    children: [

                      // ________________ RELACIONES ORIGEN ________________
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(color: Colors.white24, width: 2.w),
                                color: blackGraph2
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.arrow_circle_right_outlined, color: mainPurple, size: 32.r,),
                                      SizedBox(width: 5.w,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Origen (salientes):",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Este nodo apunta a:",
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(Icons.add_circle, color: mainPurple, size: 32.r),
                                        tooltip: "Añadir relación saliente",
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5.sp),

                                Expanded(
                                child: _originEdges.isEmpty ?
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Este nodo no apunta a nadie',
                                    style: TextStyle(color: mainPurple, fontSize: 15.sp),
                                  ),
                                )
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    itemCount: _originEdges.length,
                                    itemBuilder: (context,index){
                                      final edge = _originEdges[index];
                                      return GestureDetector(
                                        onTap: (){
                                          try {
                                            final node = _graph.nodes.firstWhere((n) => n.title == edge.to);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (c) => NodeMenu(
                                                  node: node,
                                                  graphPath: widget.graphPath)),
                                            );
                                          } catch (e) {
                                            debugPrint('Nodo destino no encontrado: ${edge.from}');
                                          }
                                        },
                                        child: ListButton(name: edge.to, appendix: "Tipo: ${edge.type}", height: itemSize, fillColor: blackGraph3,),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),

                      SizedBox(height: 5.sp),

                      // ________________ RELACIONES DESTINO ________________
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(color: Colors.white24, width: 2.w),
                              color: blackGraph2
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.arrow_circle_left_outlined, color: mainGreen, size: 32.r,),
                                      SizedBox(width: 5.w,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Destino (entrantes):",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Este nodo es apuntado por:",
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(Icons.add_circle, color: mainGreen, size: 32.r),
                                        tooltip: "Añadir relación entrante",
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5.sp),

                                Expanded(
                                  child: _destinationEdges.isEmpty ?
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Nadie apunta a este nodo',
                                      style: TextStyle(color: mainGreen, fontSize: 15.sp),
                                    ),
                                  )
                                  :ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    itemCount: _destinationEdges.length,
                                    itemBuilder: (context,index){
                                      final edge = _destinationEdges[index];
                                      return GestureDetector(
                                        onTap: (){
                                          try {
                                            final node = _graph.nodes.firstWhere((n) => n.title == edge.from);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (c) => NodeMenu(
                                                  node: node,
                                                  graphPath: widget.graphPath)),
                                            );
                                          } catch (e) {
                                            debugPrint('Nodo origen no encontrado: ${edge.from}');
                                          }
                                        },
                                        child: ListButton(name: edge.from, appendix: "Tipo: ${edge.type}", height: itemSize, fillColor: blackGraph3,),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),

                    ],
                  ),
                ),
              ]
          ),
        )
    );
  }
}
