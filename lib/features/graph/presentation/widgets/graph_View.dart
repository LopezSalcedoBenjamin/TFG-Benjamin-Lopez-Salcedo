import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';

enum GridMode {dotted, lined, clean}

class GraphView extends StatefulWidget {
  final GridMode gridMode;
  const GraphView({super.key, this.gridMode = GridMode.dotted});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {

  final TransformationController _transformController = TransformationController();
  final double canvasWidth = 3000;
  final double canvasHeight = 5000;

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

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //Centramos la vista al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_){
      final screenSize = MediaQuery.of(context).size;
      final double dx = -(canvasWidth/2 - screenSize.width/2);
      final double dy = -(canvasHeight/2 - screenSize.height/2);

      _transformController.value = Matrix4.translationValues(dx,dy,0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformController,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 5.0,
      constrained: false,
      child: CustomPaint(
        size: const Size(3000, 5000),
        painter: _painterMode(widget.gridMode),
      ),
    );
  }
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