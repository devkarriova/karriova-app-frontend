import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/di/injection.dart';

class AdminCareersPage extends StatefulWidget {
  const AdminCareersPage({super.key});

  @override
  State<AdminCareersPage> createState() => _AdminCareersPageState();
}

class _AdminCareersPageState extends State<AdminCareersPage> {
  final _dio = getIt<Dio>();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  String _selectedStream = 'All';
  List<String> _streams = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCareers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _dio.get('/admin/careers');
      final data = res.data as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(data['careers'] ?? []);
      final streams = <String>{'All'};
      for (final c in list) {
        if ((c['stream'] as String?)?.isNotEmpty == true) {
          streams.add(c['stream'] as String);
        }
      }
      setState(() {
        _careers = list;
        _streams = streams.toList();
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

  Future<void> _toggleActive(String id, bool currentlyActive) async {
    try {
      await _dio.put('/admin/careers/$id', data: {'is_active': !currentlyActive});
      _loadCareers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final pathCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String stream = 'Flexible';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Add Career', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Career Name *'),
                const SizedBox(height: 12),
                _field(descCtrl, 'Description', maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: stream,
                  decoration: _inputDecoration('Stream'),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    'Science PCM', 'Science PCB', 'Science PCMB',
                    'Commerce', 'Arts/Humanities', 'Vocational', 'Flexible',
                  ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setS(() => stream = v!),
                ),
                const SizedBox(height: 12),
                _field(pathCtrl, 'Entrance Path'),
                const SizedBox(height: 12),
                _field(notesCtrl, 'Stream Notes'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                try {
                  await _dio.post('/admin/careers', data: {
                    'name': nameCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'stream': stream,
                    'entrance_path': pathCtrl.text.trim(),
                    'stream_notes': notesCtrl.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadCareers();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  TextField _field(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Career', style: TextStyle(color: Colors.white)),
      ),
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => context.go(AppRouter.admin),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Career Library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('Manage all 61 career profiles and their parameters', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _loadCareers),
                      ],
                    ),
                  ),
                  // Search + filter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _applyFilter(),
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search careers...',
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedStream,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          underline: const SizedBox(),
                          items: _streams.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) { setState(() => _selectedStream = v!); _applyFilter(); },
                        ),
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
                                  Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(onPressed: _loadCareers, child: const Text('Retry')),
                                ],
                              ))
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(24, 4, 24, 80),
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final career = _filtered[index];
                                  final isActive = career['is_active'] as bool? ?? true;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(career['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        ),
                                        _StreamBadge(stream: career['stream'] as String? ?? ''),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if ((career['description'] as String?)?.isNotEmpty == true)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(career['description'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ),
                                        if ((career['entrance_path'] as String?)?.isNotEmpty == true)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text('Path: ${career['entrance_path']}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                                          ),
                                        Text('Parameters: ${career['parameter_count'] ?? 0}/21', style: TextStyle(color: (career['parameter_count'] as int? ?? 0) == 21 ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: isActive,
                                          activeColor: AppColors.primary,
                                          onChanged: (v) => _toggleActive(career['id'] as String, isActive),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.tune, color: AppColors.textSecondary),
                                          tooltip: 'Edit Parameters',
                                          onPressed: () => context.go('/admin/careers/${career['id']}/parameters', extra: career),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

class _StreamBadge extends StatelessWidget {
  final String stream;
  const _StreamBadge({required this.stream});

  Color get _color {
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
    if (stream.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(stream, style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
