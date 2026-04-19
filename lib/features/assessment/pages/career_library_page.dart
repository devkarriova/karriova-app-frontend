import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';

class CareerLibraryPage extends StatefulWidget {
  const CareerLibraryPage({super.key});

  @override
  State<CareerLibraryPage> createState() => _CareerLibraryPageState();
}

class _CareerLibraryPageState extends State<CareerLibraryPage> {
  final _dio = getIt<Dio>();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _filtered = [];
  List<String> _streams = ['All'];
  String _selectedStream = 'All';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _dio.get('/api/v1/careers');
      final data = res.data as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['careers'] ?? []);
      final rawStreams = List<String>.from(data['streams'] ?? []);
      setState(() {
        _careers = list;
        _streams = ['All', ...rawStreams];
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    var result = List<Map<String, dynamic>>.from(_careers);
    if (_selectedStream != 'All') {
      result = result.where((c) => c['stream'] == _selectedStream).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) =>
        (c['name'] as String).toLowerCase().contains(q) ||
        (c['description'] as String? ?? '').toLowerCase().contains(q),
      ).toList();
    }
    setState(() { _filtered = result; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Explore Careers', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search careers...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stream filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _streams.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _streams[i];
                final selected = s == _selectedStream;
                return ChoiceChip(
                  label: Text(s, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textSecondary)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                  onSelected: (_) { setState(() => _selectedStream = s); _applyFilter(); },
                );
              },
            ),
          ),
          // Career count
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Text('${_filtered.length} careers', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text('Failed to load careers', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ))
                    : _filtered.isEmpty
                        ? const Center(child: Text('No careers found', style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _CareerCard(
                              career: _filtered[i],
                              onTap: () => context.push('/careers/${_filtered[i]['id']}', extra: _filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  final Map<String, dynamic> career;
  final VoidCallback onTap;

  const _CareerCard({required this.career, required this.onTap});

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
    final stream = career['stream'] as String? ?? '';
    final fitScore = (career['user_fit_score'] as num?)?.toDouble() ?? 0.0;
    final hasFit = fitScore > 0;
    final color = _streamColor(stream);

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stream color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(career['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                        ),
                        if (hasFit) _FitBadge(score: fitScore),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if ((career['description'] as String?)?.isNotEmpty == true)
                      Text(career['description'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(stream, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        if ((career['entrance_path'] as String?)?.isNotEmpty == true) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(career['entrance_path'] as String, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FitBadge extends StatelessWidget {
  final double score;
  const _FitBadge({required this.score});

  Color get _color {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: _color),
          const SizedBox(width: 3),
          Text('${score.toStringAsFixed(0)}% fit', style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
