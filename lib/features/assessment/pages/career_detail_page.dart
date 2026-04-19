import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';

class CareerDetailPage extends StatefulWidget {
  final String careerId;
  final Map<String, dynamic>? initialData;

  const CareerDetailPage({
    super.key,
    required this.careerId,
    this.initialData,
  });

  @override
  State<CareerDetailPage> createState() => _CareerDetailPageState();
}

class _CareerDetailPageState extends State<CareerDetailPage> {
  final _dio = getIt<Dio>();
  Map<String, dynamic>? _career;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _career = widget.initialData;
      _loading = false;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _dio.get('/api/v1/careers/${widget.careerId}');
      setState(() {
        _career = res.data as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (_career == null) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  Color _streamColor(String stream) {
    switch (stream) {
      case 'Science PCM': return Colors.blue;
      case 'Science PCB': return Colors.green;
      case 'Science PCMB': return Colors.teal;
      case 'Commerce': return Colors.orange;
      case 'Arts/Humanities': return Colors.purple;
      case 'Vocational': return Colors.brown;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _career == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, leading: const BackButton(color: AppColors.textPrimary)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _career == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, leading: const BackButton(color: AppColors.textPrimary)),
        body: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load career', style: TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        )),
      );
    }

    final career = _career!;
    final stream = career['stream'] as String? ?? '';
    final color = _streamColor(stream);
    final fitScore = (career['user_fit_score'] as num?)?.toDouble() ?? 0.0;
    final hasFit = fitScore > 0;
    final targets = List<Map<String, dynamic>>.from(career['parameter_targets'] ?? []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: color.withOpacity(0.9),
            foregroundColor: Colors.white,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(career['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.work_outline, color: Colors.white.withOpacity(0.4), size: 64),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stream + fit score row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(stream, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const Spacer(),
                      if (hasFit)
                        _FitScoreBadge(score: fitScore),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if ((career['description'] as String?)?.isNotEmpty == true) ...[
                    Text(career['description'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // Entrance path
                  if ((career['entrance_path'] as String?)?.isNotEmpty == true)
                    _InfoCard(
                      icon: Icons.school_outlined,
                      label: 'How to Get There',
                      value: career['entrance_path'] as String,
                      color: color,
                    ),

                  // Notes
                  if ((career['stream_notes'] as String?)?.isNotEmpty == true)
                    _InfoCard(
                      icon: Icons.info_outline,
                      label: 'Important Note',
                      value: career['stream_notes'] as String,
                      color: Colors.amber,
                    ),

                  // AI content placeholder
                  _PlaceholderSection(
                    icon: Icons.auto_awesome,
                    title: 'Detailed Insights',
                    subtitle: 'What you actually do, who it\'s for, hard truths, and more — personalized content coming soon.',
                    color: AppColors.primary,
                  ),

                  // Parameter fit breakdown (if user has taken assessment)
                  if (hasFit && targets.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Your Fit Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('How your KIT scores compare to the ideal profile for this career.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    ...targets.take(8).map((t) => _ParameterRow(target: t)),
                    if (targets.length > 8)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('+ ${targets.length - 8} more parameters', style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PlaceholderSection({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterRow extends StatelessWidget {
  final Map<String, dynamic> target;
  const _ParameterRow({required this.target});

  @override
  Widget build(BuildContext context) {
    final name = target['parameter_name'] as String? ?? '';
    final ideal = (target['ideal_score'] as num?)?.toDouble() ?? 50.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ideal / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.7)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(ideal.toStringAsFixed(0), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FitScoreBadge extends StatelessWidget {
  final double score;
  const _FitScoreBadge({required this.score});

  Color get _color {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: _color),
          const SizedBox(width: 4),
          Text('${score.toStringAsFixed(0)}% Fit', style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
