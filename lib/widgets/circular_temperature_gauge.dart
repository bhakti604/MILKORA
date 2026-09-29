import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/temperature_data.dart';
import '../theme/app_theme.dart';
import '../localization/language_provider.dart';
import '../localization/app_strings.dart';
import 'status_pill.dart';

class CircularTemperatureGauge extends StatelessWidget {
  final double? temperature;
  final bool isLive;
  final bool isOffline;
  final bool isStale;
  final double size;

  const CircularTemperatureGauge({
    super.key,
    required this.temperature,
    this.isLive = true,
    this.isOffline = false,
    this.isStale = false,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final hasTemp = temperature != null && !isOffline;
    final tempVal = temperature ?? 4.2;
    final tempStatus = TemperatureThresholds.evaluate(tempVal);

    // Map temperature from range 0°C to 14°C to progress 0.0 to 1.0
    // Below 0 -> 0, above 14 -> 1.0
    final double progress = ((tempVal - 0.0) / 14.0).clamp(0.05, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track and Active Progress Arc
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: hasTemp ? progress : 0.0,
              status: tempStatus,
              isOffline: !hasTemp,
            ),
          ),

          // Central Information Display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTemp) ...[
                // Main Temperature Number
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tempVal.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Status Badge
                StatusPill.fromTempStatus(tempStatus, isLarge: true),

                const SizedBox(height: 8),

                // Helper Subtitle
                Text(
                  _getStatusDescription(tempStatus, LanguageProvider().strings),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Text(
                  '(4°C — 8°C)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.sensors_off_rounded,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageProvider().strings.offline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LanguageProvider().strings.sensorLost,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(TemperatureStatus status, AppStrings strings) {
    switch (status) {
      case TemperatureStatus.safe:
        return strings.withinSafeRange;
      case TemperatureStatus.warning:
        return strings.warning;
      case TemperatureStatus.critical:
        return strings.critical;
      case TemperatureStatus.low:
        return strings.low;
    }
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final TemperatureStatus status;
  final bool isOffline;

  _ArcPainter({
    required this.progress,
    required this.status,
    required this.isOffline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.065;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2 - 4;

    // 240 degrees sweep, starting from 150 degrees (bottom-left) to 390 degrees (bottom-right)
    const startAngle = 145.0 * (math.pi / 180.0);
    const totalSweep = 250.0 * (math.pi / 180.0);

    // 1. Background Inactive Arc Track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    if (isOffline || progress <= 0) return;

    // 2. Active Arc with Status Colors
    List<Color> gradientColors;
    switch (status) {
      case TemperatureStatus.safe:
        gradientColors = [
          const Color(0xFF34D399), // Emerald light
          const Color(0xFF10B981), // Emerald safe
        ];
        break;
      case TemperatureStatus.warning:
        gradientColors = [
          const Color(0xFFFBBF24),
          const Color(0xFFF59E0B),
        ];
        break;
      case TemperatureStatus.critical:
        gradientColors = [
          const Color(0xFFF87171),
          const Color(0xFFEF4444),
        ];
        break;
      case TemperatureStatus.low:
        gradientColors = [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
        ];
        break;
    }

    final activeSweep = totalSweep * progress.clamp(0.02, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + totalSweep,
      colors: gradientColors,
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      activeSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.isOffline != isOffline;
  }
}
