import 'package:flutter/material.dart';
import '../models/temperature_data.dart';
import '../theme/app_theme.dart';

class LinearTemperatureGauge extends StatelessWidget {
  final double temperature;
  final double minTemp;
  final double maxTemp;

  const LinearTemperatureGauge({
    super.key,
    required this.temperature,
    this.minTemp = 0.0,
    this.maxTemp = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final tempStatus = TemperatureThresholds.evaluate(temperature);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom Painted Slider Bar
        SizedBox(
          height: 36,
          child: CustomPaint(
            painter: _LinearGaugePainter(
              temperature: temperature,
              minTemp: minTemp,
              maxTemp: maxTemp,
              status: tempStatus,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Labels under ticks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '0°C',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                '4°C',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.safeGreenDark,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                '8°C',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.safeGreenDark,
                ),
              ),
            ),
            Text(
              '12°C',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Subtitle indicator
        const Center(
          child: Text(
            'Optimal temperature range: 4°C – 8°C',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinearGaugePainter extends CustomPainter {
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final TemperatureStatus status;

  _LinearGaugePainter({
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height * 0.45;
    final trackHeight = 6.0;
    final totalRange = maxTemp - minTemp;

    // Background track (full range 0 - 12)
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, trackY - trackHeight / 2, size.width, trackHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(bgRRect, bgPaint);

    // Safe zone highlighted band (4°C to 8°C)
    final safeStartX = ((4.0 - minTemp) / totalRange) * size.width;
    final safeEndX = ((8.0 - minTemp) / totalRange) * size.width;

    final safeZonePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final safeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(safeStartX, trackY - trackHeight / 2, safeEndX - safeStartX, trackHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(safeRRect, safeZonePaint);

    // Tick marks at 0, 4, 8, 12
    final tickPaint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 1.5;

    final tick4X = safeStartX;
    final tick8X = safeEndX;

    canvas.drawLine(Offset(0, trackY - 6), Offset(0, trackY + 6), tickPaint);
    canvas.drawLine(Offset(tick4X, trackY - 6), Offset(tick4X, trackY + 6), tickPaint);
    canvas.drawLine(Offset(tick8X, trackY - 6), Offset(tick8X, trackY + 6), tickPaint);
    canvas.drawLine(Offset(size.width, trackY - 6), Offset(size.width, trackY + 6), tickPaint);

    // Current temperature pin position
    final clampedTemp = temperature.clamp(minTemp, maxTemp);
    final pinX = ((clampedTemp - minTemp) / totalRange) * size.width;

    // Pin indicator: circle with border and pulse
    Color pinColor;
    switch (status) {
      case TemperatureStatus.safe:
        pinColor = AppColors.primary;
        break;
      case TemperatureStatus.warning:
        pinColor = AppColors.warningAmber;
        break;
      case TemperatureStatus.critical:
        pinColor = AppColors.urgentRed;
        break;
      case TemperatureStatus.low:
        pinColor = AppColors.lowBlue;
        break;
    }

    // Outer shadow / glow
    canvas.drawCircle(
      Offset(pinX, trackY),
      8,
      Paint()..color = pinColor.withValues(alpha: 0.25),
    );

    // Pin body
    canvas.drawCircle(
      Offset(pinX, trackY),
      5.5,
      Paint()..color = pinColor,
    );

    // Inner white dot
    canvas.drawCircle(
      Offset(pinX, trackY),
      2.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _LinearGaugePainter oldDelegate) {
    return oldDelegate.temperature != temperature || oldDelegate.status != status;
  }
}
