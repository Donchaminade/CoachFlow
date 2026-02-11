import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ThemeMode provider with Hive persistence
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);
    final themeIndex = box.get(_themeKey, defaultValue: 0) as int;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, mode.index);
  }
}

// Notifications enabled provider with Hive persistence
final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<bool> {
  static const String _boxName = 'settings';
  static const String _notifKey = 'notifications_enabled';

  NotificationsNotifier() : super(true) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final box = await Hive.openBox(_boxName);
    state = box.get(_notifKey, defaultValue: true) as bool;
  }

  Future<void> toggle() async {
    state = !state;
    final box = await Hive.openBox(_boxName);
    await box.put(_notifKey, state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final box = await Hive.openBox(_boxName);
    await box.put(_notifKey, enabled);
  }
}
