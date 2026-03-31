import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/services/user_settings_service.dart';
import 'package:karriova_app/core/theme/theme_cubit.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  final _settingsService = GetIt.instance<UserSettingsService>();
  
  // Loading state
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  String _themeMode = 'system'; // light, dark, system

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final settings = await _settingsService.getAppearanceSettings();

      setState(() {
        _themeMode = settings.theme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appearance'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appearance'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load settings', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadSettings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Theme',
            children: [
              RadioListTile<String>(
                title: const Text('Light'),
                secondary: const Icon(Icons.light_mode_outlined),
                value: 'light',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() => _themeMode = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: 'dark',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() => _themeMode = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('System Default'),
                secondary: const Icon(Icons.settings_brightness_outlined),
                value: 'system',
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() => _themeMode = value!);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      await _settingsService.updateAppearanceSettings(
        AppearanceSettings(
          theme: _themeMode,
        ),
      );

      // Update theme immediately
      final themeCubit = GetIt.instance<ThemeCubit>();
      switch (_themeMode) {
        case 'light':
          themeCubit.setTheme(ThemeMode.light);
          break;
        case 'dark':
          themeCubit.setTheme(ThemeMode.dark);
          break;
        case 'system':
        default:
          themeCubit.setTheme(ThemeMode.system);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appearance settings saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
