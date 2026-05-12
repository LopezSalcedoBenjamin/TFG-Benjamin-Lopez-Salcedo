import 'dart:ui';
import 'dart:math';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/edge_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';

Map<String, Offset> calcularLayout(List<NodeEntity> nodes, List<EdgeEntity> edges, {bool  recalculate = false}){

  if(nodes.isEmpty) return {};

  final random = Random(42);
  final Map<String, Offset> positions = {};

  for (final node in nodes) {
    if ((node.x == 1.0 && node.y == 1.0) || recalculate) {
      positions[node.id] = Offset(
        1400 + random.nextDouble() * 200,
        2400 + random.nextDouble() * 200,
      );
    } else {
      positions[node.id] = Offset(node.x, node.y);
    }
  }

  const double k = 150.0;
  const int iterations = 200;
  double temp = 10.0;

  for (int i = 0; i < iterations; i++){
    final Map<String, Offset> forces = {
      for (final n in nodes) n.id: Offset.zero
    };

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final idA = nodes[i].id;
        final idB = nodes[j].id;
        final delta = positions[idA]! - positions[idB]!;
        final double dist = delta.distance < 1.0 ? 1.0 : delta.distance;
        final double force = (k * k) / dist;
        final direction = delta / dist;

        forces[idA] = forces[idA]! + direction * force;
        forces[idB] = forces[idB]! - direction * force;
      }
    }

    final Map<String, String> titleToId = {
      for (final n in nodes) n.title: n.id
    };

    for (final edge in edges) {
      final idA = titleToId[edge.from];
      final idB = titleToId[edge.to];
      if (idA == null || idB == null) continue;

      final delta = positions[idB]! - positions[idA]!;
      final double dist = delta.distance < 1.0 ? 1.0 : delta.distance;
      final double force = (dist * dist) / k;
      final direction = delta / dist;

      forces[idA] = forces[idA]! + direction * force;
      forces[idB] = forces[idB]! - direction * force;
    }

    for (final node in nodes) {
      if ((node.x != 1.0 || node.y != 1.0) && !recalculate) continue;

      final force = forces[node.id]!;
      final double raw = force.distance < 1.0 ? 1.0 : force.distance;
      final double magnitude = raw > temp ? temp : raw;
      final direction = force / raw;
      Offset newPos = positions[node.id]! + direction * magnitude;

      newPos = Offset(
        newPos.dx.clamp(100.0, 2900.0),
        newPos.dy.clamp(100.0, 4900.0),
      );

      positions[node.id] = newPos;
    }

    temp *= 0.95;
  }

  const double minDistance = 150.0;
  const int maxAttempts = 500;

  for (final node in nodes) {
    if ((node.x != 1.0 || node.y != 1.0) && !recalculate) continue; // solo nodos nuevos

    bool overlapping = true;
    int attempts = 0;

    while (overlapping && attempts < maxAttempts) {
      for (final other in nodes) {
        if (other.id == node.id) continue;
        final delta = positions[node.id]! - positions[other.id]!;
        if (delta.distance < minDistance) {
          final direction = delta / delta.distance;
          positions[node.id] = positions[node.id]! + direction * (minDistance - delta.distance);
        }
      }

      overlapping = nodes.any((other) {
        if (other.id == node.id) return false;
        return (positions[node.id]! - positions[other.id]!).distance < minDistance;
      });

      attempts++;
    }

  }

  return positions;
}