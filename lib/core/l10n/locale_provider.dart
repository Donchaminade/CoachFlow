import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for managing app locale
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';
  
  LocaleNotifier() : super(const Locale('fr')) {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    try {
      final box = await Hive.openBox(_boxName);
      final savedLocale = box.get(_localeKey, defaultValue: 'fr') as String;
      state = Locale(savedLocale);
    } catch (e) {
      print('Error loading locale: $e');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_localeKey, locale.languageCode);
      state = locale;
    } catch (e) {
      print('Error saving locale: $e');
    }
  }
  
  void toggleLocale() {
    final newLocale = state.languageCode == 'fr' 
        ? const Locale('en') 
        : const Locale('fr');
    setLocale(newLocale);
  }
}

/// Provider instance
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
