import 'dart:async';
import 'package:flutter/material.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';

class BleTestScreen extends StatefulWidget {
  const BleTestScreen({super.key});

  @override
  State<BleTestScreen> createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  final MilkoraBleService _bleService = MilkoraBleService();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Update "X seconds ago" display every second
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatLastUpdated() {
    if (_bleService.lastReadingTime == null) return 'No readings yet';
    final diff = DateTime.now().difference(_bleService.lastReadingTime!);
    if (diff.inSeconds < 2) return 'Just now (< 1s ago)';
    if (diff.inSeconds < 60) return '${diff.inSeconds} seconds ago';
    return '${diff.inMinutes} min ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MILKORA BLE TEST',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Developer Hardware Diagnostics',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _bleService,
        builder: (context, _) {
          final isConnected = _bleService.isConnected;
          final isLive = _bleService.isLive;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '--------------------------------\nMILKORA BLE TEST\n--------------------------------',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDiagRow('Device:', _bleService.deviceName, Colors.white),
                      _buildDiagRow(
                        'Status:',
                        isConnected ? 'CONNECTED ✓' : 'DISCONNECTED',
                        isConnected ? AppColors.safeGreen : AppColors.urgentRed,
                      ),
                      _buildDiagRow(
                        'Temperature:',
                        _bleService.liveTemperature != null
                            ? '${_bleService.liveTemperature} °C'
                            : '--.- °C',
                        Colors.amberAccent,
                      ),
                      _buildDiagRow('Data:', isLive ? 'LIVE ●' : 'OFFLINE ○', isLive ? Colors.greenAccent : Colors.white60),
                      _buildDiagRow('Last update:', _formatLastUpdated(), Colors.white70),
                      _buildDiagRow(
                        'BLE notifications:',
                        isConnected && isLive ? 'ACTIVE' : 'INACTIVE',
                        isConnected && isLive ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      _buildDiagRow('Raw payload:', _bleService.rawPayload.isNotEmpty ? _bleService.rawPayload : '(empty)', Colors.cyanAccent),
                      const SizedBox(height: 4),
                      const Text(
                        '--------------------------------',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // UUID Reference Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.perm_device_information, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'BLE Architecture Specs',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildUuidRow(
                        'Service UUID',
                        MilkoraBleService.primaryServiceUuid.toString(),
                      ),
                      const SizedBox(height: 8),
                      _buildUuidRow(
                        'Temp Characteristic UUID',
                        MilkoraBleService.primaryTempCharUuid.toString(),
                      ),
                      const SizedBox(height: 8),
                      _buildUuidRow('Hardware Sensor', 'DS18B20 on ESP32 GPIO 4'),
                      const SizedBox(height: 8),
                      _buildUuidRow('Watchdog Inactivity Timeout', '10 Seconds'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Control Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Commands',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_bleService.status == BleStatus.scanning) {
                                  _bleService.stopScan();
                                } else {
                                  _bleService.startScan();
                                }
                              },
                              icon: const Icon(Icons.search, size: 18),
                              label: Text(_bleService.status == BleStatus.scanning ? 'Stop Scan' : 'Scan BLE'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isConnected ? () => _bleService.disconnect() : null,
                              icon: const Icon(Icons.link_off, size: 18),
                              label: const Text('Disconnect'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiagRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUuidRow(String title, String uuid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          uuid,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
