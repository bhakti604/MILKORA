import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import '../widgets/can_vector_graphic.dart';
import '../widgets/circular_temperature_gauge.dart';
import '../widgets/milk_safety_score_card.dart';
import '../widgets/pulse_live_badge.dart';
import '../widgets/sensor_metric_card.dart';
import '../widgets/ble_connection_panel.dart';
import '../localization/language_provider.dart';

class HomeScreen extends StatelessWidget {
  final MilkCan can;
  final VoidCallback onViewAllCans;
  final ValueChanged<MilkCan> onSelectCan;

  const HomeScreen({
    super.key,
    required this.can,
    required this.onViewAllCans,
    required this.onSelectCan,
  });

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final bool isBleConnected = bleService.isConnected;
        final bool isBleLive = bleService.isLive;
        final bool isSensorLost = bleService.isSensorLost;

        // DS18B20 Live Temperature: real BLE stream takes priority, never use demo when BLE is connected
        final double? currentTemp = (isBleConnected || isBleLive)
            ? bleService.liveTemperature
            : can.temperature;

        // Format live timestamp
        final String lastUpdatedText = isBleLive && bleService.lastReadingTime != null
            ? _formatTimestamp(bleService.lastReadingTime!)
            : '24 Oct 2024, 09:41 AM';

        // Future hardware sensor abstractions with preserved demo values
        final String volumeText = '${(bleService.hardwareVolumeLiters ?? can.volumeLiters).toStringAsFixed(1)} L';
        final String batteryText = '${bleService.hardwareBatteryPercent ?? can.batteryLevel}%';
        final String lidText = bleService.lidStatusDisplay;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. MILK SAFETY SCORE (Distinctive Product Identity)
                MilkSafetyScoreCard(
                  currentTemp: currentTemp,
                  isLive: isBleLive,
                ),

                const SizedBox(height: 14),

                // 2. PRIMARY MAIN CAN TEMPERATURE & LIVE COLD-CHAIN CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Header Row: Hero Can Avatar, Title, and Pulse Live Badge
                      Row(
                        children: [
                          // Recurring Metallic Milk Can Avatar
                          Container(
                            width: 44,
                            height: 48,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CanVectorGraphic(width: 32, height: 42, showDroplet: true),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Can Identifier & Live Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      strings.liveSensor.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '• ${isBleConnected ? bleService.deviceName : can.name}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${strings.lastUpdated}: $lastUpdatedText',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Interactive Pulsing Live Sensor Badge
                          InkWell(
                            onTap: () => BleConnectionPanel.show(context),
                            borderRadius: BorderRadius.circular(100),
                            child: PulseLiveBadge(
                              isLive: isBleLive,
                              isConnected: isBleConnected,
                              isStale: isSensorLost,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Circular Temperature Gauge Hero
                      CircularTemperatureGauge(
                        temperature: currentTemp,
                        isLive: isBleLive,
                        isOffline: !isBleConnected && currentTemp == null,
                        isStale: isSensorLost,
                        size: 205,
                      ),

                      const SizedBox(height: 20),

                      // 3 Compact Sensor Metric Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: SensorMetricCard(
                              icon: Icons.water_drop_rounded,
                              iconColor: AppColors.primary,
                              iconBgColor: AppColors.primaryFixed,
                              value: volumeText,
                              label: strings.milkQuantity,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SensorMetricCard(
                              icon: Icons.battery_charging_full_rounded,
                              iconColor: AppColors.safeGreenDark,
                              iconBgColor: AppColors.safeGreenLight,
                              value: batteryText,
                              label: strings.battery,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SensorMetricCard(
                              icon: Icons.lock_rounded,
                              iconColor: const Color(0xFF0F766E),
                              iconBgColor: const Color(0xFFCCFBF1),
                              value: lidText,
                              label: strings.lidStatus,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. TODAY'S MILK SAFETY (Fleet Cold-Chain Health Overview)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.health_and_safety_rounded, size: 16, color: AppColors.safeGreenDark),
                              const SizedBox(width: 6),
                              Text(
                                strings.todaysMilkSafety,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: onViewAllCans,
                            child: Text(
                              '${strings.cansMonitored(4)} →',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildSafetyCountChip(strings.safeCount(3), AppColors.safeGreenDark, AppColors.safeGreenBg),
                          const SizedBox(width: 8),
                          _buildSafetyCountChip(strings.warningCount(1), AppColors.warningDark, AppColors.warningBg),
                          const SizedBox(width: 8),
                          _buildSafetyCountChip(strings.criticalCount(0), AppColors.errorDark, AppColors.errorBg),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.safeGreenBg,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              strings.withinSafeRange,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.safeGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. SAFE TIME LEFT CARD
                InkWell(
                  onTap: () => onSelectCan(can),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time_filled_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.safeTimeLeft,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                '4 h 18 m',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                strings.milkIsSafeNow,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.safeGreenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primaryDark,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSafetyCountChip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }
}
