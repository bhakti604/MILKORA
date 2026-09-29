import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  hindi,
  marathi,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.marathi:
        return 'मराठी';
    }
  }

  String get nativeName => displayName;

  String get englishName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'Hindi';
      case AppLanguage.marathi:
        return 'Marathi';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en', 'US');
      case AppLanguage.hindi:
        return const Locale('hi', 'IN');
      case AppLanguage.marathi:
        return const Locale('mr', 'IN');
    }
  }

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'hi':
        return AppLanguage.hindi;
      case 'mr':
        return AppLanguage.marathi;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }
}
