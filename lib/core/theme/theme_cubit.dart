import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karriova_app/core/services/user_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemePrefKey = 'theme_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  final UserSettingsService _settingsService;
  final SharedPreferences _prefs;

  ThemeCubit(this._settingsService, this._prefs) : super(ThemeMode.system) {
    _loadLocalTheme();
  }

  /// Instantly applies the locally cached theme without any network call.
  void _loadLocalTheme() {
    final saved = _prefs.getString(_kThemePrefKey);
    if (saved != null) {
      emit(_parseThemeMode(saved));
    }
  }

  /// Fetches theme from the API (requires auth) and syncs local cache.
  /// Call this after the user has authenticated.
  Future<void> loadThemePreference() async {
    try {
      final settings = await _settingsService.getAppearanceSettings();
      final themeMode = _parseThemeMode(settings.theme);
      await _prefs.setString(_kThemePrefKey, settings.theme);
      emit(themeMode);
    } catch (_) {
      // API unavailable or unauthenticated — keep the locally cached value.
    }
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(_kThemePrefKey, _themeModeToString(mode));
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

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
