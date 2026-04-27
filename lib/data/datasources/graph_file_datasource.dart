
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/entities/edge_entity.dart';
import '../../features/graph/presentation/widgets/file_Manager.dart';

//_________________________________________________ GESTION DE GRAFOS _________________________________________________

Future<void> createGraph(String name, String dir, File? logo) async {

  FileManager.createDirectory(dir, name);
  final String graphPath = "$dir/$name";
  FileManager.createDirectory(graphPath, "nodes");
  if (logo != null) {
    FileManager.copyImage(logo, graphPath);
  }

  NodeEntity n1 = await createNode('Bienvenido', graphPath);
  NodeEntity n2 = await createNode('Nodo Ejemplo', graphPath);
  EdgeEntity edge = await createEdge(n1, n2, 'relación ejemplo');

  final String wellcomeMessage = '''
  ¡¡¡Bienvenido a tu nuevo grafo!!! 
  
  Este es tu primer nodo de bienvenida, puedes escribir todo lo que quieras dentro de los nodos que crees.
  También puedes enlazarme con otros nodos con el botón de relaciones si quieres.
  
  Cuando estés listo edítame o bórrame y comienza a disfrutar tu nuevo grafo.
  ''';

  FileManager.writeContent(n1.filePath, wellcomeMessage);

  GraphEntity g = GraphEntity(nodes: [], edges: []);
  g.nodes.add(n1);
  g.nodes.add(n2);
  g.edges.add(edge);
  FileManager.createFile(graphPath, jsonEncode(g.toJson()), "$name.json");
}

Future<void> saveGraph (GraphEntity graph, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  await file.writeAsString(jsonEncode(graph.toJson()));
}

void deleteGraph(Directory dir){
  FileManager.deleteDirectory(dir);
}

//_________________________________________________ GESTION DE NODOS _________________________________________________

Future<NodeEntity> createNode(String name, String dir) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  final filePath = '$dir/nodes/$name.txt';

  await FileManager.createFile("$dir/nodes", "", "$name.txt");

  return NodeEntity(
      id: id,
      title: name,
      x: 1, y: 1,           //Cambiar la generación de la posición en grafo___________________________________________________________________
      filePath: filePath
  );
}

Future<void> addNode(NodeEntity node, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  final updatedGraph = GraphEntity(
      nodes: [...graph.nodes, node],
      edges: graph.edges,
  );
  await saveGraph(updatedGraph, graphPath);
}

Future<void> saveNode(NodeEntity node, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  final updatedNodes = graph.nodes.map((n) => n.id == node.id ? node : n).toList();
  final updatedGraph = GraphEntity(nodes: updatedNodes, edges: graph.edges);

  await saveGraph(updatedGraph, graphPath);
}

Future<void> deleteNode(NodeEntity node, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);
  final nodeFile = File(node.filePath);

  final updatedNodes = graph.nodes.where((n) => n.id != node.id && n.title != node.title).toList();
  final updatedEdges = graph.edges.where((e) => e.to != node.title && e.from != node.title).toList();
  final updatedGraph = GraphEntity(nodes: updatedNodes, edges: updatedEdges);

  await saveGraph(updatedGraph, graphPath);

  if(await nodeFile.exists()){
    nodeFile.delete();
  }
}

//_________________________________________________ GESTION DE ARISTAS _________________________________________________

Future<EdgeEntity> createEdge (NodeEntity origin, NodeEntity destiny, String relation) async {
  final e = EdgeEntity(from: origin.title, to: destiny.title, type: relation);
  return e;
}

Future<void> addEdge(EdgeEntity edge, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  final updatedGraph = GraphEntity(
    nodes: graph.nodes,
    edges: [...graph.edges, edge],
  );
  await saveGraph(updatedGraph, graphPath);
}

Future<void> updateEdges (NodeEntity oldNode, NodeEntity node, String graphPath) async{
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  List<EdgeEntity> updatedEdges = [];
  for(EdgeEntity e in graph.edges){
    if(e.from == oldNode.title){
      updatedEdges.add(EdgeEntity(from: node.title, to: e.to, type: e.type));
    }else if(e.to == oldNode.title){
      updatedEdges.add(EdgeEntity(from: e.from, to: node.title, type: e.type));
    } else {
      updatedEdges.add(e);
    }
  }
  final updatedGraph = GraphEntity(nodes: graph.nodes, edges: updatedEdges);

  await saveGraph(updatedGraph, graphPath);
}

Future<void> saveEdge (EdgeEntity oldEdge, EdgeEntity newEdge, String graphPath) async {
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  final updatedEdges = graph.edges.map((e) => e == oldEdge ? newEdge : e).toList();
  final updatedGraph = GraphEntity(nodes: graph.nodes, edges: updatedEdges);

  saveGraph(updatedGraph, graphPath);
}

Future<void> deleteEdge(EdgeEntity edge, String graphPath) async {
  final graphName = graphPath.split('/').last;
  final file = File('$graphPath/$graphName.json');
  final json = jsonDecode(await file.readAsString());
  final graph = GraphEntity.fromJson(json);

  for(EdgeEntity e in graph.edges){
    print(e.toJson().toString());
  }
  print("object");
  print(edge.toJson().toString());

  final updatedEdges = graph.edges.where(
          (e) => e.from != edge.from
              && e.type != edge.type
              && e.to != edge.to
  ).toList();
  final updatedGraph = GraphEntity(nodes: graph.nodes, edges: updatedEdges);
  print("object2");
  for(EdgeEntity e in updatedEdges){
    print(e.toJson().toString());
  }

  await saveGraph(updatedGraph, graphPath);
}