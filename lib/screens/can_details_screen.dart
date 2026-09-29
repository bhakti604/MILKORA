import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../models/temperature_data.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import '../widgets/can_vector_graphic.dart';
import '../widgets/linear_temperature_gauge.dart';
import '../widgets/sensor_metric_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/cold_chain_journey_widget.dart';
import '../widgets/ble_connection_sheet.dart';
import '../localization/language_provider.dart';

class CanDetailsScreen extends StatefulWidget {
  final MilkCan can;
  final VoidCallback onBack;
  final VoidCallback onMarkCollected;
  final VoidCallback? onViewHistory;

  const CanDetailsScreen({
    super.key,
    required this.can,
    required this.onBack,
    required this.onMarkCollected,
    this.onViewHistory,
  });

  @override
  State<CanDetailsScreen> createState() => _CanDetailsScreenState();
}

class _CanDetailsScreenState extends State<CanDetailsScreen> {
  int _selectedSegment = 0; // 0: Live, 1: Details, 2: Location

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final bool isHardwareCan = widget.can.id == 'CAN-001' ||
            widget.can.id == 'M-001' ||
            widget.can.name.contains('001') ||
            widget.can.name.contains('CAN-01');
        final bool isBleConnected = bleService.isConnected;
        final bool isBleLive = isHardwareCan && (bleService.isLive || (isBleConnected && bleService.liveTemperature != null));

        // Current real-time temperature: use live BLE data whenever connected or available
        final double currentTemp = (isHardwareCan && (isBleConnected || bleService.liveTemperature != null))
            ? (bleService.liveTemperature ?? widget.can.temperature)
            : widget.can.temperature;

        final tempStatus = TemperatureThresholds.evaluate(currentTemp);

        // Demo values for future sensors
        final String volumeText = '${(bleService.hardwareVolumeLiters ?? widget.can.volumeLiters).toStringAsFixed(1)} L';
        final String batteryText = '${bleService.hardwareBatteryPercent ?? widget.can.batteryLevel}%';
        final String lidText = bleService.lidStatusDisplay;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.liveMonitoring,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.can.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Share sensor telemetry
                        },
                        icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Can Header Card (Screen 4 Benchmark)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      // Stainless Steel Can Graphic
                      Container(
                        width: 72,
                        height: 96,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CanVectorGraphic(width: 54, height: 78, showDroplet: true),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Can Metadata & Connection Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.can.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => BleConnectionSheet.show(context),
                                  borderRadius: BorderRadius.circular(100),
                                  child: StatusPill.connection(
                                    isConnected: isBleConnected,
                                    isLive: isBleLive,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Bay 2 • Farmer: Ramesh Patel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'ID: #4092 • Batch: Morning-01',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Segmented Control Pills [Live] [Details] [Location]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      _buildSegmentItem(index: 0, label: strings.tabLive),
                      _buildSegmentItem(index: 1, label: strings.tabDetails),
                      _buildSegmentItem(index: 2, label: strings.tabLocation),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Segmented Views: [0: Live] [1: Details] [2: Location]
                if (_selectedSegment == 0) ...[
                  // Milk Temperature Card with Linear Range Gauge (Screen 4 Benchmark)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.thermostat_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              strings.milkTemperature,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${currentTemp.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusPill.fromTempStatus(tempStatus, isLarge: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LinearTemperatureGauge(
                          temperature: currentTemp,
                          minTemp: 0.0,
                          maxTemp: 12.0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2x2 Grid of Sensor Metrics
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: SensorMetricCard(
                          icon: Icons.battery_charging_full_rounded,
                          iconColor: AppColors.safeGreenDark,
                          iconBgColor: AppColors.safeGreenLight,
                          value: batteryText,
                          label: strings.battery,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SensorMetricCard(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          iconBgColor: const Color(0xFFEDE9FE),
                          value: lidText,
                          label: strings.lidStatus,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SensorMetricCard(
                          icon: Icons.access_time_rounded,
                          iconColor: AppColors.primaryDark,
                          iconBgColor: AppColors.primaryFixed,
                          value: '4 h 18 m',
                          label: strings.safeTimeLeft,
                        ),
                      ),
                    ],
                  ),
                ] else if (_selectedSegment == 1) ...[
                  // Details: Cold-Chain Journey Pipeline
                  ColdChainJourneyWidget(
                    currentTemp: currentTemp,
                    isLive: isBleLive,
                  ),
                ] else ...[
                  // Location Segment: Depot & Route Metadata
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'COLLECTION BAY LOCATION',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Village Collection Center • Sector 4',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Designated Bay: Bay 2\nAssigned Farmer: Ramesh Patel (#4092)\nAssigned Driver: Vikram Yadav (+91-9876543210)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 5. CTA Button: View Temperature History
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: widget.onViewHistory ?? widget.onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.show_chart_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          strings.viewHistoryBtn,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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

  Widget _buildSegmentItem({required int index, required String label}) {
    final isSelected = _selectedSegment == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSegment = index),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
