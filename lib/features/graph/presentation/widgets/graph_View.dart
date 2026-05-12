import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/graph_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/domain/entities/node_entity.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/features/graph/presentation/widgets/node_Widget.dart';

import '../../../../domain/entities/edge_entity.dart';

enum GridMode {dotted, lined, clean}

class GraphView extends StatefulWidget {
  final GridMode gridMode;
  final TransformationController transformationController;
  final GraphEntity graph;
  final Map<String, Offset> positions;
  final Function(NodeEntity) onNodeTap;

  const GraphView({
    super.key,
    this.gridMode = GridMode.dotted,
    required this.transformationController,
    required this.graph,
    required this.positions,
    required this.onNodeTap,
  });

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {

  List<EdgeEntity> _purgedEdges = [];

  CustomPainter _painterMode(GridMode mode){
    switch(mode){
      case GridMode.dotted:
        return _DotGridPainter();
      case GridMode.lined:
        return _GridPainter();
      case GridMode.clean:
        return _CleanGridPainter();
    }
  }

  List<EdgeEntity> purgeEdgeTypes(){
    List<EdgeEntity> edges = widget.graph.edges;

    List<EdgeEntity> purgedEdges = edges.where((e) =>
      edges.lastIndexWhere((p) => (p.from == e.from && p.to == e.to) || (p.from == e.to && p.to == e.from)) == edges.indexOf(e)
    ).toList();

    return purgedEdges;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _purgedEdges = purgeEdgeTypes();
  }

  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph.edges != widget.graph.edges) {
      setState(() {
        _purgedEdges = purgeEdgeTypes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: widget.transformationController,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 5.0,
      constrained: false,
      child: SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          children: [

            // ___________________________________________________ GRID ___________________________________________________
            CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: _painterMode(widget.gridMode),
            ),

            // ___________________________________________________ NODES ___________________________________________________
            ...widget.graph.nodes.map((node) {
              final pos = widget.positions[node.id] ?? Offset(canvasWidth / 2, canvasHeight / 2);
              return Positioned(
                left: pos.dx - nodeSize/2,
                top: pos.dy - nodeSize/2,
                child: NodeWidget(
                  node: node,
                  nodeSize: nodeSize,
                ),
              );
            }),

            // ___________________________________________________ EDGES ___________________________________________________
            SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: CustomPaint(
                painter: _EdgePainter(
                  edges: widget.graph.edges,
                  purgedEdges: _purgedEdges,
                  positions: widget.positions,
                  titleToId: {
                    for(final n in widget.graph.nodes) n.title: n.id
                  },
                  nodeSize: nodeSize,
                ),
              ),
            ),

            // ___________________________________________________ NODE HIT AREAS ___________________________________________________
            ...widget.graph.nodes.map((node) {
              final pos = widget.positions[node.id] ?? Offset(canvasWidth / 2, canvasHeight / 2);
              return Positioned(
                left: pos.dx - nodeSize/2,
                top: pos.dy - nodeSize/2,
                child: NodeHitArea(
                  nodeSize: nodeSize,
                  onTap: () => widget.onNodeTap(node),
                ),
              );
            }),

          ],
        ),
      )
    );
  }
}

class _EdgePainter extends CustomPainter {
  final List<EdgeEntity> edges;
  final List<EdgeEntity> purgedEdges;
  final Map<String, Offset> positions;
  final Map<String, String> titleToId;
  final double nodeSize;

