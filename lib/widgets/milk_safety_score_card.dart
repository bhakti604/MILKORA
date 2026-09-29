import 'package:flutter/material.dart';
import '../models/temperature_data.dart';
import '../theme/app_theme.dart';

import '../localization/language_provider.dart';

class MilkSafetyScoreCard extends StatelessWidget {
  final double? currentTemp;
  final bool isLive;

  const MilkSafetyScoreCard({
    super.key,
    required this.currentTemp,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final temp = currentTemp ?? 6.3;
    final status = TemperatureThresholds.evaluate(temp);
    final strings = LanguageProvider().strings;

    int score;
    String conditionText;
    Color conditionColor;
    Color scoreBg;

    switch (status) {
      case TemperatureStatus.safe:
        score = (98 - (temp - 4.0) * 1.5).round().clamp(90, 98);
        conditionText = strings.excellentColdChain;
        conditionColor = AppColors.safeGreenDark;
        scoreBg = AppColors.safeGreenBg;
        break;
      case TemperatureStatus.low:
        score = 88;
        conditionText = strings.chilledDeepCold;
        conditionColor = AppColors.lowBlueDark;
        scoreBg = AppColors.lowBlueBg;
        break;
      case TemperatureStatus.warning:
        score = 68;
        conditionText = strings.elevatedRisk;
        conditionColor = AppColors.warningDark;
        scoreBg = AppColors.warningBg;
        break;
      case TemperatureStatus.critical:
        score = 32;
        conditionText = strings.criticalSpoilage;
        conditionColor = AppColors.errorDark;
        scoreBg = AppColors.errorBg;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Circular Score Meter
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scoreBg,
              shape: BoxShape.circle,
              border: Border.all(color: conditionColor.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: conditionColor,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Score Information & Condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      strings.milkSafetyScore,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  conditionText,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: conditionColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Estimated cold-chain quality index based on current temperature',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
