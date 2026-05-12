import 'package:flutter/material.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';

import '../../../../consts.dart';

class NodeWidget extends StatelessWidget {
  final NodeEntity node;
  final double nodeSize;

  const NodeWidget({
    super.key,
    required this.node,
    required this.nodeSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1a1040),
          border: Border.all(color: mainPurple, width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              node.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NodeHitArea extends StatelessWidget {
  final double nodeSize;
  final VoidCallback onTap;

  const NodeHitArea({
    super.key,
    required this.nodeSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: nodeSize,
        height: nodeSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
      ),
    );
  }
}