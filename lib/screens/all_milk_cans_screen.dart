import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../models/temperature_data.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import '../widgets/can_vector_graphic.dart';
import '../widgets/status_pill.dart';

import '../localization/language_provider.dart';

class AllMilkCansScreen extends StatelessWidget {
  final List<MilkCan> cans;
  final ValueChanged<MilkCan> onSelectCan;

  const AllMilkCansScreen({
    super.key,
    required this.cans,
    required this.onSelectCan,
  });

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final bool isBleLive = bleService.isLive;

        // Calculate counts dynamically
        int safeCount = 0;
        int warningCount = 0;
        int criticalCount = 0;

        for (final c in cans) {
          double temp = c.temperature;
          final bool isHardwareCan = c.id == 'CAN-001' || c.id == 'M-001' || c.name.contains('001') || c.name.contains('CAN-01');
          if (isHardwareCan && bleService.liveTemperature != null) {
            temp = bleService.liveTemperature!;
          }
          final status = TemperatureThresholds.evaluate(temp);
          if (status == TemperatureStatus.safe || status == TemperatureStatus.low) {
            safeCount++;
          } else if (status == TemperatureStatus.warning) {
            warningCount++;
          } else {
            criticalCount++;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Titles
                Text(
                  strings.milkCansTitle,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.milkCansSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // 4 Summary Metrics Row (Screen 3 Reference Benchmark)
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        count: '${cans.length}',
                        label: strings.total,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        count: '$safeCount',
                        label: strings.safe,
                        color: AppColors.safeGreenDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        count: '$warningCount',
                        label: strings.warning,
                        color: AppColors.warningDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        count: '$criticalCount',
                        label: strings.critical,
                        color: AppColors.errorDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // List of Can Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final can = cans[index];
                    final bool isHardwareCan = can.id == 'CAN-001' || can.id == 'M-001' || can.name.contains('001') || can.name.contains('CAN-01');

                    // Resolve real-time temperature
                    final double temp = (isHardwareCan && bleService.liveTemperature != null)
                        ? bleService.liveTemperature!
                        : can.temperature;

                    final tempStatus = TemperatureThresholds.evaluate(temp);
                    final canStatus = TemperatureThresholds.toCanStatus(tempStatus);

                    return _buildCanItemCard(
                      context: context,
                      can: can,
                      temp: temp,
                      tempStatus: tempStatus,
                      canStatus: canStatus,
                      isHardwareCan: isHardwareCan,
                      isBleLive: isBleLive && isHardwareCan,
                      onTap: () => onSelectCan(can),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.subtleShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanItemCard({
    required BuildContext context,
    required MilkCan can,
    required double temp,
    required TemperatureStatus tempStatus,
    required CanStatus canStatus,
    required bool isHardwareCan,
    required bool isBleLive,
    required VoidCallback onTap,
  }) {
    // Dynamic color for temperature value
    Color tempColor;
    switch (tempStatus) {
      case TemperatureStatus.safe:
      case TemperatureStatus.low:
        tempColor = AppColors.safeGreenDark;
        break;
      case TemperatureStatus.warning:
        tempColor = AppColors.warningDark;
        break;
      case TemperatureStatus.critical:
        tempColor = AppColors.errorDark;
        break;
    }

    // Dynamic left time label
    String timeLeftText;
    if (can.id == 'CAN-001') {
      timeLeftText = '4 h 18 m left';
    } else if (can.id == 'CAN-002') {
      timeLeftText = '3 h 45 m left';
    } else if (can.id == 'CAN-003') {
      timeLeftText = '1 h 10 m left';
    } else {
      timeLeftText = 'Collect Now';
    }

    final isCritical = tempStatus == TemperatureStatus.critical;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.cardShadow,
          border: Border.all(
            color: isCritical
                ? AppColors.urgentRed.withValues(alpha: 0.3)
                : AppColors.borderLight,
            width: isCritical ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Left Can Vector Graphic
            Container(
              width: 48,
              height: 54,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: CanVectorGraphic(width: 34, height: 46, showDroplet: true),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Identifier, Temperature, Volume
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        can.name,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isBleLive) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.safeGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${temp.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: tempColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${can.volumeLiters.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Status Badge, Time Left, Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusPill.fromTempStatus(tempStatus),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCritical)
                      const Icon(Icons.warning_rounded, size: 13, color: AppColors.urgentRed)
                    else if (isBleLive)
                      const Icon(Icons.sensors_rounded, size: 13, color: AppColors.safeGreenDark)
                    else
                      const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      timeLeftText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCritical ? FontWeight.w800 : FontWeight.w600,
                        color: isCritical
                            ? AppColors.urgentRed
                            : (isBleLive ? AppColors.safeGreenDark : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
