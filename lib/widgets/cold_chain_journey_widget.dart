import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../localization/language_provider.dart';

class ColdChainJourneyWidget extends StatelessWidget {
  final double currentTemp;
  final bool isLive;

  const ColdChainJourneyWidget({
    super.key,
    required this.currentTemp,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = LanguageProvider().strings;

    final stages = [
      _JourneyStage(
        title: strings.stageFarm,
        subtitle: 'Milking & Can Seal',
        temp: '4.1°C',
        isCompleted: true,
        isActive: false,
      ),
      _JourneyStage(
        title: strings.stageCollection,
        subtitle: 'Village Center',
        temp: '4.8°C',
        isCompleted: true,
        isActive: false,
      ),
      _JourneyStage(
        title: strings.stageTransport,
        subtitle: strings.currentStageInTransit,
        temp: '${currentTemp.toStringAsFixed(1)}°C',
        isCompleted: false,
        isActive: true,
      ),
      _JourneyStage(
        title: strings.stageChilling,
        subtitle: 'Bulk Chilling Center',
        temp: 'Target ≤4°C',
        isCompleted: false,
        isActive: false,
      ),
      _JourneyStage(
        title: strings.stageDairy,
        subtitle: 'Processing Plant',
        temp: 'Intake QA',
        isCompleted: false,
        isActive: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                strings.coldChainJourney,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Text(
                'LIVE PIPELINE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal/Vertical Pipeline
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            separatorBuilder: (_, index) => Container(
              margin: const EdgeInsets.only(left: 17),
              height: 16,
              width: 2,
              color: stages[index].isCompleted
                  ? AppColors.safeGreen
                  : AppColors.surfaceContainer,
            ),
            itemBuilder: (context, index) {
              final stage = stages[index];
              return Row(
                children: [
                  // Step Indicator Node
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stage.isCompleted
                          ? AppColors.safeGreenBg
                          : (stage.isActive
                              ? AppColors.primaryFixed
                              : AppColors.surfaceContainerLow),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stage.isCompleted
                            ? AppColors.safeGreen
                            : (stage.isActive
                                ? AppColors.primary
                                : AppColors.border),
                        width: stage.isActive ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: stage.isCompleted
                          ? const Icon(Icons.check_rounded, size: 18, color: AppColors.safeGreenDark)
                          : (stage.isActive
                              ? const Icon(Icons.local_shipping_rounded, size: 18, color: AppColors.primary)
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textTertiary,
                                  ),
                                )),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Stage Titles
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: stage.isActive
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          stage.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperature Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stage.isActive
                          ? AppColors.primaryFixed
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      stage.temp,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: stage.isActive
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JourneyStage {
  final String title;
  final String subtitle;
  final String temp;
  final bool isCompleted;
  final bool isActive;

  _JourneyStage({
    required this.title,
    required this.subtitle,
    required this.temp,
    required this.isCompleted,
    required this.isActive,
  });
}
