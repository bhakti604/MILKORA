import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/can_vector_graphic.dart';
import '../localization/language_provider.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final langProvider = LanguageProvider();

    return ListenableBuilder(
      listenable: langProvider,
      builder: (context, _) {
        final strings = langProvider.strings;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F2FE), // Soft sky blue
                  AppColors.background, // Fresh milk cream tone (#FFF9ED)
                ],
                stops: [0.0, 0.45],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          // Official Milkora Logo
                          Image.asset(
                            'assets/images/milkora_logo.png',
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Text(
                              'MILKORA',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            strings.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // National Mission Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              strings.nationalMission,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Hero Can Graphic with Milk Splash Aesthetics
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Soft Glow Circle
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      const Color(0xFFBAE6FD).withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.4, 0.7, 1.0],
                                  ),
                                ),
                              ),

                              // Vector Milk Can
                              const CanVectorGraphic(
                                width: 140,
                                height: 190,
                                showDroplet: true,
                                showGlow: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // 3 Feature Pills Row (matching reference image)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFeaturePill(
                                icon: Icons.thermostat_rounded,
                                iconColor: AppColors.primary,
                                iconBg: const Color(0xFFE0F2FE),
                                label: strings.monitorTempTitle,
                              ),
                              _buildFeaturePill(
                                icon: Icons.ac_unit_rounded,
                                iconColor: const Color(0xFF0284C7),
                                iconBg: const Color(0xFFE0F2FE),
                                label: strings.preventSpoilageTitle,
                              ),
                              _buildFeaturePill(
                                icon: Icons.verified_user_rounded,
                                iconColor: AppColors.safeGreenDark,
                                iconBg: const Color(0xFFDCFCE7),
                                label: strings.ensureQualityTitle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section: CTA Button & Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: onGetStarted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  strings.getStartedBtn,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              size: 16,
                              color: AppColors.safeGreenDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.techEcosystem,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.subtleShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
