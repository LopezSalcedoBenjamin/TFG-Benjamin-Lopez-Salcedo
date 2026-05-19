import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:http/http.dart' as http;
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';

import '../widgets/dialog_popups.dart';
import '../widgets/list_button.dart';

const String _baseUrl = 'http://localhost:8000';
enum NiaState {processing, completed}
enum CharacterOptions {rename, fuse, delete}
enum RelationOptions {modify, delete}

List<String> titles = <String>['Personajes', 'Relaciones'];

class NiaOutputScreen extends StatefulWidget {
  final String inputText;
  final List<String> existingNodes;
  const NiaOutputScreen({super.key, required this.inputText, required this.existingNodes});

  @override
  State<NiaOutputScreen> createState() => _NiaOutputScreenState();
}

class _NiaOutputScreenState extends State<NiaOutputScreen> {

  NiaState _state = NiaState.processing;

  StreamSubscription? _sub;
  String _phase = 'Iniciando análisis...';
  bool _error = false;
  double _progress = 0.0;
  int _actualChunk = 0;
  int _totalChunks = 0;

  List<Map<String, dynamic>> _nodes = [];
  List<Map<String, dynamic>> _edges = [];
  List<String> _allNodeNames = [];

  @override
  void initState() {
    super.initState();
    _loadNodes();
    _startProcessing();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startProcessing() async{
    try{
      final request = http.Request('POST', Uri.parse('$_baseUrl/procesar_stream'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'historia': widget.inputText});

      final response = await http.Client().send(request);
      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

      _sub = stream.listen(
          (linea) {
            if(!linea.startsWith('data: ')) return;

            final event = jsonDecode(linea.substring(6)) as Map<String, dynamic>;

            setState(() {
              switch (event['tipo']){
                case 'progreso':
                  _actualChunk = event['chunk'];
                  _totalChunks = event['total'];
                  _progress = (event['valor'] as int) / 100.0;
                  _phase = "Analizando chunks...";

                case 'fase':
                  _phase = event['mensaje'];

                case 'resultado':
                  _nodes = List<Map<String, dynamic>>.from(event['datos']['nodes']);
                  _edges = List<Map<String, dynamic>>.from(event['datos']['edges']);
                  _state = NiaState.completed;
              }
            });
          },
        onError: (e){
            setState(() {
              _error = true;
              _phase = "Error de conexión con el servidor: $e";
            });
        },
      );
    }catch(e){
      setState(() {
        _error = true;
        _phase = "No se pudo conectar: $e";
      });
    }
  }

  Future<void> _characterResultOptions(context, node, option) async{
    switch(option){
      case CharacterOptions.rename:
        AppDialogs.showRenameNodeDialog(
            context,
            _nodes.map((n) => n['title'].toString()).toList(),
            node['title'],
            (newName){
              _renameNode(node['title'], newName);
              _loadNodes();
            }
        );
      case CharacterOptions.fuse:
        AppDialogs.showFuseNodeDialog(
            context,
            node['title'],
            _allNodeNames,
            widget.existingNodes,
            (targetName){
              _fuseNode(node, targetName);
              _loadNodes();
            }
        );

      case CharacterOptions.delete:
        AppDialogs.showDeleteNodeDialog(
            context,
            node['title'],
            (){
              _deleteNodes(node);
              _loadNodes();
            }
        );

    }
  }

  Future<void> _relationResultOptions(context, edge, option) async{
    switch(option){
      case RelationOptions.modify:
        AppDialogs.showModifyEdgeDialog(
            context,
            _edges.map((e) => EdgeEntity.fromJson(e)).toList(),
            EdgeEntity.fromJson(edge),
            (newType){
              setState(() {
                edge['type'] = newType;
              });
            }
        );
      case RelationOptions.delete:
        AppDialogs.showDeleteEdgeDialog(
            context,
            EdgeEntity(from: edge['node1'], to: edge['node2'], type: edge['type']),
            (){
              setState(() {
                _edges.removeWhere((e) =>
                e['node1'] == edge['node1'] &&
                    e['node2'] == edge['node2'] &&
                    e['type'] == edge['type']
                );
              });
              _loadNodes();
            }
        );
    }
  }

  void _loadNodes(){
    try{
      setState(() {
        _allNodeNames = {...widget.existingNodes, ..._nodes.map((n) => n['title'].toString())}.toList();
      });
    }catch(e){
      debugPrint('Error cargando nodos: $e');
    }
  }

  Future<void> _renameNode(String oldName, String newName) async{
    setState(() {
      for (var n in _nodes) {
        if (n['title'] == oldName) n['title'] = newName;
      }
      for (var e in _edges) {
        if (e['node1'] == oldName) e['node1'] = newName;
        if (e['node2'] == oldName) e['node2'] = newName;
      }
    });
  }

  Future<void> _fuseNode(Map<String, dynamic> node, String targetName) async{

    final currentName = node['title'];
    final targetExists = widget.existingNodes.contains(targetName);
    final targetInList = _nodes.map((n) => n['title']).toList().contains(targetName);
    final survivorNode = targetExists ? targetName : currentName;
    final absorbedNode = targetExists ? currentName : targetName;

    setState(() {

      for (var e in _edges) {
        if (e['node1'] == absorbedNode) e['node1'] = survivorNode;
        if (e['node2'] == absorbedNode) e['node2'] = survivorNode;
      }

      if(!targetInList) _nodes.add({'id': node['id'], 'title': targetName});

      _nodes.removeWhere((n) => n['title'] == absorbedNode);
      _edges.removeWhere((e) => e['node1'] == e['node2']);
    });
  }

  Future<void> _deleteNodes(node) async{
    setState(() {
      _nodes.removeWhere((n) => n['title'] == node['title']);
      _edges.removeWhere((e) =>
          e['node1'] == node['title'] ||
          e['node2'] == node['title']
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_state == NiaState.processing){
      return _buildProcessing();
    }
    return _buildCompleted();
  }

  Widget _buildProcessing(){
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor: colorAppBar,
        toolbarHeight: 80.h,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Procesando texto...",
                style: TextStyle(color: Colors.white)
            ),
            Text("NIA está analizando tu historia",
                style: TextStyle(color: Colors.white24, fontSize: 14.sp)
            )
          ],
        ),
      ),

