import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/graph_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/widget_buttons.dart';

import '../../../../consts.dart';
import '../../../../domain/entities/edge_entity.dart';

List<String> titles = <String>['Contenido', 'Relaciones'];

class NodeMenu extends StatefulWidget {
  final String nodePath;
  final String graphJson;
  const NodeMenu({super.key, required this.nodePath, required this.graphJson});

  @override
  State<NodeMenu> createState() => _NodeMenuState();
}

class _NodeMenuState extends State<NodeMenu> {

  String _nodeName = "";
  String _fileContent = "Cargando...";
  late File _file;
  late GraphEntity _graph;
  List<EdgeEntity> _originEdges = [];
  List<EdgeEntity> _destinationEdges = [];

  @override
  void initState() {
    super.initState();
    _nodeName = widget.nodePath.split('/').last.split('.').first;
    _loadFile();
    _loadGraph();
  }

  Future<void> _loadGraph() async{
    try {
      final String jsonContent;
      final file = File(widget.graphJson);
      jsonContent = await file.readAsString();

      final graph = GraphEntity.fromJson(jsonDecode(jsonContent));

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
    _file = File(widget.nodePath);

    if(await _file.exists()){
      final content = await _file.readAsString();
      setState(() => _fileContent = content);
    }else{
      setState(() => _fileContent = "Error: Error de lectura o archivo inexistente. \n ${_file.path}");
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
            title: Text(widget.nodePath.split('/').last.split('.').first, style: TextStyle(color: Colors.white),),
            backgroundColor: colorAppBar,
            iconTheme: IconThemeData(color: Colors.white),
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
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
                            child: Text(
                              _fileContent,
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ),


                      SizedBox(height: 5.sp),

                      ElevatedButton(
                        onPressed: () async {

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bottomBar,
                          elevation: 0,
                          minimumSize: Size(double.infinity, 50.r),
                          padding: EdgeInsets.all(10.r),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                        ),
                        child: Text("Modificar", style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ),
                // ________________ RELACIONES NODO ________________
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 10.h),
                  child: Column(
                    children: [

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
                                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Relaciones destino a:",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(Icons.add_circle, color: mainPurple, size: 32.r),
                                        tooltip: "Añadir relación",
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5.sp),

                                Expanded(
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    itemCount: _originEdges.length,
                                    itemBuilder: (context,index){
                                      final edge = _originEdges[index];
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (c) => NodeMenu(
                                                  nodePath: "${_graph.nodes.where((n) => n.title == edge.to).first.filePath}/${edge.to}.txt",
                                                  graphJson: widget.graphJson)),
                                          );
                                        },
                                        child: EdgeButton(edgeName: edge.to, edgeType: edge.type, height: itemSize),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),

                      SizedBox(height: 5.sp),

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
                                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Relaciones origen en:",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(Icons.add_circle, color: mainPurple, size: 32.r),
                                        tooltip: "Añadir relación",
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5.sp),

                                Expanded(
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    itemCount: _destinationEdges.length,
                                    itemBuilder: (context,index){
                                      final edge = _destinationEdges[index];
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (c) => NodeMenu(
                                                nodePath: "${_graph.nodes.where((n) => n.title == edge.from).first.filePath}/${edge.from}.txt",
                                                graphJson: widget.graphJson)),
                                          );
                                        },
                                        child: EdgeButton(edgeName: edge.from, edgeType: edge.type, height: itemSize),
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
