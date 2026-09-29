import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/milk_can.dart';
import '../models/temperature_data.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';
import '../localization/language_provider.dart';

class ImportantAlertsScreen extends StatefulWidget {
  final List<MilkCan> cans;
  final ValueChanged<MilkCan> onSelectCan;

  const ImportantAlertsScreen({
    super.key,
    required this.cans,
    required this.onSelectCan,
  });

  @override
  State<ImportantAlertsScreen> createState() => _ImportantAlertsScreenState();
}

class _ImportantAlertsScreenState extends State<ImportantAlertsScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Critical, 2: Warning, 3: Safe

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();
    final strings = LanguageProvider().strings;

    return ListenableBuilder(
      listenable: bleService,
      builder: (context, _) {
        final liveAlerts = bleService.alerts;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Titles
                Text(
                  strings.alertsTitle,
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
                  strings.alertsSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Chips Row (Screen 5 Benchmark)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        index: 0,
                        label: '${strings.filterAll} ${3 + liveAlerts.length}',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryFixed,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        index: 1,
                        label: '${strings.filterCritical} ${1 + liveAlerts.where((a) => a.status == TemperatureStatus.critical).length}',
                        color: AppColors.errorDark,
                        bgColor: AppColors.errorLight,
                        icon: Icons.error_outline_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        index: 2,
                        label: '${strings.filterWarning} ${1 + liveAlerts.where((a) => a.status == TemperatureStatus.warning).length}',
                        color: AppColors.warningDark,
                        bgColor: AppColors.warningLight,
                        icon: Icons.warning_amber_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        index: 3,
                        label: strings.filterSafe,
                        color: AppColors.safeGreenDark,
                        bgColor: AppColors.safeGreenLight,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 1. Live Hardware BLE Alerts (if triggered)
                if (liveAlerts.isNotEmpty) ...[
                  ...liveAlerts.map((alert) => _buildLiveBleAlertCard(alert)),
                  const SizedBox(height: 12),
                ],

                // 2. Demo Critical Alert (Can M-004)
                if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
                  _buildCriticalAlertCard(
                    canId: 'Can M-004',
                    temp: '9.6°C',
                    timestamp: '09:38 AM',
                    message: 'Milk may become unsafe. Please collect this can first.',
                    meta: 'Bay 2 • Farmer: Ramesh Patel (ID: #4092)',
                    driverPhone: '+919876543210',
                    onDetails: () {
                      final can = widget.cans.firstWhere((c) => c.id == 'CAN-004', orElse: () => widget.cans.first);
                      widget.onSelectCan(can);
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. Demo Warning Alert (Can M-003)
                if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
                  _buildWarningAlertCard(
                    canId: 'Can M-003',
                    temp: '8.4°C',
                    timestamp: '09:22 AM',
                    message: 'Temperature is above safe range. Monitor closely.',
                    meta: 'Bay 1 • Farmer: Suresh Yadav',
                    onDetails: () {
                      final can = widget.cans.firstWhere((c) => c.id == 'CAN-003', orElse: () => widget.cans.first);
                      widget.onSelectCan(can);
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // 4. Demo Safe / Recovery Event (Can M-002)
                if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
                  _buildSafeAlertCard(
                    canId: 'Can M-002',
                    temp: '7.1°C',
                    timestamp: '08:10 AM',
                    message: 'Stabilized in safe temperature window.',
                    meta: 'Bay 3 • Farmer: Anil Sharma',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required int index,
    required String label,
    required Color color,
    required Color bgColor,
    IconData? icon,
  }) {
    final isSelected = _selectedFilterIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
          boxShadow: isSelected ? AppColors.subtleShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlertCard({
    required String canId,
    required String temp,
    required String timestamp,
    required String message,
    required String meta,
    required String driverPhone,
    required VoidCallback onDetails,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.urgentRed.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. WHAT: Alert Type & Priority
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.errorDark, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CRITICAL SPOILAGE RISK',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. WHERE & 3. TEMPERATURE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canId,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.urgentRed.withValues(alpha: 0.3)),
                ),
                child: Text(
                  temp,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4. WHY IT MATTERS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.urgentRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.errorDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$message Temperature exceeded critical threshold ($temp). Urgent risk of bacterial multiplication.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorDark,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5. WHAT ACTION TO TAKE
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:$driverPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text(
                    'COLLECT NOW →',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onDetails,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(100, 46),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningAlertCard({
    required String canId,
    required String temp,
    required String timestamp,
    required String message,
    required String meta,
    required VoidCallback onDetails,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.warningDark, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Temperature Rising',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                canId,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                temp,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warningDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warningDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            meta,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onDetails,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Details',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeAlertCard({
    required String canId,
    required String temp,
    required String timestamp,
    required String message,
    required String meta,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.subtleShadow,
        border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.safeGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.safeGreenDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'TEMPERATURE RECOVERED',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.safeGreenDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timestamp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      canId,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      temp,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.safeGreenDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Temperature returned to the safe range (4°C — 8°C). Cold-chain stability restored.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBleAlertCard(LiveAlertItem alert) {
    final isCritical = alert.status == TemperatureStatus.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isCritical ? AppColors.urgentRed : AppColors.warningAmber,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
                color: isCritical ? AppColors.errorDark : AppColors.warningDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LIVE SENSOR ALERT: ${alert.canId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isCritical ? AppColors.errorDark : AppColors.warningDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (alert.recommendedAction.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCritical ? AppColors.errorBg : AppColors.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    size: 16,
                    color: isCritical ? AppColors.errorDark : AppColors.warningDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Action: ${alert.recommendedAction}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCritical ? AppColors.errorDark : AppColors.warningDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