      backgroundColor: blackGraph1,

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Image.asset("assets/icons/NIA_button.png", height: 80.h, width: 80.w),
              SizedBox(height: 32.h),

              // Porcentaje
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4.h),

              // Chunks — solo aparece cuando hay datos
              if (_totalChunks > 0)
                Text(
                  'Fragmento $_actualChunk de $_totalChunks',
                  style: TextStyle(color: Colors.white24, fontSize: 13.sp),
                ),

              SizedBox(height: 20.h),

              // Barra de progreso
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: _error
                        ? (_progress == 0.0 ? 0.05 : _progress)
                        : (_progress == 0.0 ? null : _progress),
                    minHeight: 8.h,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      _error
                          ? Colors.red
                          : (_progress == 1 ? mainGreen : mainPurple),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Fase — texto descriptivo
              Text(
                _phase,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14.sp),
              ),

              SizedBox(height: 48.h),

              // Botón cancelar o volver según si hay error
              if (!_error)
                TextButton(
                  onPressed: () {
                    _sub?.cancel();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: mainPurple),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white24, fontSize: 13.sp),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Volver', style: TextStyle(color: Colors.white),),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleted(){

    const int tabsCount = 2;
    final double itemSize = 60;

    return DefaultTabController(
        length: tabsCount,
        child:  Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: colorAppBar,
            toolbarHeight: 80.h,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Resultados NIA",
                    style: TextStyle(color: Colors.white)
                ),
                Text("Nodos: ${_nodes.length} | Relaciones: ${_edges.length}",
                    style: TextStyle(color: Colors.white24, fontSize: 14.sp)
                )
              ],
            ),
            bottom: TabBar(
                labelColor: mainPurple,
                unselectedLabelColor: Colors.white24,
                dividerColor: Colors.transparent,
                tabs: <Widget>[
                  Tab(icon: const Icon(Icons.person), text: titles[0],),
                  Tab(icon: const Icon(Icons.link), text: titles[1],),
                ]
            ),
          ),

          backgroundColor: blackGraph1,

          body: TabBarView(
            children: [
              // Tab 1 — Personajes
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: Colors.white24, width: 2.w),
                      color: blackGraph2
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.r), topRight: Radius.circular(13.r)),
                          color: mainPurple,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10.w,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Personajes obtenidos:",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Revisa los personajes:",
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 1.h,),

                      Divider(
                        color: Colors.white24,
                        thickness: 2,
                        height: 1,
                      ),

                      SizedBox(height: 10.h,),

                      Expanded(
                        child: _nodes.isEmpty ?
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Algo salió mal\n No se encontraron personajes',
                            style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                          ),
                        )
                            : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: _nodes.length,
                          itemBuilder: (context,index){
                            final node = _nodes[index];
                            final alreadyExists = widget.existingNodes.contains(node['title']);
                            return ListButton(
                              name: node['title'].toString(),
                              appendix: alreadyExists ? "• Ya existe en el grafo" : "id: ${node['id']}",
                              height: itemSize,
                              fillColor: blackGraph3,
                              apendixColor: alreadyExists ? mainGreen : Colors.white54,
                              trailing: IconButton(
                                icon: Icon(Icons.edit, color: Colors.white38, size: 22.r,),
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  backgroundColor: blackGraph2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                  ),
                                  builder: (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 20.h),
                                      ListTile(
                                        leading: Icon(Icons.edit, color: Colors.white),
                                        title: Text("Renombrar", style: TextStyle(color: Colors.white)),
                                        onTap: () { Navigator.pop(context); _characterResultOptions(context, node, CharacterOptions.rename); },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.merge, color: Colors.white),
                                        title: Text("Fusionar", style: TextStyle(color: Colors.white)),
                                        onTap: () { Navigator.pop(context); _characterResultOptions(context, node, CharacterOptions.fuse); },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                        onTap: () { Navigator.pop(context); _characterResultOptions(context, node, CharacterOptions.delete); },
                                      ),
                                      SizedBox(height: 20.h),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab 2 — Relaciones
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: Colors.white24, width: 2.w),
                      color: blackGraph2
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(13.r), topRight: Radius.circular(13.r)),
                          color: mainGreen,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10.w,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Relaciones obtenidas:",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Revisa las relaciones:",
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 1.h,),

                      Divider(
                        color: Colors.white24,
                        thickness: 2,
                        height: 1,
                      ),

                      SizedBox(height: 10.h,),

                      Expanded(
                        child: _edges.isEmpty ?
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Algo salió mal\n No se encontraron relaciones',
                            style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                          ),
                        )
                            : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: _edges.length,
                          itemBuilder: (context,index){
                            final edge = _edges[index];
                            return ListButton(
                              name: edge['type'].toString(),
                              appendix: "${edge['node1']}  ›  ${edge['node2']}",
                              height: itemSize,
                              fillColor: blackGraph3,
                              trailing: IconButton(
                                icon: Icon(Icons.edit, color: Colors.white38, size: 22.r,),
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  backgroundColor: blackGraph2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                  ),
                                  builder: (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 20.h),
                                      ListTile(
                                        leading: Icon(Icons.edit, color: Colors.white),
                                        title: Text("Cambiar tipo", style: TextStyle(color: Colors.white)),
                                        onTap: () { Navigator.pop(context); _relationResultOptions(context, edge, RelationOptions.modify); },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                        onTap: () { Navigator.pop(context); _relationResultOptions(context, edge, RelationOptions.delete); },
                                      ),
                                      SizedBox(height: 20.h),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'nodes': _nodes,
                    'edges': _edges,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: Text(
                  'Añadir al grafo',
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        )
    );
  }
}
