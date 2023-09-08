import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double gap;
  final double dash;
  final Axis direction;
  final Color? dashColor;
  final double strokeWidth;
  final StrokeCap strokeCap;

  const DashedDivider({
    Key? key,
    this.dashColor,
    this.gap = 6,
    this.dash = 6,
    this.strokeWidth = 1.0,
    this.direction = Axis.vertical,
    this.strokeCap = StrokeCap.round,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: (direction == Axis.horizontal)
          ? Size(double.infinity, strokeWidth)
          : Size(strokeWidth, double.infinity),
      painter: DashedLinePainter(
        strokeWidth: strokeWidth,
        dashColor: dashColor,
        direction: direction,
        strokeCap: strokeCap,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double gap;
  final double dash;
  final double strokeWidth;
  final Color? dashColor;
  final Axis direction;
  final StrokeCap strokeCap;

  const DashedLinePainter({
    this.dashColor,
    this.gap = 6,
    this.dash = 6,
    this.strokeWidth = 1.0,
    this.direction = Axis.vertical,
    this.strokeCap = StrokeCap.round,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startLine = 0;
    final paint = Paint()
      ..strokeCap = strokeCap
      ..color = dashColor ?? Colors.black54
      ..strokeWidth = strokeWidth;

    if (direction == Axis.vertical) {
      while (startLine < size.height) {
        canvas.drawLine(
            Offset(0, startLine), Offset(0, startLine + dash), paint);
        startLine += dash + gap;
      }
    } else {
      while (startLine < size.width) {
        canvas.drawLine(
            Offset(startLine, 0), Offset(startLine + dash, 0), paint);
        startLine += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
