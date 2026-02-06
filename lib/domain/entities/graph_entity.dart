import 'dart:convert';

import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';

class GraphEntity {
  final List<NodeEntity> nodes;
  final List<EdgeEntity> edges;

  GraphEntity({
    required this.nodes,
    required this.edges,
  });

  Map<String, dynamic> toJson(){
    return{
      'nodes' : nodes.map((n) => n.toJson()).toList(),
      'edges' : edges.map((n) => n.toJson()).toList(),
    };
  }

  factory GraphEntity.fromJson(Map<String, dynamic> json){
    return GraphEntity(
        nodes: (json['nodes'] as List).map((n) => NodeEntity.fromJson(n)).toList(),
        edges: (json['edges'] as List).map((n) => EdgeEntity.fromJson(n)).toList(),
    );
  }
}

void main (){

  NodeEntity n = new NodeEntity(id: 'A1', title: 'hola', x: 2, y: 2, filePath: 'a/a');
  NodeEntity n2 = new NodeEntity(id: 'A2', title: 'adios', x: 3, y: 7, filePath: 'a/a');
  NodeEntity n3 = new NodeEntity(id: 'A3', title: 'buenas', x: 10, y: 6, filePath: 'a/a');
  EdgeEntity e1 = new EdgeEntity(from: 'hola', to: 'adios', type: 'saludo');
  GraphEntity g = new GraphEntity(nodes: [n, n2, n3], edges: [e1]);


  print(g.toJson());
}

