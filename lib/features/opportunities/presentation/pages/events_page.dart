import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ApiClient _apiClient = getIt<ApiClient>();
  bool _isLoading = true;
  String? _error;
  List<_EventItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiClient.get(
      '/events',
      requiresAuth: true,
      queryParams: const {
        'recommended': 'true',
        'limit': '30',
        'offset': '0',
      },
    );

    if (!mounted) return;

    if (!response.isSuccess || response.data == null) {
      setState(() {
        _isLoading = false;
        _error = response.errorMessage ?? 'Failed to load events';
      });
      return;
    }

    final data = response.data as Map<String, dynamic>;
    final list = (data['events'] as List<dynamic>? ?? const [])
        .map((e) => _EventItem.fromJson(e as Map<String, dynamic>))
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
          const AppNavigationBar(currentRoute: AppRouter.events),
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
            ElevatedButton(onPressed: _loadEvents, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No upcoming events found for your profile.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
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
                      Chip(
                          label:
                              Text(item.isVirtual ? 'Virtual' : 'In Person')),
                      if (item.locationLabel.isNotEmpty)
                        Chip(label: Text(item.locationLabel)),
                      if (item.isFeatured) const Chip(label: Text('Featured')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.startDisplay,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

class _EventItem {
  final String id;
  final String title;
  final String description;
  final bool isVirtual;
  final bool isFeatured;
  final String locationLabel;
  final DateTime? startTime;

  _EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isVirtual,
    required this.isFeatured,
    required this.locationLabel,
    required this.startTime,
  });

  factory _EventItem.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as String? ?? '').trim();
    final city = (json['city'] as String? ?? '').trim();
    final country = (json['country'] as String? ?? '').trim();

    final parts = <String>[];
    if (location.isNotEmpty) {
      parts.add(location);
    }
    if (city.isNotEmpty && city.toLowerCase() != location.toLowerCase()) {
      parts.add(city);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    DateTime? start;
    final startRaw = json['start_time'] as String?;
    if (startRaw != null) {
      start = DateTime.tryParse(startRaw);
    }

    return _EventItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Event',
      description: json['description'] as String? ?? '',
      isVirtual: json['is_virtual'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      locationLabel: parts.join(', '),
      startTime: start,
    );
  }

  String get startDisplay {
    if (startTime == null) return 'Start time TBD';
    final local = startTime!.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$mm/$dd/${local.year} $hh:$min';
  }
}
