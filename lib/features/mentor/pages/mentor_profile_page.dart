import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';

class MentorProfilePage extends StatefulWidget {
  final String mentorId;
  final Map<String, dynamic>? initialData;

  const MentorProfilePage({
    super.key,
    required this.mentorId,
    this.initialData,
  });

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  Map<String, dynamic>? _mentor;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _mentor = widget.initialData;
      _loading = false;
    } else {
      _loadMentor();
    }
  }

  Future<void> _loadMentor() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final resp = await api.get('/mentors/${widget.mentorId}');
      if (resp.isSuccess && resp.data != null) {
        setState(() { _mentor = resp.data as Map<String, dynamic>?; _loading = false; });
      } else {
        setState(() { _error = resp.errorMessage ?? 'Mentor not found'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showConnectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ConnectSheet(mentorId: widget.mentorId, mentorName: _mentor?['name'] ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_error != null || _mentor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Mentor not found')),
      );
    }

    final mentor = _mentor!;
    final name = mentor['name'] as String? ?? 'Mentor';
    final role = mentor['current_role'] as String? ?? '';
    final bio = mentor['bio'] as String? ?? '';
    final photo = mentor['photo_url'] as String? ?? '';
    final linkedin = mentor['linkedin_url'] as String? ?? '';
    final yoe = mentor['years_experience'] as int? ?? 0;
    final available = mentor['is_available'] as bool? ?? false;
    final expertise = (mentor['expertise'] as List?)?.cast<String>() ?? [];
    final streams = (mentor['streams'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty
                            ? Text(name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      if (role.isNotEmpty)
                        Text(role,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.work_outline,
                        label: yoe > 0 ? '$yoe yrs exp' : 'Mentor',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.circle,
                        label: available ? 'Available' : 'Busy',
                        color: available ? AppColors.success : AppColors.textTertiary,
                      ),
                    ],
                  ),

                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(bio, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  ],

                  if (expertise.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Expertise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: expertise.map((e) => Chip(
                        label: Text(e, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                        backgroundColor: AppColors.secondary.withOpacity(0.08),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],

                  if (streams.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Guides Students In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: streams.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                        backgroundColor: AppColors.primary.withOpacity(0.08),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],

                  if (linkedin.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(linkedin,
                              style: const TextStyle(fontSize: 13, color: AppColors.info),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: ElevatedButton(
            onPressed: available ? _showConnectSheet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            ),
            child: Text(available ? 'Connect with $name' : 'Mentor is unavailable',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

class _ConnectSheet extends StatefulWidget {
  final String mentorId;
  final String mentorName;

  const _ConnectSheet({required this.mentorId, required this.mentorName});

  @override
  State<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<_ConnectSheet> {
  final _msgController = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() { _sending = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final resp = await api.post('/mentors/${widget.mentorId}/connect',
          body: {'message': _msgController.text.trim()});
      if (!mounted) return;
      if (resp.isSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connect request sent!'), backgroundColor: AppColors.success),
        );
      } else {
        setState(() { _error = resp.errorMessage ?? 'Failed to send request'; _sending = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _sending = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingMD,
        right: AppDimensions.paddingMD,
        top: AppDimensions.paddingMD,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingMD,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Connect with ${widget.mentorName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Introduce yourself and share what you\'d like guidance on.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextField(
            controller: _msgController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Hi, I am a student interested in...',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _sending ? null : _send,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            ),
            child: _sending
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
