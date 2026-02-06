class EdgeEntity {
  final String from;
  final String to;
  final String type;

  EdgeEntity({
    required this.from,
    required this.to,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return{
      'node1': from,
      'node2': to,
      'type': type,
    };
  }

  factory EdgeEntity.fromJson(Map<String, dynamic> json) {
    return EdgeEntity(
      from: json['node1'],
      to: json['node2'],
      type: json['type'],
    );
  }

}