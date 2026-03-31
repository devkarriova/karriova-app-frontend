import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karriova_app/core/services/user_settings_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final UserSettingsService _settingsService;

  ThemeCubit(this._settingsService) : super(ThemeMode.system);

  Future<void> loadThemePreference() async {
    try {
      final settings = await _settingsService.getAppearanceSettings();
      final themeMode = _parseThemeMode(settings.theme);
      emit(themeMode);
    } catch (e) {
      // If loading fails, keep system default
      emit(ThemeMode.system);
    }
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  ThemeMode _parseThemeMode(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
