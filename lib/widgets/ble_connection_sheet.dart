import 'package:flutter/material.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';

class BleConnectionSheet extends StatefulWidget {
  const BleConnectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BleConnectionSheet(),
    );
  }

  @override
  State<BleConnectionSheet> createState() => _BleConnectionSheetState();
}

class _BleConnectionSheetState extends State<BleConnectionSheet> {
  final MilkoraBleService _bleService = MilkoraBleService();

  @override
  void initState() {
    super.initState();
    if (!_bleService.isConnected && _bleService.status != BleStatus.scanning) {
      _bleService.startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _bleService,
      builder: (context, _) {
        final isConnected = _bleService.isConnected;
        final isScanning = _bleService.status == BleStatus.scanning;
        final isConnecting = _bleService.status == BleStatus.connecting;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Drag Bar
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppColors.secondaryContainer
                              : AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                          color: isConnected ? AppColors.safeGreenDark : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connect Milk Can',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            isConnected
                                ? 'Connected to ${_bleService.deviceName}'
                                : (isScanning ? 'Searching for nearby cans...' : 'Bluetooth Low Energy (BLE)'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error or Warning Notice
              if (_bleService.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.urgentRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _bleService.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.onErrorContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Connected Device Card
              if (isConnected) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.safeGreen, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sensors, color: AppColors.safeGreen, size: 28),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _bleService.deviceName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 14, color: AppColors.safeGreenDark),
                                      SizedBox(width: 4),
                                      Text(
                                        'Connected ✓',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.safeGreenDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_bleService.liveTemperature != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.safeGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_bleService.liveTemperature} °C',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _bleService.disconnect(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.urgentRed,
                                side: const BorderSide(color: AppColors.urgentRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.link_off, size: 18),
                              label: const Text('Disconnect'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Discovered Devices List
                if (_bleService.discoveredDevices.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (isScanning || isConnecting) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            isConnecting ? 'Connecting...' : 'Scanning for MILKORA-CAN-01...',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hold your phone near the milk can',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.bluetooth_searching, size: 48, color: AppColors.outline),
                          const SizedBox(height: 12),
                          const Text(
                            'No MILKORA can found nearby.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ensure your milk can ESP32 is powered on.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _bleService.discoveredDevices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final scanResult = _bleService.discoveredDevices[index];
                      final name = scanResult.device.platformName.isNotEmpty
                          ? scanResult.device.platformName
                          : scanResult.advertisementData.advName;
                      final isTarget = name.toUpperCase().contains('MILKORA') ||
                          name.toUpperCase().contains('CAN-01');

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: isTarget
                              ? Border.all(color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_drink,
                                  color: isTarget ? AppColors.primary : AppColors.outline,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isNotEmpty ? name : 'Unknown Device',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isTarget ? AppColors.primary : AppColors.onSurface,
                                      ),
                                    ),
                                    const Text(
                                      'Available',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.safeGreenDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: isConnecting
                                  ? null
                                  : () => _bleService.connectToDevice(scanResult.device),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(90, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                backgroundColor: isTarget ? AppColors.primary : AppColors.surfaceContainerHigh,
                                foregroundColor: isTarget ? AppColors.onPrimary : AppColors.onSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                isConnecting ? 'Connecting...' : 'Connect',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),

                // Main Scan / Rescan Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isScanning
                        ? () => _bleService.stopScan()
                        : () => _bleService.startScan(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.search, size: 22),
                    label: Text(
                      isScanning ? 'STOPPING SCAN...' : 'SCAN FOR MILK CAN',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
