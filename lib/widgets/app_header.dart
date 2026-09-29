import 'package:flutter/material.dart';
import '../services/milkora_ble_service.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leadingAction;
  final VoidCallback? onBleTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showBrandHeader;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingAction,
    this.onBleTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.showBrandHeader = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final bleService = MilkoraBleService();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left: Leading action or Menu icon
              leadingAction ??
                  InkWell(
                    onTap: () {
                      // Open drawer or actions
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),

              const SizedBox(width: 12),

              // Center / Title Area
              Expanded(
                child: showBrandHeader
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  'assets/images/milkora_logo.png',
                                  height: 26,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.eco_rounded,
                                    size: 20,
                                    color: AppColors.safeGreenDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'MILKORA',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            subtitle ?? 'Smart Milk Monitoring',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
              ),

              const SizedBox(width: 12),

              // Right Actions: BLE Pill, Notification Bell, Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Interactive BLE Status Action Button
                  ListenableBuilder(
                    listenable: bleService,
                    builder: (context, _) {
                      final isLive = bleService.isLive;
                      final isConnected = bleService.isConnected;

                      return InkWell(
                        onTap: onBleTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLive
                                ? AppColors.safeGreenBg
                                : (isConnected ? AppColors.primaryFixed : AppColors.surfaceContainerLow),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLive
                                  ? AppColors.safeGreen.withValues(alpha: 0.4)
                                  : (isConnected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight),
                            ),
                          ),
                          child: Icon(
                            isLive
                                ? Icons.bluetooth_connected_rounded
                                : (isConnected ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded),
                            color: isLive
                                ? AppColors.safeGreenDark
                                : (isConnected ? AppColors.primary : AppColors.textSecondary),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  // Notification Bell Icon with Badge
                  InkWell(
                    onTap: onNotificationTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.urgentRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (onProfileTap != null) ...[
                    const SizedBox(width: 8),
                    // Profile Avatar
                    InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
