import 'package:flutter/material.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import 'ble_connection_sheet.dart';

import '../localization/language_provider.dart';

class BleConnectionPanel extends StatelessWidget {
  const BleConnectionPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const BleConnectionPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final isConnected = bleService.isConnected;
        final isLive = bleService.isLive;
        final isStale = bleService.isSensorLost;
        final temp = bleService.liveTemperature;

        // Calculate time ago
        String updateAgo = strings.offline;
        if (bleService.lastReadingTime != null) {
          final diffSec = DateTime.now().difference(bleService.lastReadingTime!).inSeconds;
          updateAgo = diffSec < 2 ? strings.justNow : strings.secAgo(diffSec);
        }

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Handle Pill
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title & Status
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isLive
                            ? AppColors.safeGreenBg
                            : (isConnected ? AppColors.primaryFixed : AppColors.surfaceContainerLow),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLive
                            ? Icons.bluetooth_connected_rounded
                            : (isConnected ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded),
                        color: isLive
                            ? AppColors.safeGreenDark
                            : (isConnected ? AppColors.primary : AppColors.textSecondary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MILKORA CAN',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isLive
                                      ? AppColors.safeGreenDark
                                      : (isStale ? AppColors.warningAmber : AppColors.textTertiary),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isLive
                                    ? '● ${strings.connected.toUpperCase()}'
                                    : (isStale
                                        ? '⚠ ${strings.sensorLost.toUpperCase()}'
                                        : (isConnected ? '● ${strings.connected.toUpperCase()}' : '○ ${strings.disconnected.toUpperCase()}')),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isLive
                                      ? AppColors.safeGreenDark
                                      : (isStale ? AppColors.warningDark : AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Telemetry Info Matrix
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(strings.hardwareId, bleService.deviceName),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildInfoRow(strings.signalQuality, isConnected ? 'Good (-62 dBm)' : strings.offline),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildInfoRow(strings.lastReading, temp != null ? '${temp.toStringAsFixed(1)}°C' : 'None'),
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildInfoRow(strings.probeLatency, updateAgo),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Actions: Scan / Reconnect or Advanced Scanner
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (!isConnected) {
                            bleService.startScan();
                          } else {
                            bleService.disconnect();
                          }
                        },
                        icon: Icon(
                          isConnected ? Icons.link_off_rounded : Icons.refresh_rounded,
                          size: 18,
                        ),
                        label: Text(isConnected ? strings.disconnectBtn : strings.scanAndConnect),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConnected ? AppColors.errorDark : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        BleConnectionSheet.show(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(90, 48),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text(
                        strings.detailsBtn,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
