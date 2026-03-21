
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/entities/edge_entity.dart';
import '../../features/graph/presentation/widgets/file_Manager.dart';

Future<void> createGraph(String name, String dir, File? logo) async {

  FileManager.createFolder(dir, name);
  final String graphPath = "$dir/$name";
  FileManager.createFolder(graphPath, "nodes");
  if (logo != null) {
    FileManager.copyImage(logo, graphPath);
  }

  GraphEntity g = GraphEntity(nodes: [], edges: []);
  FileManager.createFile(graphPath, jsonEncode(g.toJson()), "$name.json");
}

void saveGraph (GraphEntity g){

}

void deleteGraph(Directory dir){
  FileManager.deleteDirectory(dir);
}

Future<NodeEntity> createNode(String name, String dir) async {

  final id = DateTime.now().millisecondsSinceEpoch.toString();
  final nodePath = '$dir/nodes';

  FileManager.createFile(nodePath, "", "$name.txt");

  final n = NodeEntity(
      id: id,
      title: name,
      x: 1, y: 1,           //Cambiar la generación de la posición en grafo
      filePath: nodePath
  );

  return n;
}

void saveNode (){}

void deleteNode(){}

void createEdge (){}

void saveEdge (){}

void deleteEdge(){}