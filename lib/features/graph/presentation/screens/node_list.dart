import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/graph_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_menu.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/dialog_popups.dart';

import '../../../../consts.dart';
import '../../../../data/datasources/graph_file_datasource.dart';
import '../widgets/file_Manager.dart';
import '../widgets/list_button.dart';

enum SortMode {nameAZ, nameZA}

class NodeList extends StatefulWidget {
  final String graphPath;
  const NodeList({super.key, required this.graphPath});

  @override
  State<NodeList> createState() => _NodeListState();
}

class _NodeListState extends State<NodeList> {

  List<NodeEntity> _nodes = [];
  List<EdgeEntity> _edges = [];
  final double itemSize = 70;
  String _search = "";
  SortMode _sortMode = SortMode.nameAZ;
  
  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    try {
      final file = File("${widget.graphPath}/${widget.graphPath.split('/').last}.json");
      final graph = GraphEntity.fromJson(jsonDecode(await file.readAsString()));

      List<NodeEntity> sortedNodes = await _sortList(graph.nodes);

      setState((){
        _edges = graph.edges;
        _nodes = sortedNodes;
      });
    } catch (e) {
      debugPrint('Error cargando nodos: $e');
    }
  }

  Future<List<NodeEntity>> _sortList(List<NodeEntity> nodes) async{
    switch(_sortMode){
      case SortMode.nameAZ:
        return nodes..sort((a,b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.nameZA:
        return nodes..sort((a,b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }
  }

  Future<void> _nodeOptions(context, option, NodeEntity node) async{
    switch(option){
      case NodeOptions.rename:
        AppDialogs.showRenameNodeDialog(
            context,
            _nodes.map((n) => n.title).toList(),
            node.title,
                (newName) async{
              String newPath = "";
              String fileExtension = "";

              try{
                final file = File(node.filePath);
                if(await file.exists()){
                  fileExtension = file.path.split('.').last;
                  await FileManager.renameFile(file.path, "$newName.$fileExtension");
                  newPath = file.path;
                }
              }catch(e){
                debugPrint('Error cargando archivo del nodo: $e');
                return;
              }

              final renamedNode = node.copyWith(
                title: newName,
                filePath: "${newPath.substring(0, newPath.lastIndexOf('/'))}/$newName.$fileExtension",
              );
              await updateEdges(node, renamedNode, widget.graphPath);
              await saveNode(renamedNode, widget.graphPath);

              if (context.mounted) {
                await _loadNodes();
              }
            }
        );
      case NodeOptions.delete:
        AppDialogs.showDeleteNodeDialog(
            context,
            node.title,
            () async {
              await deleteNode(node, widget.graphPath);
              if(context.mounted) await _loadNodes();
            }
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    final filteredNodes = _nodes.where((n) => n.title.toLowerCase().contains(_search.toLowerCase())).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80.h,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.graphPath.split('/').last, style: TextStyle(color: Colors.white),),
              Text("Nodos: ${_nodes.length}", style: TextStyle(color: Colors.white24, fontSize: 14.sp),)
            ],
          ),
          backgroundColor: colorAppBar,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.chrome_reader_mode_outlined, size: 35.r, color: mainPurple,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),

        backgroundColor: blackGraph1,

        body: Column(
          children: [
            SizedBox(height: 15.h,),

            Padding(
                padding:  EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  children: [
                    PopupMenuButton<SortMode>(
                        color: mainPurple,
                        onSelected: (mode) async{
                          setState(()=>_sortMode = mode);
                          await _loadNodes();
                        },
                        child: Container(
                          width: 53.r,
                          height: 53.r,
                          decoration: BoxDecoration(
                            color: button4,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Icon(Icons.sort, color: Colors.white, size: 24.r,),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<SortMode>(
                            value: SortMode.nameAZ,
                            child: Row( children: [
                              Icon(Icons.sort_by_alpha, color: Colors.white70, size: 18.r,),
                              SizedBox(width: 5.w,),
                              Text("Nombre (A-Z)", style: TextStyle(color: Colors.white70, fontSize: 14.sp),),
                              if(_sortMode == SortMode.nameAZ) ...[
                                Spacer(),
                                Icon(Icons.check, color: Colors.white, size: 18.r,)
                              ]
                            ],),
                          ),

                          PopupMenuDivider(color: Colors.white24, thickness: 2.h, height: 1.h,),

                          PopupMenuItem<SortMode>(
                            value: SortMode.nameZA,
                            child: Row( children: [
                              Icon(Icons.sort_by_alpha, color: Colors.white70, size: 18.r,),
                              SizedBox(width: 5.w,),
                              Text("Nombre (Z-A)", style: TextStyle(color: Colors.white70, fontSize: 14.sp),),
                              if(_sortMode == SortMode.nameZA) ...[
                                Spacer(),
                                Icon(Icons.check, color: mainPurple, size: 18.r,)
                              ]
                            ],),
                          ),
                        ]
                    ),

                    SizedBox(width: 5.w,),

                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _search = value);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText: "Buscar nodo...",
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 16.sp),
                          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20.r),
                          filled: true,
                          fillColor: blackGraph3,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
                        ),
                      ),
                    ),

                    SizedBox(width: 5.w,),

                    IconButton(
                      onPressed: () async {
                        AppDialogs.showCreateNodeDialog(
                            context,
                            _nodes.map((n) => n.title).toList(),
                            (nodeName, nodeContent)async{
                              final n = await createNode(nodeName, widget.graphPath );
                              await addNode(n, widget.graphPath);
                              if (nodeContent.isNotEmpty) {
                                FileManager.writeContent(n.filePath, nodeContent);
                              }
                              await _loadNodes();
                            }
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: blackGraph2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                      ),
                      icon: Icon(Icons.add_circle, color: mainPurple, size: 36.r),
                      tooltip: "Añadir nodo",
                    ),

                  ],
                )
            ),

            SizedBox(height: 15.h,),

            Expanded(
                    child: _nodes.isEmpty ?
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Todavía no hay nodos en este grafo\nPulsa + para añadir uno nuevo',
                        style: TextStyle(color: Colors.white38, fontSize: 16.sp),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 50.w),
                      itemCount: filteredNodes.length,
                      itemBuilder: (context,index){
                        final node = filteredNodes[index];
                        final nOrigin = _edges.where((e) => e.from == node.title).length;
                        final nDestiny = _edges.where((e) => e.to == node.title).length;
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => NodeMenu(
                                  node: node,
                                  graphPath: widget.graphPath,)
                                )
                            ).then((_) async => await _loadNodes());
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: blackGraph2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                              ),
                              builder: (_) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(node.title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                        Text(
                                          nOrigin > 0 || nDestiny > 0 ? "Origen: $nOrigin | Destino: $nDestiny" : "Sin relaciones",
                                          style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.white12),
                                  ListTile(
                                    leading: Icon(Icons.edit, color: Colors.white),
                                    title: Text("Renombrar", style: TextStyle(color: Colors.white)),
                                    onTap: () { Navigator.pop(context); _nodeOptions(context, NodeOptions.rename, node); },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                    onTap: () { Navigator.pop(context); _nodeOptions(context, NodeOptions.delete, node); },
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            );
                          },
                          child: ListButton(
                            name: node.title.length > 25
                                ? "${node.title.substring(0, 25)}..."
                                : node.title,
                            appendix: nOrigin > 0 || nDestiny > 0 ?
                            "Origen: $nOrigin | Destino: $nDestiny"
                                : "Sin relaciones",
                            height: itemSize,
                            fillColor: blackGraph2,
                          ),
                        );
                      },
                    ),
                  ),

            SizedBox(height:15.h,),
          ],
        ),
      ),
    );
  }

}