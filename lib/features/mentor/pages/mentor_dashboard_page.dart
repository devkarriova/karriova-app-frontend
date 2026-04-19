import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';

class MentorDashboardPage extends StatefulWidget {
  const MentorDashboardPage({super.key});

  @override
  State<MentorDashboardPage> createState() => _MentorDashboardPageState();
}

class _MentorDashboardPageState extends State<MentorDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<Map<String, dynamic>> _requests = [];
  Map<String, dynamic>? _profile;
  bool _loadingRequests = true;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadProfile();
    _loadRequests();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final api = getIt<ApiClient>();
      final resp = await api.get('/mentor/profile');
      if (resp.isSuccess && resp.data != null) {
        setState(() { _profile = resp.data as Map<String, dynamic>?; _loadingProfile = false; });
      } else {
        setState(() => _loadingProfile = false);
      }
    } catch (_) {
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    try {
      final api = getIt<ApiClient>();
      final resp = await api.get('/mentor/requests');
      if (resp.isSuccess && resp.data != null) {
        final list = (resp.data['requests'] as List?) ?? [];
        setState(() { _requests = list.cast<Map<String, dynamic>>(); _loadingRequests = false; });
      } else {
        setState(() => _loadingRequests = false);
      }
    } catch (_) {
      setState(() => _loadingRequests = false);
    }
  }

  Future<void> _respond(String requestId, String status) async {
    final api = getIt<ApiClient>();
    final resp = await api.put('/mentor/requests/$requestId', body: {'status': status});
    if (resp.isSuccess) {
      _loadRequests();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.errorMessage ?? 'Failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/mentor/profile/edit').then((_) => _loadProfile()),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Requests (${_requests.where((r) => r['status'] == 'pending').length})'),
            const Tab(text: 'My Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildRequestsTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_loadingRequests) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text('No connect requests yet', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('Students will appear here when they reach out',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RequestCard(
          request: _requests[i],
          onApprove: () => _respond(_requests[i]['id'] as String, 'approved'),
          onDecline: () => _respond(_requests[i]['id'] as String, 'declined'),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_profile == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _loadProfile,
          child: const Text('Load Profile'),
        ),
      );
    }
    final p = _profile!;
    final name = p['name'] as String? ?? '';
    final role = p['current_role'] as String? ?? '';
    final bio = p['bio'] as String? ?? '';
    final yoe = p['years_experience'] as int? ?? 0;
    final available = p['is_available'] as bool? ?? false;
    final verified = p['is_verified'] as bool? ?? false;
    final expertise = (p['expertise'] as List?)?.cast<String>() ?? [];
    final streams = (p['streams'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badges
          Row(
            children: [
              _Badge(
                label: verified ? 'Verified' : 'Pending Verification',
                color: verified ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              _Badge(
                label: available ? 'Available' : 'Unavailable',
                color: available ? AppColors.success : AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileField('Name', name),
          _ProfileField('Current Role', role.isEmpty ? '—' : role),
          _ProfileField('Years of Experience', yoe > 0 ? '$yoe years' : '—'),
          _ProfileField('Bio', bio.isEmpty ? '—' : bio),
          if (expertise.isNotEmpty)
            _ProfileField('Expertise', expertise.join(', ')),
          if (streams.isNotEmpty)
            _ProfileField('Streams', streams.join(', ')),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/mentor/profile/edit').then((_) => _loadProfile()),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const _RequestCard({required this.request, required this.onApprove, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final studentName = request['student_name'] as String? ?? 'Student';
    final message = request['message'] as String? ?? '';
    final status = request['status'] as String? ?? 'pending';

    Color statusColor;
    switch (status) {
      case 'approved': statusColor = AppColors.success; break;
      case 'declined': statusColor = AppColors.error; break;
      default: statusColor = AppColors.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(studentName[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(studentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