  _EdgePainter({
    required this.edges,
    required this.purgedEdges,
    required this.positions,
    required this.titleToId,
    required this.nodeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final linePaint = Paint()
      ..color = mainPurple.withAlpha(150)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = mainPurple.withAlpha(150)
      ..style = PaintingStyle.fill;

    //Pintamos lineas por cada edge
    for (final edge in purgedEdges) {
      final idA = titleToId[edge.from];
      final idB = titleToId[edge.to];
      if (idA == null || idB == null) continue;

      final Offset from = positions[idA]!;
      final Offset to   = positions[idB]!;

      // Caclulamos el vector director de la recta
      final double dx = to.dx - from.dx;
      final double dy = to.dy - from.dy;
      // Calculamos el ángulo de la recta
      final double angle = atan2(dy, dx);

      // Acortamos la recta para tocar los bordes de los nodos con un margen
      final lineMargin = nodeSize/2;
      final Offset fromEdge = from + Offset(cos(angle) * (lineMargin), sin(angle) * (lineMargin));
      final Offset fromEdgeMargin = from + Offset(cos(angle) * (lineMargin+2), sin(angle) * (lineMargin+2));
      final Offset toEdgeMargin = to - Offset(cos(angle) * (lineMargin+2), sin(angle) * (lineMargin+2));
      final Offset fromArrow = from + Offset(cos(angle) * (lineMargin+13), sin(angle) * (lineMargin+13));
      final Offset toArrow = to - Offset(cos(angle) * (lineMargin+13), sin(angle) * (lineMargin+13));

      // Comprobamos relaciónes bidireccionales
      if(edges.any((e) => e.from == edge.to && e.to == edge.from)){
        // Linea de relación bidireccional
        canvas.drawLine(fromArrow, toArrow, linePaint);

        // Punta de la flecha 1
        const double arrowSize = 12.0;
        final Path arrowPathDestiny = Path()
          ..moveTo(toEdgeMargin.dx, toEdgeMargin.dy)
          ..lineTo(
            toEdgeMargin.dx - arrowSize * cos(angle - 0.4),
            toEdgeMargin.dy - arrowSize * sin(angle - 0.4),
          )
          ..lineTo(
            toEdgeMargin.dx - arrowSize * cos(angle + 0.4),
            toEdgeMargin.dy - arrowSize * sin(angle + 0.4),
          )
          ..close();
        canvas.drawPath(arrowPathDestiny, arrowPaint);

        // Punta de la flecha 2
        final Path arrowPathOrigin = Path()
          ..moveTo(fromEdgeMargin.dx, fromEdgeMargin.dy)
          ..lineTo(
            fromEdgeMargin.dx + arrowSize * cos(angle - 0.4),
            fromEdgeMargin.dy + arrowSize * sin(angle - 0.4),
          )
          ..lineTo(
            fromEdgeMargin.dx + arrowSize * cos(angle + 0.4),
            fromEdgeMargin.dy + arrowSize * sin(angle + 0.4),
          )
          ..close();
        canvas.drawPath(arrowPathOrigin, arrowPaint);
      }else{
        // Linea de relación simple
        canvas.drawLine(fromEdge, toArrow, linePaint);

        // Punta de la flecha
        const double arrowSize = 12.0;
        final Path arrowPath = Path()
          ..moveTo(toEdgeMargin.dx, toEdgeMargin.dy)
          ..lineTo(
            toEdgeMargin.dx - arrowSize * cos(angle - 0.4),
            toEdgeMargin.dy - arrowSize * sin(angle - 0.4),
          )
          ..lineTo(
            toEdgeMargin.dx - arrowSize * cos(angle + 0.4),
            toEdgeMargin.dy - arrowSize * sin(angle + 0.4),
          )
          ..close();
        canvas.drawPath(arrowPath, arrowPaint);
      }

      // Pintar etiqueta
      final Offset mid = Offset(
        (from.dx + to.dx) / 2,
        (from.dy + to.dy) / 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: edge.type,
          style: const TextStyle( color: Colors.white, fontSize: 10,),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double textW = textPainter.width;
      final double textH = textPainter.height;
      const double padding = 5;

      final RRect background = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: mid,
          width: textW + padding * 2,
          height: textH + padding * 2,
        ),
        const Radius.circular(5),
      );

      final bgPaint = Paint()
        ..color = blackGraph3.withAlpha(130);

      canvas.drawRRect(background, bgPaint);

      textPainter.paint(
        canvas,
        mid - Offset(textW / 2, textH / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size){

    // Lineas del grid
    final paint = Paint()
        ..color = Colors.white.withAlpha(15)
        ..strokeWidth = 1;

    const double spacing = 50;

    for (double x = 0; x <= size.width; x += spacing){
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing){
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Punto central de referencia
    final centerPaint = Paint()
      ..color = Colors.white.withAlpha(75)
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5,
      centerPaint,
    );

    // Bordes del canvas
    final borderPaint = Paint()
      ..color = mainGreen
      ..strokeWidth = 5;

    canvas.drawLine(Offset(-100, -100), Offset(-100, size.height+100), borderPaint);
    canvas.drawLine(Offset(size.width+100, -100), Offset(size.width+100, size.height+100), borderPaint);
    canvas.drawLine(Offset(-100, -100), Offset(size.width+100, -100), borderPaint);
    canvas.drawLine(Offset(-100, size.height+100), Offset(size.width+100, size.height+100), borderPaint);

    canvas.drawCircle(Offset(-100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(-100, size.height+100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, size.height+100), 5, borderPaint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGridPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size){

    // Grid de puntos
    final paint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const double spacing = 50;
    final List<Offset> points = [];

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        points.add(Offset(x, y));
      }
    }

    canvas.drawPoints(PointMode.points, points, paint);

    // Punto central de referencia
    final centerPaint = Paint()
      ..color = Colors.white.withAlpha(75)
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5,
      centerPaint,
    );

    // Bordes del canvas
    final borderPaint = Paint()
      ..color = mainGreen
      ..strokeWidth = 5;

    canvas.drawLine(Offset(-100, -100), Offset(-100, size.height+100), borderPaint);
    canvas.drawLine(Offset(size.width+100, -100), Offset(size.width+100, size.height+100), borderPaint);
    canvas.drawLine(Offset(-100, -100), Offset(size.width+100, -100), borderPaint);
    canvas.drawLine(Offset(-100, size.height+100), Offset(size.width+100, size.height+100), borderPaint);

    canvas.drawCircle(Offset(-100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(-100, size.height+100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, size.height+100), 5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CleanGridPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size){

    // Punto central de referencia
    final centerPaint = Paint()
      ..color = Colors.white.withAlpha(75)
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      5,
      centerPaint,
    );

    // Bordes del canvas
    final canvasPaint = Paint()
      ..color = mainPurple
      ..strokeWidth = 5;

    canvas.drawLine(Offset(0, 0), Offset(0, size.height), canvasPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), canvasPaint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), canvasPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), canvasPaint);

    canvas.drawCircle(Offset(0, 0), 5, canvasPaint);
    canvas.drawCircle(Offset(size.width, 0), 5, canvasPaint);
    canvas.drawCircle(Offset(0, size.height), 5, canvasPaint);
    canvas.drawCircle(Offset(size.width, size.height), 5, canvasPaint);

    // Bordes del canvas
    final borderPaint = Paint()
      ..color = mainGreen
      ..strokeWidth = 5;

    canvas.drawLine(Offset(-100, -100), Offset(-100, size.height+100), borderPaint);
    canvas.drawLine(Offset(size.width+100, -100), Offset(size.width+100, size.height+100), borderPaint);
    canvas.drawLine(Offset(-100, -100), Offset(size.width+100, -100), borderPaint);
    canvas.drawLine(Offset(-100, size.height+100), Offset(size.width+100, size.height+100), borderPaint);

    canvas.drawCircle(Offset(-100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, -100), 5, borderPaint);
    canvas.drawCircle(Offset(-100, size.height+100), 5, borderPaint);
    canvas.drawCircle(Offset(size.width+100, size.height+100), 5, borderPaint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}