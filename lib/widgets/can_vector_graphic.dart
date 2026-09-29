import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CanVectorGraphic extends StatelessWidget {
  final double width;
  final double height;
  final bool showDroplet;
  final bool showGlow;

  const CanVectorGraphic({
    super.key,
    this.width = 80,
    this.height = 110,
    this.showDroplet = true,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        painter: _CanPainter(showDroplet: showDroplet),
        size: Size(width, height),
      ),
    );
  }
}

class _CanPainter extends CustomPainter {
  final bool showDroplet;

  _CanPainter({required this.showDroplet});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 130.0;
    canvas.scale(scaleX, scaleY);

    // 1. Metal gradients
    final steelGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFCBD5E1), // 0% shadow side
        Color(0xFFF1F5F9), // 25% highlight
        Color(0xFFE2E8F0), // 50% body
        Color(0xFFFFFFFF), // 75% specular light
        Color(0xFF94A3B8), // 100% outer rim
      ],
      stops: [0.0, 0.25, 0.55, 0.8, 1.0],
    );

    final steelDarkGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF94A3B8),
        Color(0xFFE2E8F0),
        Color(0xFF64748B),
      ],
    );

    final rectBounds = const Rect.fromLTWH(0, 0, 100, 130);
    final paintBody = Paint()
      ..shader = steelGradient.createShader(rectBounds)
      ..style = PaintingStyle.fill;

    final paintDarkSteel = Paint()
      ..shader = steelDarkGradient.createShader(rectBounds)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 2. Top Handle Bar
    final handlePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final handlePath = Path()
      ..moveTo(40, 16)
      ..lineTo(40, 7)
      ..quadraticBezierTo(40, 3, 44, 3)
      ..lineTo(56, 3)
      ..quadraticBezierTo(60, 3, 60, 7)
      ..lineTo(60, 16);
    canvas.drawPath(handlePath, handlePaint);

    // 3. Lid Rim
    final lidRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 14, 32, 9),
      const Radius.circular(3),
    );
    canvas.drawRRect(lidRRect, paintDarkSteel);
    canvas.drawRRect(lidRRect, outlinePaint);

    // 4. Neck / Collar
    final neckPath = Path()
      ..moveTo(31, 23)
      ..lineTo(69, 23)
      ..lineTo(66, 38)
      ..lineTo(34, 38)
      ..close();
    canvas.drawPath(neckPath, paintBody);
    canvas.drawPath(neckPath, outlinePaint);

    // Collar ring
    final collarRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 36, 40, 6),
      const Radius.circular(2),
    );
    canvas.drawRRect(collarRect, paintDarkSteel);

    // 5. Main Can Body
    final bodyPath = Path()
      ..moveTo(32, 40)
      ..lineTo(20, 52)
      ..quadraticBezierTo(16, 56, 16, 62)
      ..lineTo(16, 118)
      ..quadraticBezierTo(16, 126, 25, 126)
      ..lineTo(75, 126)
      ..quadraticBezierTo(84, 126, 84, 118)
      ..lineTo(84, 62)
      ..quadraticBezierTo(84, 56, 80, 52)
      ..lineTo(68, 40)
      ..close();

    // Body shadow underneath
    canvas.drawOval(
      const Rect.fromLTWH(18, 120, 64, 10),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    canvas.drawPath(bodyPath, paintBody);
    canvas.drawPath(bodyPath, outlinePaint);

    // Subtle horizontal steel bands across body
    final bandPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(const Offset(16, 68), const Offset(84, 68), bandPaint);
    canvas.drawLine(const Offset(16, 108), const Offset(84, 108), bandPaint);

    // 6. Side Handles
    final sideHandlePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final leftHandle = Path()
      ..moveTo(16, 60)
      ..cubicTo(6, 60, 6, 75, 6, 75)
      ..cubicTo(6, 90, 16, 90, 16, 90);
    canvas.drawPath(leftHandle, sideHandlePaint);

    final rightHandle = Path()
      ..moveTo(84, 60)
      ..cubicTo(94, 60, 94, 75, 94, 75)
      ..cubicTo(94, 90, 84, 90, 84, 90);
    canvas.drawPath(rightHandle, sideHandlePaint);

    // 7. Signature Blue Milk Drop Emblem on Body
    if (showDroplet) {
      final dropGradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      );

      final dropBounds = const Rect.fromLTWH(38, 70, 24, 32);
      final dropPaint = Paint()
        ..shader = dropGradient.createShader(dropBounds)
        ..style = PaintingStyle.fill;

      final dropPath = Path()
        ..moveTo(50, 72)
        ..cubicTo(50, 72, 38, 86, 38, 94)
        ..cubicTo(38, 101, 43.4, 106, 50, 106)
        ..cubicTo(56.6, 106, 62, 101, 62, 94)
        ..cubicTo(62, 86, 50, 72, 50, 72)
        ..close();

      canvas.drawPath(dropPath, dropPaint);

      // Specular highlight on drop
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(46, 93), 2.2, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
