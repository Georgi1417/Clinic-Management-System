import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, bg }

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.en);

  void setLanguage(AppLanguage language) {
    state = language;
  }

  Locale get locale {
    switch (state) {
      case AppLanguage.bg:
        return const Locale('bg', 'BG');
      case AppLanguage.en:
      return const Locale('en', 'US');
    }
  }
}
