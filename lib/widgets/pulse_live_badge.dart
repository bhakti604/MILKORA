import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulseLiveBadge extends StatefulWidget {
  final bool isLive;
  final bool isConnected;
  final bool isStale;
  final String? customLabel;

  const PulseLiveBadge({
    super.key,
    required this.isLive,
    required this.isConnected,
    this.isStale = false,
    this.customLabel,
  });

  @override
  State<PulseLiveBadge> createState() => _PulseLiveBadgeState();
}

class _PulseLiveBadgeState extends State<PulseLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isStale) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warningDark),
            SizedBox(width: 4),
            Text(
              'STALE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.warningDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    if (!widget.isConnected && !widget.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.circle_outlined, size: 9, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Active Live BLE Stream with Pulse Animation
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.safeGreenBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Pulsing Dot
          SizedBox(
            width: 12,
            height: 12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isLive)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.safeGreen.withValues(
                              alpha: _opacityAnimation.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.safeGreenDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.customLabel ?? (widget.isLive ? 'LIVE' : 'CONNECTED'),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.safeGreenDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
