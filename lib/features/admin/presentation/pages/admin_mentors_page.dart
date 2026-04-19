import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';

class AdminMentorsPage extends StatefulWidget {
  const AdminMentorsPage({super.key});

  @override
  State<AdminMentorsPage> createState() => _AdminMentorsPageState();
}

class _AdminMentorsPageState extends State<AdminMentorsPage> {
  List<Map<String, dynamic>> _mentors = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all'; // 'all' | 'pending' | 'verified'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final resp = await api.get('/admin/mentors');
      if (resp.isSuccess && resp.data != null) {
        final list = (resp.data['mentors'] as List?) ?? [];
        setState(() { _mentors = list.cast<Map<String, dynamic>>(); _loading = false; });
      } else {
        setState(() { _error = resp.errorMessage ?? 'Failed to load'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _verify(String userId, bool verified) async {
    final api = getIt<ApiClient>();
    final resp = await api.put('/admin/mentors/$userId/verify', body: {'verified': verified});
    if (resp.isSuccess) {
      _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.errorMessage ?? 'Failed'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _promote(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promote to Mentor'),
        content: const Text('This will set the user\'s role to mentor and create a mentor profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Promote', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final api = getIt<ApiClient>();
    final resp = await api.put('/admin/mentors/$userId/promote', body: {});
    if (!mounted) return;
    if (resp.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User promoted to mentor'), backgroundColor: AppColors.success),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.errorMessage ?? 'Failed'), backgroundColor: AppColors.error),
      );
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _mentors.where((m) {
      final verified = m['is_verified'] as bool? ?? false;
      if (_filter == 'verified') return verified;
      if (_filter == 'pending') return !verified;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mentor Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMD, 0, AppDimensions.paddingMD, AppDimensions.paddingMD,
      ),
      child: Row(
        children: [
          _FilterChip(label: 'All', value: 'all', current: _filter, onTap: () => setState(() => _filter = 'all')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Pending', value: 'pending', current: _filter, onTap: () => setState(() => _filter = 'pending')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Verified', value: 'verified', current: _filter, onTap: () => setState(() => _filter = 'verified')),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const Center(child: Text('No mentors found', style: TextStyle(color: AppColors.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _MentorAdminCard(
          mentor: list[i],
          onVerify: (v) => _verify(list[i]['user_id'] as String, v),
          onPromote: () => _promote(list[i]['user_id'] as String),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, current;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.white : AppColors.textSecondary,
            )),
      ),
    );
  }
}

class _MentorAdminCard extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final void Function(bool) onVerify;
  final VoidCallback onPromote;

  const _MentorAdminCard({required this.mentor, required this.onVerify, required this.onPromote});

  @override
  Widget build(BuildContext context) {
    final name = mentor['name'] as String? ?? 'Unknown';
    final email = mentor['email'] as String? ?? '';
    final role = mentor['current_role'] as String? ?? '';
    final verified = mentor['is_verified'] as bool? ?? false;
    final available = mentor['is_available'] as bool? ?? false;
    final connects = mentor['connect_requests'] as int? ?? 0;
    final expertise = (mentor['expertise'] as List?)?.cast<String>() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(name[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (verified ? AppColors.success : AppColors.warning).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(verified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        color: verified ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ],
            ),
            if (role.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(role, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
            if (expertise.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: expertise.take(3).map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.people_outline, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('$connects requests',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(width: 12),
                Icon(
                  Icons.circle,
                  size: 8,
                  color: available ? AppColors.success : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(available ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 12,
                      color: available ? AppColors.success : AppColors.textTertiary,
                    )),
                const Spacer(),
                TextButton(
                  onPressed: () => onVerify(!verified),
                  style: TextButton.styleFrom(
                    foregroundColor: verified ? AppColors.error : AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: Text(verified ? 'Unverify' : 'Verify'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
