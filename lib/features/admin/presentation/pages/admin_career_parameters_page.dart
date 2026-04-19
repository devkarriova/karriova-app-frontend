import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/di/injection.dart';

/// Groups the 21 parameters into 4 KIT categories
const _parameterCategories = {
  'Personality': ['thinking_style', 'work_style', 'social_energy', 'risk_handling', 'stress_response'],
  'RIASEC Interest': ['realistic', 'investigative', 'artistic', 'social', 'enterprising', 'conventional'],
  'Aptitude': ['logical_reasoning', 'numerical_ability', 'communication_ability', 'creativity', 'technical'],
  'Career Orientation': ['leadership', 'entrepreneurial', 'stability', 'independence', 'team_orientation'],
};

const _parameterDisplayNames = {
  'thinking_style': 'Thinking Style',
  'work_style': 'Work Style',
  'social_energy': 'Social Energy',
  'risk_handling': 'Risk Handling',
  'stress_response': 'Stress Response',
  'realistic': 'Realistic (R)',
  'investigative': 'Investigative (I)',
  'artistic': 'Artistic (A)',
  'social': 'Social (S)',
  'enterprising': 'Enterprising (E)',
  'conventional': 'Conventional (C)',
  'logical_reasoning': 'Logical Reasoning',
  'numerical_ability': 'Numerical Ability',
  'communication_ability': 'Communication',
  'creativity': 'Creativity',
  'technical': 'Technical',
  'leadership': 'Leadership',
  'entrepreneurial': 'Entrepreneurial',
  'stability': 'Stability',
  'independence': 'Independence',
  'team_orientation': 'Team Orientation',
};

class AdminCareerParametersPage extends StatefulWidget {
  final String careerId;
  final Map<String, dynamic>? careerData;

  const AdminCareerParametersPage({
    super.key,
    required this.careerId,
    this.careerData,
  });

  @override
  State<AdminCareerParametersPage> createState() => _AdminCareerParametersPageState();
}

class _AdminCareerParametersPageState extends State<AdminCareerParametersPage> {
  final _dio = getIt<Dio>();
  Map<String, double> _scores = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _careerName = '';

  @override
  void initState() {
    super.initState();
    _careerName = widget.careerData?['name'] as String? ?? 'Career';
    _loadParameters();
  }

  Future<void> _loadParameters() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _dio.get('/api/v1/admin/careers/${widget.careerId}/parameters');
      final data = res.data as Map<String, dynamic>;
      final targets = List<Map<String, dynamic>>.from(data['targets'] ?? []);

      final scores = <String, double>{};
      // Initialize all 21 to 50 (neutral)
      for (final code in _parameterDisplayNames.keys) {
        scores[code] = 50.0;
      }
      for (final t in targets) {
        final code = t['parameter_code'] as String?;
        final score = (t['ideal_score'] as num?)?.toDouble() ?? 50.0;
        if (code != null) scores[code] = score;
      }

      setState(() { _scores = scores; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    setState(() { _saving = true; });
    try {
      final targets = _scores.entries.map((e) => {
        'parameter_code': e.key,
        'ideal_score': e.value,
      }).toList();

      await _dio.put(
        '/api/v1/admin/careers/${widget.careerId}/parameters',
        data: {'targets': targets},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parameters saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const AppNavigationBar(currentRoute: AppRouter.admin),
            Expanded(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => context.go(AppRouter.adminCareers),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_careerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const Text('Ideal parameter scores (0–100)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (_saving)
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: _save,
                            icon: const Icon(Icons.save, color: Colors.white, size: 18),
                            label: const Text('Save', style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Content
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                                  ElevatedButton(onPressed: _loadParameters, child: const Text('Retry')),
                                ],
                              ))
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: _parameterCategories.entries.map((entry) {
                                  return _CategorySection(
                                    title: entry.key,
                                    paramCodes: entry.value,
                                    scores: _scores,
                                    onChanged: (code, val) => setState(() => _scores[code] = val),
                                  );
                                }).toList(),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<String> paramCodes;
  final Map<String, double> scores;
  final void Function(String code, double val) onChanged;

  const _CategorySection({
    required this.title,
    required this.paramCodes,
    required this.scores,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...paramCodes.map((code) {
              final score = scores[code] ?? 50.0;
              final name = _parameterDisplayNames[code] ?? code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: Slider(
                        value: score,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceVariant,
                        onChanged: (v) => onChanged(code, v),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(score.toStringAsFixed(0), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.end),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
