import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import '../widgets/temperature_chart_widget.dart';
import '../localization/language_provider.dart';

class PreviousRecordsScreen extends StatefulWidget {
  final MilkCan selectedCan;
  final List<MilkCan> allCans;
  final ValueChanged<MilkCan> onSelectCan;

  const PreviousRecordsScreen({
    super.key,
    required this.selectedCan,
    required this.allCans,
    required this.onSelectCan,
  });

  @override
  State<PreviousRecordsScreen> createState() => _PreviousRecordsScreenState();
}

class _PreviousRecordsScreenState extends State<PreviousRecordsScreen> {
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final bool isHardwareCan = widget.selectedCan.id == 'CAN-001' || widget.selectedCan.id == 'M-001';
        final bool isBleLive = isHardwareCan && bleService.isLive;

        // Highest, Lowest, Average: computed dynamically from BLE data when available, otherwise demo defaults
        final double highest = (isHardwareCan && bleService.highestTemp != null)
            ? bleService.highestTemp!
            : 8.2;
        final double lowest = (isHardwareCan && bleService.lowestTemp != null)
            ? bleService.lowestTemp!
            : 5.6;
        final double average = (isHardwareCan && bleService.averageTemp != null)
            ? bleService.averageTemp!
            : 6.7;

        final double currentTemp = (isHardwareCan && bleService.liveTemperature != null)
            ? bleService.liveTemperature!
            : 6.3;

        final String timeString = isBleLive && bleService.lastReadingTime != null
            ? '${bleService.lastReadingTime!.hour.toString().padLeft(2, '0')}:${bleService.lastReadingTime!.minute.toString().padLeft(2, '0')} ${bleService.lastReadingTime!.hour >= 12 ? 'PM' : 'AM'}'
            : '09:41 AM';

        // Sample data points matching the curve in Screen 6
        final chartPoints = [
          const TemperatureDataPoint(temp: 5.8, timeLabel: '12AM'),
          const TemperatureDataPoint(temp: 5.4, timeLabel: '4AM'),
          TemperatureDataPoint(temp: currentTemp, timeLabel: '8AM'),
          const TemperatureDataPoint(temp: 6.8, timeLabel: '12PM'),
          const TemperatureDataPoint(temp: 6.2, timeLabel: '4PM'),
          const TemperatureDataPoint(temp: 5.9, timeLabel: '8PM'),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Screen Title & Subtitle
                Text(
                  strings.historyTitle,
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
                  strings.historySubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Dropdowns Row (Screen 6 Benchmark)
                Row(
                  children: [
                    // Can Selector Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: AppColors.subtleShadow,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<MilkCan>(
                            value: widget.allCans.firstWhere(
                              (c) => c.id == widget.selectedCan.id,
                              orElse: () => widget.allCans.first,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                            isExpanded: true,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: widget.allCans.map((can) {
                              return DropdownMenuItem<MilkCan>(
                                value: can,
                                child: Text(can.name),
                              );
                            }).toList(),
                            onChanged: (can) {
                              if (can != null) widget.onSelectCan(can);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Period Selector Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: AppColors.subtleShadow,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          items: [
                            DropdownMenuItem(value: 'Today', child: Text(strings.periodToday)),
                            DropdownMenuItem(value: 'Yesterday', child: Text(strings.periodYesterday)),
                            DropdownMenuItem(value: 'This Week', child: Text(strings.periodThisWeek)),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPeriod = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main Temperature Line Chart (Screen 6 Benchmark)
                TemperatureChartWidget(
                  dataPoints: chartPoints,
                  currentTemp: currentTemp,
                  currentTime: timeString,
                  isLive: isBleLive,
                ),

                const SizedBox(height: 16),

                // 2x2 Statistics Summary Grid (Screen 6 Benchmark)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.urgentRed,
                        value: '${highest.toStringAsFixed(1)}°C',
                        label: strings.highest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppColors.lowBlue,
                        value: '${lowest.toStringAsFixed(1)}°C',
                        label: strings.lowest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.functions_rounded,
                        iconColor: AppColors.primary,
                        value: '${average.toStringAsFixed(1)}°C',
                        label: strings.average,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.verified_user_rounded,
                        iconColor: AppColors.safeGreenDark,
                        value: '96.4%',
                        label: strings.timeInSafeZone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Overall Result & Cold-Chain Health Banner Card (Screen 6 Benchmark)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.safeGreenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: AppColors.safeGreenDark, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${strings.coldChainHealth}: 96.4% ${strings.optimalLabel}',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.safeGreenDark,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Milk was preserved within the 4°C — 8°C optimal safety window throughout collection and transit.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Disconnected notice if hardware can selected but offline
                if (isHardwareCan && !isBleLive && bleService.liveHistory.isEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Sensor History Unavailable (Connect MILKORA-CAN-01 via BLE for real-time telemetry logging)',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
}
