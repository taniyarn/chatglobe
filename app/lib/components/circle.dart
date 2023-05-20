import 'dart:math';

import 'package:flutter/material.dart';

class Circle extends StatefulWidget {
  const Circle({
    Key? key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.rotateRadians,
    required this.radius,
    this.isBackground = false,
  }) : super(key: key);

  final Color primaryColor;
  final Color secondaryColor;
  final double rotateRadians;
  final double radius;
  final bool isBackground;

  @override
  State<Circle> createState() => _CircleState();
}

class _CircleState extends State<Circle> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size:
          widget.isBackground ? Size.infinite : Size.fromRadius(widget.radius),
      painter: CirclePainter(
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
        radius: widget.radius,
        rotateRadians: widget.rotateRadians,
        isBackground: widget.isBackground,
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.radius,
    required this.rotateRadians,
    required this.isBackground,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final double radius;
  final double rotateRadians;
  final bool isBackground;

  final x = sqrt2;

  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset(size.width / 2, size.height / 2);
    final _radius = isBackground ? radius : size.width / 2;
    for (var sigma in [
      5.0,
      10.0,
      50.0,
      100.0,
      1000.0,
    ]) {
      _drawShader(
          canvas: canvas,
          center: center,
          radius: _radius,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          rotateRadians: rotateRadians,
          sigma: sigma * _radius / 1000);
    }

    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _radius / 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    canvas.drawCircle(center, _radius, ringPaint);
  }

  static void _drawShader({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color primaryColor,
    required Color secondaryColor,
    required double sigma,
    required double rotateRadians,
  }) {
    final gradient = SweepGradient(
      colors: [
        primaryColor,
        primaryColor,
        secondaryColor,
        primaryColor,
        primaryColor
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      transform: GradientRotation(rotateRadians),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    var paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius / 15
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
