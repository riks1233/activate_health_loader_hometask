import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;

class Arc extends StatelessWidget {
  const Arc({
    Key? key,
    required this.color,
    required this.arcSize,
    required this.strokeWidth,
    required this.tailAngle,
    required this.headAngle,
  }) : super(key: key);

  final Color color;
  final double arcSize;
  final double strokeWidth;
  final double tailAngle;
  final double headAngle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: vmath.radians(-180),
      child: CustomPaint(
        painter: ArcPainter(
          color: color,
          arcSize: arcSize,
          strokeWidth: strokeWidth,
          tailAngle: tailAngle,
          headAngle: headAngle,
        ),
      ),
    );
  }
}

/// ArcPainter CustomPainter, adapted from:
/// https://stackoverflow.com/questions/67336319/create-custom-circular-progress-indicator-in-flutter-with-custom-stroke-cap
class ArcPainter extends CustomPainter {
  const ArcPainter({
    required this.color,
    required this.arcSize,
    required this.strokeWidth,
    required this.tailAngle,
    required this.headAngle,
  });

  final Color color;
  final double arcSize;
  final double strokeWidth;
  final double tailAngle;
  final double headAngle;

  @override
  void paint(Canvas canvas, Size size) {
    double sweepAngle = ((360 - tailAngle).abs() + headAngle) % 360;
    sweepAngle = headAngle - tailAngle == 360 ? 360 : sweepAngle;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.width, size.height), width: arcSize, height: arcSize),
      vmath.radians(tailAngle),
      vmath.radians(sweepAngle),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = color
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
