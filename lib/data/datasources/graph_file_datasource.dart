
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/entities/edge_entity.dart';
import '../../features/graph/presentation/widgets/file_Manager.dart';

Future<void> createGraph(String name, String dir, File? logo) async {

  FileManager.createDirectory(dir, name);
  final String graphPath = "$dir/$name";
  FileManager.createDirectory(graphPath, "nodes");
  if (logo != null) {
    FileManager.copyImage(logo, graphPath);
  }

  NodeEntity n1 = await createNode('Bienvenido', graphPath);
  NodeEntity n2 = await createNode('Nodo Ejemplo', graphPath);
  EdgeEntity edge = await createEdge(n1, n2, 'tipo relación');

  final String wellcomeMessage = '''
  ¡¡¡Bienvenido a tu nuevo grafo!!! 
  
  Este es tu primer nodo de bienvenida, puedes escribir todo lo que quieras dentro de los nodos que crees.
  También puedes enlazarme con otros nodos con el botón de relaciones si quieres.
  
  Cuando estés listo edítame o bórrame y comienza a disfrutar tu nuevo grafo.
  ''';
  /*
  *   FileManager.createFile(n1.title, wellcomeMessage, "${n1.title}.txt");
  *   FileManager.createFile(n2.title, "", "${n2.title}.txt");
  * */

  FileManager.createFile(n1.filePath, wellcomeMessage, "${n1.title}.txt");
  FileManager.createFile(n2.filePath, "", "${n2.title}.txt");

  GraphEntity g = GraphEntity(nodes: [], edges: []);
  g.nodes.add(n1);
  g.nodes.add(n2);
  g.edges.add(edge);
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

Future<EdgeEntity> createEdge (NodeEntity origin, NodeEntity destiny, String relation) async {
  final e = EdgeEntity(from: origin.title, to: destiny.title, type: relation);
  return e;
}

void saveEdge (){}

void deleteEdge(){}