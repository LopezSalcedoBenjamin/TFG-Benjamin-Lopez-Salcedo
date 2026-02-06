import 'dart:ffi';

class NodeEntity {
  final String id;          //String de identificación del nodo
  final String title;       //Nombre del nodo
  final double x;           //Posición X en el tablero principal
  final double y;           //Posición Y en el tablero principal
  final String filePath;    //En donde se guarda el archivo

  NodeEntity({
    required this.id,
    required this.title,
    required this.x,
    required this.y,
    required this.filePath
  });

  NodeEntity copyWith({
    String? id,
    String? title,
    double? x,
    double? y,
    String? filePath,
  }) {
    return NodeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      x: x ?? this.x,
      y: y ?? this.y,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'title': title,
      'x': x,
      'y': y,
      'file': filePath,
    };
  }

  factory NodeEntity.fromJson(Map<String, dynamic> json){
    return NodeEntity(
        id: json['id'],
        title: json['title'],
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        filePath: json['file'],
    );
  }
}