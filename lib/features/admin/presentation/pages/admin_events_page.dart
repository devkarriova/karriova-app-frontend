import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../domain/models/event_model.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/event_form_dialog.dart';

/// Admin page for managing events
class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()
        ..add(const LoadEventsEvent())
        ..add(const LoadCategoriesEvent()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(),
              const AppNavigationBar(currentRoute: AppRouter.admin),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(context),
                      const SizedBox(height: 24),
                      _buildToolbar(context),
                      const SizedBox(height: 16),
                      _buildFilterChips(context),
                      const SizedBox(height: 16),
                      _buildEventsList(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.admin),
          tooltip: 'Back to Admin Dashboard',
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.event, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Create and manage events for the community',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onSubmitted: (value) {
              context.read<AdminBloc>().add(UpdateFilterEvent(search: value));
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateEventDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Event'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: state.statusFilter == null,
                onSelected: () => context.read<AdminBloc>().add(const UpdateFilterEvent(status: '')),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Published',
                isSelected: state.statusFilter == 'published',
                onSelected: () => context.read<AdminBloc>().add(const UpdateFilterEvent(status: 'published')),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Draft',
                isSelected: state.statusFilter == 'draft',
                onSelected: () => context.read<AdminBloc>().add(const UpdateFilterEvent(status: 'draft')),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Cancelled',
                isSelected: state.statusFilter == 'cancelled',
                onSelected: () => context.read<AdminBloc>().add(const UpdateFilterEvent(status: 'cancelled')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.isLoadingEvents && state.events.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state.eventsError != null && state.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(state.eventsError!, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AdminBloc>().add(const RefreshEventsEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 48, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text('No events found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                SizedBox(height: 8),
                Text('Create your first event to get started', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
              ],
            ),
          );
        }

        return Column(
          children: state.events.map((event) => _EventCard(event: event)).toList(),
        );
      },
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final bloc = context.read<AdminBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const EventFormDialog(),
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

/// Event card widget
class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEditEventDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event thumbnail or placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      image: event.thumbnailImage != null
                          ? DecorationImage(
                              image: NetworkImage(event.thumbnailImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: event.thumbnailImage == null
                        ? const Icon(
                            Icons.event,
                            size: 40,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Event details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (event.categoryName != null)
                          Text(
                            event.categoryName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateFormat.format(event.startTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              event.isVirtual ? Icons.videocam : Icons.location_on,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.isVirtual
                                    ? 'Virtual Event'
                                    : event.location ?? 'Location TBD',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (event.status == 'draft')
                    TextButton.icon(
                      onPressed: () => _publishEvent(context),
                      icon: const Icon(Icons.publish, size: 18),
                      label: const Text('Publish'),
                      style: TextButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  TextButton.icon(
                    onPressed: () => _showEditEventDialog(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (event.status) {
      case 'published':
        color = Colors.green;
        label = 'Published';
        break;
      case 'draft':
        color = Colors.orange;
        label = 'Draft';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = event.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showEditEventDialog(BuildContext context) {
    final bloc = context.read<AdminBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: EventFormDialog(event: event),
      ),
    );
  }

  void _publishEvent(BuildContext context) {
    context.read<AdminBloc>().add(PublishEventEvent(event.id));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminBloc>().add(DeleteEventEvent(event.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
