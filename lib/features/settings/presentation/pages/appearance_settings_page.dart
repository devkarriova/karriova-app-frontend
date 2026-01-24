import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  String _themeMode = 'system'; // light, dark, system
  String _accentColor = 'blue';
  double _textScale = 1.0;
  bool _reduceMotion = false;

  @override
  Widget build(BuildContext context) {
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
          _buildSection(
            context,
            title: 'Accent Color',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildColorOption('blue', AppColors.primary),
                    _buildColorOption('purple', Colors.purple),
                    _buildColorOption('green', Colors.green),
                    _buildColorOption('orange', Colors.orange),
                    _buildColorOption('pink', Colors.pink),
                    _buildColorOption('teal', Colors.teal),
                  ],
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Text Size',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _textScale,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        onChanged: (value) {
                          setState(() => _textScale = value);
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'This is a preview of your text size setting.',
                    style: TextStyle(fontSize: 14 * _textScale),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          _buildSection(
            context,
            title: 'Accessibility',
            children: [
              SwitchListTile(
                title: const Text('Reduce Motion'),
                subtitle: const Text('Minimize animations and transitions'),
                value: _reduceMotion,
                onChanged: (value) {
                  setState(() => _reduceMotion = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Settings'),
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
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildColorOption(String name, Color color) {
    final isSelected = _accentColor == name;
    return GestureDetector(
      onTap: () {
        setState(() => _accentColor = name);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  void _saveSettings() {
    // TODO: Save appearance settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appearance settings saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
