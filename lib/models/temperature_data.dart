import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'milk_can.dart';

enum TemperatureStatus {
  low,
  safe,
  warning,
  critical,
}

class TemperatureThresholds {
  // Configurable thresholds as requested
  static const double safeMin = 4.0;
  static const double safeMax = 8.0;
  static const double critical = 10.0;

  /// Calculate temperature status based on physical sensor reading
  static TemperatureStatus evaluate(double temp) {
    if (temp < safeMin) {
      return TemperatureStatus.low;
    } else if (temp <= safeMax) {
      return TemperatureStatus.safe;
    } else if (temp < critical) {
      return TemperatureStatus.warning;
    } else {
      return TemperatureStatus.critical;
    }
  }

  /// Maps TemperatureStatus to existing CanStatus for seamless UI compatibility
  static CanStatus toCanStatus(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.low:
        return CanStatus.checkSoon;
      case TemperatureStatus.safe:
        return CanStatus.safe;
      case TemperatureStatus.warning:
        return CanStatus.checkSoon;
      case TemperatureStatus.critical:
        return CanStatus.collectNow;
    }
  }

  static String getLabel(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.low:
        return 'LOW';
      case TemperatureStatus.safe:
        return 'SAFE';
      case TemperatureStatus.warning:
        return 'WARNING';
      case TemperatureStatus.critical:
        return 'CRITICAL';
    }
  }

  static Color getColor(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.low:
        return AppColors.warningAmber;
      case TemperatureStatus.safe:
        return AppColors.safeGreen;
      case TemperatureStatus.warning:
        return AppColors.warningAmber;
      case TemperatureStatus.critical:
        return AppColors.urgentRed;
    }
  }

  static Color getBackgroundColor(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.low:
        return AppColors.tertiaryContainer;
      case TemperatureStatus.safe:
        return AppColors.secondaryContainer;
      case TemperatureStatus.warning:
        return AppColors.tertiaryContainer;
      case TemperatureStatus.critical:
        return AppColors.errorContainer;
    }
  }
}

class MilkCanTemperature {
  final double temperature;
  final DateTime timestamp;
  final bool isLive;
  final bool connected;
  final TemperatureStatus status;
  final String deviceName;

  const MilkCanTemperature({
    required this.temperature,
    required this.timestamp,
    required this.isLive,
    required this.connected,
    required this.status,
    this.deviceName = 'MILKORA-CAN-01',
  });

  factory MilkCanTemperature.initial({double initialTemp = 6.3}) {
    return MilkCanTemperature(
      temperature: initialTemp,
      timestamp: DateTime.now(),
      isLive: false,
      connected: false,
      status: TemperatureThresholds.evaluate(initialTemp),
    );
  }

  MilkCanTemperature copyWith({
    double? temperature,
    DateTime? timestamp,
    bool? isLive,
    bool? connected,
    TemperatureStatus? status,
    String? deviceName,
  }) {
    return MilkCanTemperature(
      temperature: temperature ?? this.temperature,
      timestamp: timestamp ?? this.timestamp,
      isLive: isLive ?? this.isLive,
      connected: connected ?? this.connected,
      status: status ?? this.status,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

class LiveAlertItem {
  final String id;
  final String canId;
  final String title;
  final String message;
  final String recommendedAction;
  final double temperature;
  final TemperatureStatus status;
  final DateTime timestamp;
  final bool isUrgent;

  LiveAlertItem({
    required this.id,
    required this.canId,
    required this.title,
    required this.message,
    required this.recommendedAction,
    required this.temperature,
    required this.status,
    required this.timestamp,
    required this.isUrgent,
  });
}
