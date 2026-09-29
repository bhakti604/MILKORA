import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../models/temperature_data.dart';
import '../theme/app_theme.dart';
import '../localization/language_provider.dart';

enum StatusPillType {
  safe,
  warning,
  critical,
  low,
  connected,
  disconnected,
  stale,
}

class StatusPill extends StatelessWidget {
  final StatusPillType type;
  final String? customLabel;
  final bool isLarge;

  const StatusPill({
    super.key,
    required this.type,
    this.customLabel,
    this.isLarge = false,
  });

  factory StatusPill.fromTempStatus(TemperatureStatus status, {bool isLarge = false}) {
    switch (status) {
      case TemperatureStatus.safe:
        return StatusPill(type: StatusPillType.safe, isLarge: isLarge);
      case TemperatureStatus.warning:
        return StatusPill(type: StatusPillType.warning, isLarge: isLarge);
      case TemperatureStatus.critical:
        return StatusPill(type: StatusPillType.critical, isLarge: isLarge);
      case TemperatureStatus.low:
        return StatusPill(type: StatusPillType.low, isLarge: isLarge);
    }
  }

  factory StatusPill.fromCanStatus(CanStatus status, {bool isLarge = false}) {
    switch (status) {
      case CanStatus.safe:
        return StatusPill(type: StatusPillType.safe, isLarge: isLarge);
      case CanStatus.checkSoon:
        return StatusPill(type: StatusPillType.warning, isLarge: isLarge);
      case CanStatus.collectNow:
        return StatusPill(type: StatusPillType.critical, isLarge: isLarge);
    }
  }

  factory StatusPill.connection({
    required bool isConnected,
    required bool isLive,
    bool isStale = false,
    bool isLarge = false,
  }) {
    if (isStale) {
      return StatusPill(type: StatusPillType.stale, isLarge: isLarge);
    }
    if (isLive || isConnected) {
      return StatusPill(type: StatusPillType.connected, isLarge: isLarge);
    }
    return StatusPill(type: StatusPillType.disconnected, isLarge: isLarge);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String defaultLabel;

    final strings = LanguageProvider().strings;

    switch (type) {
      case StatusPillType.safe:
        bg = AppColors.safeGreenBg;
        border = AppColors.safeGreen.withValues(alpha: 0.3);
        fg = AppColors.safeGreenDark;
        icon = Icons.check_circle_rounded;
        defaultLabel = strings.safe;
        break;
      case StatusPillType.warning:
        bg = AppColors.warningBg;
        border = AppColors.warningAmber.withValues(alpha: 0.3);
        fg = AppColors.warningDark;
        icon = Icons.warning_amber_rounded;
        defaultLabel = strings.warning;
        break;
      case StatusPillType.critical:
        bg = AppColors.errorBg;
        border = AppColors.urgentRed.withValues(alpha: 0.3);
        fg = AppColors.errorDark;
        icon = Icons.error_outline_rounded;
        defaultLabel = strings.critical;
        break;
      case StatusPillType.low:
        bg = AppColors.lowBlueBg;
        border = AppColors.lowBlue.withValues(alpha: 0.3);
        fg = AppColors.lowBlueDark;
        icon = Icons.arrow_downward_rounded;
        defaultLabel = strings.low;
        break;
      case StatusPillType.connected:
        bg = AppColors.safeGreen;
        border = AppColors.safeGreen;
        fg = Colors.white;
        icon = Icons.circle;
        defaultLabel = strings.connected;
        break;
      case StatusPillType.disconnected:
        bg = AppColors.surfaceContainerLow;
        border = AppColors.border;
        fg = AppColors.textSecondary;
        icon = Icons.circle_outlined;
        defaultLabel = strings.disconnected;
        break;
      case StatusPillType.stale:
        bg = AppColors.warningBg;
        border = AppColors.warningAmber.withValues(alpha: 0.4);
        fg = AppColors.warningDark;
        icon = Icons.warning_amber_rounded;
        defaultLabel = strings.sensorLost;
        break;
    }

    final label = customLabel ?? defaultLabel;
    final isFilledGreen = type == StatusPillType.connected;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isFilledGreen ? 7 : (isLarge ? 15 : 13),
            color: fg,
          ),
          SizedBox(width: isFilledGreen ? 5 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13 : 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
