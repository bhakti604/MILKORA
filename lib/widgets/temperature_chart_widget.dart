import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TemperatureDataPoint {
  final double temp;
  final String timeLabel;

  const TemperatureDataPoint({required this.temp, required this.timeLabel});
}

class TemperatureChartWidget extends StatelessWidget {
  final List<TemperatureDataPoint> dataPoints;
  final double currentTemp;
  final String currentTime;
  final bool isLive;

  const TemperatureChartWidget({
    super.key,
    required this.dataPoints,
    required this.currentTemp,
    required this.currentTime,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart Canvas
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _ChartPainter(
                dataPoints: dataPoints,
                currentTemp: currentTemp,
                currentTime: currentTime,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              _buildLegendItem(
                color: AppColors.primary,
                label: 'Temperature',
              ),
              _buildLegendItem(
                color: AppColors.safeGreen,
                label: 'Safe Range (4-8°C)',
              ),
              _buildLegendItem(
                color: AppColors.warningAmber,
                label: 'Warning Range (8-10°C)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<TemperatureDataPoint> dataPoints;
  final double currentTemp;
  final String currentTime;

  _ChartPainter({
    required this.dataPoints,
    required this.currentTemp,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 34.0;
    const bottomPadding = 24.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    // Y Range: 0 to 12
    const minY = 0.0;
    const maxY = 12.0;
    const totalRange = maxY - minY;

    double yToCanvas(double y) {
      final normalized = (y - minY) / totalRange;
      return chartHeight * (1.0 - normalized);
    }

    // 1. Shaded Background Range Zones
    // Critical: 10 to 12
    final critTop = yToCanvas(12.0);
    final critHeight = yToCanvas(10.0) - critTop;
    canvas.drawRect(
      Rect.fromLTWH(leftPadding, critTop, chartWidth, critHeight),
      Paint()..color = const Color(0xFFFEE2E2).withValues(alpha: 0.4),
    );

    // Warning: 8 to 10
    final warnTop = yToCanvas(10.0);
    final warnHeight = yToCanvas(8.0) - warnTop;
    canvas.drawRect(
      Rect.fromLTWH(leftPadding, warnTop, chartWidth, warnHeight),
      Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: 0.4),
    );

    // Safe: 4 to 8
    final safeTop = yToCanvas(8.0);
    final safeHeight = yToCanvas(4.0) - safeTop;
    canvas.drawRect(
      Rect.fromLTWH(leftPadding, safeTop, chartWidth, safeHeight),
      Paint()..color = const Color(0xFFDCFCE7).withValues(alpha: 0.4),
    );

    // Grid lines and Y labels (0, 2, 4, 6, 8, 10, 12)
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;

    final textStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.textTertiary,
    );

    for (int t = 0; t <= 12; t += 2) {
      final y = yToCanvas(t.toDouble());
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(text: '$t', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2));
    }

    // X Axis Labels (12AM, 4AM, 8AM, 12PM, 4PM, 8PM)
    final xLabels = ['12AM', '4AM', '8AM', '12PM', '4PM', '8PM'];
    final stepX = chartWidth / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPadding + i * stepX;
      final textSpan = TextSpan(text: xLabels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, chartHeight + 6));
    }

    if (dataPoints.isEmpty) return;

    // 2. Draw Temperature Curve
    final points = <Offset>[];
    final count = dataPoints.length;
    for (int i = 0; i < count; i++) {
      final x = leftPadding + (i / (count - 1).clamp(1, 999)) * chartWidth;
      final y = yToCanvas(dataPoints[i].temp.clamp(minY, maxY));
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line stroke
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // 3. Highlight Point & Tooltip on Current Temp
    // Find point roughly corresponding to 09:41 AM (around index 2 or 3 in 6 points)
    final highlightIndex = (points.length * 0.45).round().clamp(0, points.length - 1);
    final hp = points[highlightIndex];

    // Dashed vertical guideline
    final dashPaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 1.0;
    for (double dy = hp.dy; dy < chartHeight; dy += 6) {
      canvas.drawLine(Offset(hp.dx, dy), Offset(hp.dx, (dy + 3).clamp(dy, chartHeight)), dashPaint);
    }

    // Outer glow dot
    canvas.drawCircle(hp, 6, Paint()..color = AppColors.primaryLight.withValues(alpha: 0.5));
    // Inner dot
    canvas.drawCircle(hp, 3.5, Paint()..color = AppColors.primary);
    canvas.drawCircle(hp, 1.5, Paint()..color = Colors.white);

    // Tooltip Card above point
    final tooltipPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${currentTemp.toStringAsFixed(1)}°C  ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: currentTime,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFFBAE6FD),
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final ttWidth = tooltipPainter.width + 16;
    final ttHeight = tooltipPainter.height + 10;
    final ttX = (hp.dx - ttWidth / 2).clamp(leftPadding, size.width - ttWidth);
    final ttY = hp.dy - ttHeight - 8;

    final ttRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(ttX, ttY, ttWidth, ttHeight),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      ttRRect,
      Paint()..color = const Color(0xFF0F172A),
    );

    tooltipPainter.paint(canvas, Offset(ttX + 8, ttY + 5));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
