import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/screens/node_menu.dart';

import '../../../../consts.dart';

enum SortMode {nameAZ, nameZA}

class NodeList extends StatefulWidget {
  final String graphPath;
  const NodeList({super.key, required this.graphPath});

  @override
  State<NodeList> createState() => _NodeListState();
}

class _NodeListState extends State<NodeList> {

  List<String> _nodes = [];
  final int itemSize = 70;
  late String dirNodes = "${widget.graphPath}/nodes";
  String _search = "";
  SortMode _sortMode = SortMode.nameAZ;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final dir = Directory(dirNodes);
    if (!await dir.exists()) {
      return;
    }
    final List<String> nodes = [];

    await for(var n in dir.list()){
      if(n is File && n.path.toLowerCase().endsWith('.txt')){
        nodes.add(n.path);
      }
    }

    List<String> sortedNodes = await _sortList(nodes);

    setState((){
      _nodes = sortedNodes;
    });
  }

  Future<List<String>> _sortList(List<String> nodes) async{
    switch(_sortMode){
      case SortMode.nameAZ:
        return nodes..sort((a,b) => a.split("/").last.toLowerCase().compareTo(b.split("/").last.toLowerCase()));
      case SortMode.nameZA:
        return nodes..sort((a,b) => b.split("/").last.toLowerCase().compareTo(a.split("/").last.toLowerCase()));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final filteredNodes = _nodes.where((n) => n.split("/").last.split('.').first.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.graphPath.split('/').last, style: TextStyle(color: Colors.white),),
        backgroundColor: colorAppBar,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.manage_search),
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
                  PopupMenuButton(
                      color: mainPurple,
                      onSelected: (mode) async{
                        setState(()=>_sortMode = mode);
                        await _loadNodes();
                      },
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: button3,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Icon(Icons.sort, color: Colors.white, size: 24.r,),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: SortMode.nameAZ,
                          child: Row( children: [
                            Icon(Icons.sort_by_alpha, color: Colors.white70, size: 18.r,),
                            SizedBox(width: 5.w,),
                            Text("Nombre (A-Z)", style: TextStyle(color: Colors.white70, fontSize: 14.sp),),
                            if(_sortMode == SortMode.nameAZ) ...[
                              Spacer(),
                              Icon(Icons.check, color: mainPurple, size: 18.r,)
                            ]
                          ],),
                        ),
                        PopupMenuItem(
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
                        fillColor: button2,
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
                      //CREATE NODE and RELOAD NODE LIST
                      },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: button4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                    ),
                    icon: Icon(Icons.add, color: Colors.white, size: 24.r,),
                  ),

                ],
              )
          ),

          SizedBox(height: 15.h,),

          SizedBox(
            height: 250.h,
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              itemCount: filteredNodes.length,
              itemBuilder: (context,index){
                final node = filteredNodes[index];
                return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Expanded(
                      child: Container(
                        height: itemSize.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(color: Colors.white24, width: 2.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (c) => NodeMenu())
                                  ).then((_) => _loadNodes());
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: blackGraph2,
                                    minimumSize: Size(double.infinity, double.infinity),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.all(18.r),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12.r),
                                          bottomLeft: Radius.circular(12.r),
                                        )
                                    )
                                ),
                                child: Text(
                                  node.split("/").last.split('.').first.length > 25
                                      ? "${node.split("/").last.split('.').first.substring(0, 25)}..."
                                      : node.split("/").last.split('.').first,
                                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

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
    );
  }

}