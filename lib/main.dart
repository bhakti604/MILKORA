import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/language_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MilkoraApp());
}

class MilkoraApp extends StatefulWidget {
  const MilkoraApp({super.key});

  @override
  State<MilkoraApp> createState() => _MilkoraAppState();
}

class _MilkoraAppState extends State<MilkoraApp> {
  bool _hasStarted = false;
  final LanguageProvider _langProvider = LanguageProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _langProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'MILKORA - Milk Safety Monitor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: _langProvider.currentLocale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('hi', 'IN'),
            Locale('mr', 'IN'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _hasStarted
              ? const MainNavigationScreen()
              : WelcomeScreen(
                  onGetStarted: () {
                    setState(() {
                      _hasStarted = true;
                    });
                  },
                ),
        );
      },
    );
  }
}
