import 'package:flutter/material.dart';

class MilkoraLogo extends StatelessWidget {
  final double size;

  const MilkoraLogo({super.key, this.size = 120.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MilkoraLogoPainter(),
      ),
    );
  }
}

class _MilkoraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 160.0;
    canvas.scale(scale);

    // 1. Background Circle
    final bgCirclePaint = Paint()
      ..color = const Color(0xFFEFF6FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(80, 80), 76, bgCirclePaint);

    final bgStrokePaint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(const Offset(80, 80), 76, bgStrokePaint);

    // 2. Linear Gradient for Can
    final canGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    );
    final canBounds = const Rect.fromLTWH(30, 18, 100, 114);
    final canGradientPaint = Paint()
      ..shader = canGradient.createShader(canBounds)
      ..style = PaintingStyle.fill;

    // 3. Can Top Handle Loop
    final handleLoopPaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final handlePath = Path()
      ..moveTo(70, 30)
      ..lineTo(70, 22)
      ..quadraticBezierTo(70, 18, 74, 18)
      ..lineTo(86, 18)
      ..quadraticBezierTo(90, 18, 90, 22)
      ..lineTo(90, 30);
    canvas.drawPath(handlePath, handleLoopPaint);

    // 4. Can Lid Rect
    final lidPaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.fill;
    final lidRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(62, 30, 36, 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(lidRect, lidPaint);

    // 5. Can Neck
    final neckPath = Path()
      ..moveTo(58, 38)
      ..lineTo(102, 38)
      ..lineTo(98, 54)
      ..lineTo(62, 54)
      ..close();
    canvas.drawPath(neckPath, canGradientPaint);

    // 6. Can Body
    final bodyPath = Path()
      ..moveTo(62, 54)
      ..lineTo(44, 68)
      ..quadraticBezierTo(40, 71, 40, 78)
      ..lineTo(40, 124)
      ..quadraticBezierTo(40, 132, 48, 132)
      ..lineTo(112, 132)
      ..quadraticBezierTo(120, 132, 120, 124)
      ..lineTo(120, 78)
      ..quadraticBezierTo(120, 71, 116, 68)
      ..lineTo(98, 54)
      ..close();
    canvas.drawPath(bodyPath, canGradientPaint);

    // 7. Side Handles
    final sideHandlePaint = Paint()
      ..color = const Color(0xFF1E40AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final leftSideHandle = Path()
      ..moveTo(40, 78)
      ..cubicTo(30, 78, 30, 90, 30, 90)
      ..cubicTo(30, 102, 40, 102, 40, 102);
    canvas.drawPath(leftSideHandle, sideHandlePaint);

    final rightSideHandle = Path()
      ..moveTo(120, 78)
      ..cubicTo(130, 78, 130, 90, 130, 90)
      ..cubicTo(130, 102, 120, 102, 120, 102);
    canvas.drawPath(rightSideHandle, sideHandlePaint);

    // 8. White Milk Drop on Body
    final dropPath = Path()
      ..moveTo(80, 78)
      ..cubicTo(80, 78, 68, 95, 68, 106)
      ..cubicTo(68, 114, 73.4, 119, 80, 119)
      ..cubicTo(86.6, 119, 92, 114, 92, 106)
      ..cubicTo(92, 95, 80, 78, 80, 78)
      ..close();

    final dropPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, dropPaint);

    // 9. Inner Blue Drop Accent
    final innerDropDot = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(76, 103), 3, innerDropDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
