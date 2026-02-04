import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/assessment_management_tab.dart';
import '../../../feedback/presentation/widgets/feedback_management_tab.dart';

/// Admin page for managing events and other admin functions
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _expandedSection;

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
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage events, assessments, feedback, and content moderation',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAdminCard(
                        context,
                        title: 'Events Management',
                        subtitle: 'Create and manage events for the community',
                        icon: Icons.event,
                        color: Colors.blue,
                        sectionKey: 'events',
                        expandedContent: _EventManagementContent(searchController: _searchController),
                      ),
                      const SizedBox(height: 16),
                      _buildAdminCard(
                        context,
                        title: 'Assessment Management',
                        subtitle: 'Manage career assessment questions and scoring',
                        icon: Icons.psychology,
                        color: Colors.purple,
                        sectionKey: 'assessment',
                        expandedContent: const SizedBox(
                          height: 500,
                          child: AssessmentManagementTab(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAdminCard(
                        context,
                        title: 'Feedback Management',
                        subtitle: 'Review and respond to user feedback',
                        icon: Icons.support_agent,
                        color: Colors.green,
                        sectionKey: 'feedback',
                        expandedContent: const SizedBox(
                          height: 400,
                          child: FeedbackManagementTab(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAdminCard(
                        context,
                        title: 'Content Moderation',
                        subtitle: 'Review flagged content and manage reports',
                        icon: Icons.shield_outlined,
                        color: Colors.orange,
                        sectionKey: 'moderation',
                        expandedContent: const _ContentModerationContent(),
                      ),
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

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String sectionKey,
    required Widget expandedContent,
  }) {
    final isExpanded = _expandedSection == sectionKey;
    
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSection = isExpanded ? null : sectionKey;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: expandedContent,
            ),
          ],
        ],
      ),
    );
  }
}

/// Event Management Content (expanded card content)
class _EventManagementContent extends StatelessWidget {
  final TextEditingController searchController;

  const _EventManagementContent({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toolbar
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: AppColors.background,
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
        ),
        const SizedBox(height: 16),
        // Filter chips
        _buildFilterChips(context),
        const SizedBox(height: 16),
        // Events list
        BlocBuilder<AdminBloc, AdminState>(
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

/// Content Moderation Content (expanded card content)
class _ContentModerationContent extends StatelessWidget {
  const _ContentModerationContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Content Moderation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'This feature is coming soon. You will be able to review flagged content and manage reports here.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
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
                              event.isVirtual
                                  ? Icons.videocam
                                  : Icons.location_on,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.isVirtual
                                    ? 'Virtual • ${event.virtualPlatform ?? 'Online'}'
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
              const Divider(height: 24),
              Row(
                children: [
                  _buildStatItem(
                    Icons.people,
                    '${event.attendeeCount}${event.maxAttendees != null ? '/${event.maxAttendees}' : ''}',
                    'Attendees',
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    Icons.attach_money,
                    event.registrationFee > 0
                        ? '${event.currency} ${event.registrationFee.toStringAsFixed(0)}'
                        : 'Free',
                    'Price',
                  ),
                  const Spacer(),
                  _buildActionButtons(context),
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
    switch (event.status) {
      case 'published':
        color = Colors.green;
        break;
      case 'draft':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.isFeatured) ...[
            const Icon(Icons.star, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
          ],
          Text(
            event.statusDisplay,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (event.status == 'draft')
          IconButton(
            icon: const Icon(Icons.publish, color: Colors.green),
            onPressed: () => _publishEvent(context),
            tooltip: 'Publish',
          ),
        IconButton(
          icon: Icon(
            event.isFeatured ? Icons.star : Icons.star_border,
            color: event.isFeatured ? Colors.amber : AppColors.textSecondary,
          ),
          onPressed: () => _toggleFeatured(context),
          tooltip: event.isFeatured ? 'Unfeature' : 'Feature',
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.primary),
          onPressed: () => _showEditEventDialog(context),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(context),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  void _showEditEventDialog(BuildContext context) {
    final bloc = context.read<AdminBloc>();
    bloc.add(SelectEventForEditEvent(event));
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: EventFormDialog(event: event),
      ),
    );
  }

  void _publishEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Publish Event'),
        content: Text('Are you sure you want to publish "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(PublishEventEvent(event.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _toggleFeatured(BuildContext context) {
    context.read<AdminBloc>().add(
          ToggleEventFeaturedEvent(event.id, !event.isFeatured),
        );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteEventEvent(event.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
