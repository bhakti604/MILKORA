import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final CanStatus status;
  final bool isLarge;

  const StatusChip({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case CanStatus.safe:
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        icon = Icons.check_circle;
        label = 'SAFE';
        break;
      case CanStatus.checkSoon:
        bg = AppColors.tertiaryFixed;
        fg = AppColors.onTertiaryFixedVariant;
        icon = Icons.warning;
        label = 'CHECK SOON';
        break;
      case CanStatus.collectNow:
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        icon = Icons.error;
        label = 'COLLECT NOW';
        break;
    }

    final padding = isLarge
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final fontSize = isLarge ? 14.0 : 12.0;
    final iconSize = isLarge ? 18.0 : 16.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
