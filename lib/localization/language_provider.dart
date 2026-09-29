import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';
import 'app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;

  LanguageProvider._internal() {
    _loadLanguagePreference();
  }

  static const String _prefKey = 'milkora_selected_language';
  AppLanguage _currentLanguage = AppLanguage.english;

  final EnglishStrings _englishStrings = EnglishStrings();
  final HindiStrings _hindiStrings = HindiStrings();
  final MarathiStrings _marathiStrings = MarathiStrings();

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage.locale;

  AppStrings get strings {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return _hindiStrings;
      case AppLanguage.marathi:
        return _marathiStrings;
      case AppLanguage.english:
        return _englishStrings;
    }
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        _currentLanguage = AppLanguageExtension.fromCode(code);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Localization] Error loading language preference: $e');
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
      debugPrint('[Localization] Language switched & saved: ${language.displayName} (${language.code})');
    } catch (e) {
      debugPrint('[Localization] Error saving language preference: $e');
    }
  }
}
