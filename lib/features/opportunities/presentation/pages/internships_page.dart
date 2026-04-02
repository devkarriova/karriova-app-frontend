import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key});

  @override
  State<InternshipsPage> createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  final ApiClient _apiClient = getIt<ApiClient>();
  bool _isLoading = true;
  String? _error;
  List<_InternshipItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadInternships();
  }

  Future<void> _loadInternships() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiClient.get(
      '/jobs/recommended',
      requiresAuth: true,
      queryParams: const {
        'job_type': 'internship',
        'limit': '30',
        'offset': '0',
      },
    );

    if (!mounted) return;

    if (!response.isSuccess || response.data == null) {
      setState(() {
        _isLoading = false;
        _error = response.errorMessage ?? 'Failed to load internships';
      });
      return;
    }

    final data = response.data as Map<String, dynamic>;
    final list = (data['jobs'] as List<dynamic>? ?? const [])
        .map((e) => _InternshipItem.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _isLoading = false;
      _items = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const AppNavigationBar(currentRoute: AppRouter.internships),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadInternships, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No internships found yet for your profile.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInternships,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.companyName.isNotEmpty)
                        Chip(label: Text(item.companyName)),
                      if (item.location.isNotEmpty)
                        Chip(label: Text(item.location)),
                      Chip(label: Text(item.isRemote ? 'Remote' : 'Onsite')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InternshipItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final bool isRemote;
  final String companyName;

  _InternshipItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.isRemote,
    required this.companyName,
  });

  factory _InternshipItem.fromJson(Map<String, dynamic> json) {
    return _InternshipItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Internship',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isRemote: json['is_remote'] as bool? ?? false,
      companyName: json['company_name'] as String? ?? '',
    );
  }
}
