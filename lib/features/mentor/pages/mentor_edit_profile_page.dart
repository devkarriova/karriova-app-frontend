import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';

class MentorEditProfilePage extends StatefulWidget {
  const MentorEditProfilePage({super.key});

  @override
  State<MentorEditProfilePage> createState() => _MentorEditProfilePageState();
}

class _MentorEditProfilePageState extends State<MentorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _expertiseController = TextEditingController();

  int _yearsExperience = 0;
  bool _isAvailable = true;
  List<String> _streams = [];
  List<String> _expertise = [];
  bool _loading = true;
  bool _saving = false;

  static const _allStreams = [
    'Science PCM', 'Science PCB', 'Science PCMB',
    'Commerce', 'Arts/Humanities', 'Vocational', 'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _roleController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final api = getIt<ApiClient>();
      final resp = await api.get('/mentor/profile');
      if (resp.isSuccess && resp.data != null) {
        final p = resp.data as Map<String, dynamic>;
        setState(() {
          _roleController.text = p['current_role'] as String? ?? '';
          _bioController.text = p['bio'] as String? ?? '';
          _linkedinController.text = p['linkedin_url'] as String? ?? '';
          _yearsExperience = p['years_experience'] as int? ?? 0;
          _isAvailable = p['is_available'] as bool? ?? true;
          _streams = (p['streams'] as List?)?.cast<String>() ?? [];
          _expertise = (p['expertise'] as List?)?.cast<String>() ?? [];
          _expertiseController.text = _expertise.join(', ');
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Parse expertise from comma-separated text
    final expertiseList = _expertiseController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _saving = true);
    try {
      final api = getIt<ApiClient>();
      final body = <String, dynamic>{
        'current_role': _roleController.text.trim(),
        'bio': _bioController.text.trim(),
        'linkedin_url': _linkedinController.text.trim(),
        'years_experience': _yearsExperience,
        'is_available': _isAvailable,
        'streams': _streams,
        'expertise': expertiseList,
      };
      final resp = await api.put('/mentor/profile', body: body);
      if (!mounted) return;
      if (resp.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.errorMessage ?? 'Failed to save'), backgroundColor: AppColors.error),
        );
        setState(() => _saving = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Mentor Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Professional Info', [
                _buildField('Current Role', _roleController,
                    hint: 'e.g. Senior Engineer at Google'),
                const SizedBox(height: 12),
                _buildLabel('Years of Experience'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() { if (_yearsExperience > 0) _yearsExperience--; }),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Text('$_yearsExperience', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(
                      onPressed: () => setState(() => _yearsExperience++),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                    const Text('years', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField('LinkedIn URL', _linkedinController,
                    hint: 'https://linkedin.com/in/yourprofile',
                    keyboardType: TextInputType.url,
                    required: false),
              ]),

              const SizedBox(height: 16),

              _buildSection('About You', [
                _buildField('Bio', _bioController,
                    hint: 'Tell students about your background and how you can help...',
                    maxLines: 4,
                    required: false),
              ]),

              const SizedBox(height: 16),

              _buildSection('Expertise', [
                _buildLabel('Areas of Expertise (comma-separated)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _expertiseController,
                  decoration: _inputDecoration(
                    hint: 'Software Engineering, Data Science, Product Management',
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              _buildSection('Streams You Guide', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allStreams.map((s) {
                    final selected = _streams.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _streams.add(s);
                          } else {
                            _streams.remove(s);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
              ]),

              const SizedBox(height: 16),

              _buildSection('Availability', [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available for connect requests',
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  subtitle: const Text('Students can only connect when you\'re available',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  value: _isAvailable,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
              ]),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary));
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint: hint ?? ''),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
