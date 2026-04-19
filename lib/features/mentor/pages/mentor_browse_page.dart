import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';

class MentorBrowsePage extends StatefulWidget {
  const MentorBrowsePage({super.key});

  @override
  State<MentorBrowsePage> createState() => _MentorBrowsePageState();
}

class _MentorBrowsePageState extends State<MentorBrowsePage> {
  final _searchController = TextEditingController();
  String _selectedStream = '';
  List<Map<String, dynamic>> _mentors = [];
  bool _loading = true;
  String? _error;

  static const _streams = [
    '', 'Science PCM', 'Science PCB', 'Science PCMB',
    'Commerce', 'Arts/Humanities', 'Vocational', 'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final params = <String, String>{};
      if (_selectedStream.isNotEmpty) params['stream'] = _selectedStream;
      // text search is applied client-side via _filtered

      final uri = Uri(path: '/mentors', queryParameters: params.isEmpty ? null : params);
      final resp = await api.get(uri.toString());
      if (resp.isSuccess && resp.data != null) {
        final list = (resp.data['mentors'] as List?) ?? [];
        setState(() {
          _mentors = list.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() { _error = resp.errorMessage ?? 'Failed to load mentors'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _mentors;
    return _mentors.where((m) {
      final name = (m['name'] as String? ?? '').toLowerCase();
      final role = (m['current_role'] as String? ?? '').toLowerCase();
      return name.contains(q) || role.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find a Mentor'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMD, 0,
        AppDimensions.paddingMD, AppDimensions.paddingMD,
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name or role...',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _streams.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _streams[i];
                final selected = _selectedStream == s;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStream = s);
                    _loadMentors();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      s.isEmpty ? 'All' : s,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadMentors, child: const Text('Retry')),
          ],
        ),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const Center(
        child: Text('No mentors found', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMentors,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _MentorCard(
          mentor: list[i],
          onTap: () => context.push('/mentors/${list[i]['id']}', extra: list[i]),
        ),
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final VoidCallback onTap;

  const _MentorCard({required this.mentor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = mentor['name'] as String? ?? 'Mentor';
    final role = mentor['current_role'] as String? ?? '';
    final bio = mentor['bio'] as String? ?? '';
    final photo = mentor['photo_url'] as String? ?? '';
    final available = mentor['is_available'] as bool? ?? false;
    final expertise = (mentor['expertise'] as List?)?.cast<String>() ?? [];
    final yoe = mentor['years_experience'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? Text(name[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary)),
                        ),
                        if (available)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Available',
                                style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(role,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (yoe > 0) ...[
                      const SizedBox(height: 2),
                      Text('$yoe yrs experience',
                          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(bio,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (expertise.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: expertise.take(3).map((e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(e,
                              style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                        )).toList(),
                      ),
                    ],
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
