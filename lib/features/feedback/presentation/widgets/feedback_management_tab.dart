import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/feedback_models.dart';
import '../bloc/admin_feedback_bloc.dart';
import '../bloc/admin_feedback_event.dart';
import '../bloc/admin_feedback_state.dart';

/// Admin tab for managing support tickets
class FeedbackManagementTab extends StatelessWidget {
  const FeedbackManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminFeedbackBloc>()
        ..add(const LoadAllTickets())
        ..add(const LoadTicketStats()),
      child: const _FeedbackManagementView(),
    );
  }
}

class _FeedbackManagementView extends StatelessWidget {
  const _FeedbackManagementView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats bar
        BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
          buildWhen: (prev, curr) => prev.stats != curr.stats,
          builder: (context, state) {
            final stats = state.stats;
            if (stats == null) return const SizedBox.shrink();
            return _StatsBar(stats: stats);
          },
        ),

        // Filters
        const _FiltersBar(),

        // Ticket list
        BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
          builder: (context, state) {
            if (state.isLoading && state.tickets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Failed to load tickets'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AdminFeedbackBloc>()
                          .add(const LoadAllTickets()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.hasFilters
                          ? 'No tickets match your filters'
                          : 'No support tickets yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminFeedbackBloc>().add(const LoadAllTickets());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = state.tickets[index];
                  return _AdminTicketCard(ticket: ticket);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  final TicketStats stats;

  const _StatsBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: stats.total, color: Colors.grey),
          _StatItem(label: 'Open', value: stats.open, color: Colors.blue),
          _StatItem(
              label: 'In Progress', value: stats.inProgress, color: Colors.orange),
          _StatItem(label: 'Resolved', value: stats.resolved, color: Colors.green),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.background,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Status filter
                      _FilterDropdown<TicketStatus>(
                        label: 'Status',
                        value: state.statusFilter,
                        items: TicketStatus.values,
                        getLabel: (s) => s.displayName,
                        onChanged: (value) {
                          context.read<AdminFeedbackBloc>().add(
                                ApplyTicketFilters(
                                  status: value,
                                  category: state.categoryFilter,
                                  priority: state.priorityFilter,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Category filter
                      _FilterDropdown<TicketCategory>(
                        label: 'Category',
                        value: state.categoryFilter,
                        items: TicketCategory.values,
                        getLabel: (c) => c.displayName,
                        onChanged: (value) {
                          context.read<AdminFeedbackBloc>().add(
                                ApplyTicketFilters(
                                  status: state.statusFilter,
                                  category: value,
                                  priority: state.priorityFilter,
                                ),
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Priority filter
                      _FilterDropdown<TicketPriority>(
                        label: 'Priority',
                        value: state.priorityFilter,
                        items: TicketPriority.values,
                        getLabel: (p) => p.displayName,
                        onChanged: (value) {
                          context.read<AdminFeedbackBloc>().add(
                                ApplyTicketFilters(
                                  status: state.statusFilter,
                                  category: state.categoryFilter,
                                  priority: value,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (state.hasFilters)
                TextButton(
                  onPressed: () {
                    context.read<AdminFeedbackBloc>().add(
                          const ApplyTicketFilters(),
                        );
                  },
                  child: const Text('Clear'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value != null
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != null
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(label),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text('All $label'),
            ),
            ...items.map((item) => DropdownMenuItem<T?>(
                  value: item,
                  child: Text(getLabel(item)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AdminTicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _AdminTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: InkWell(
        onTap: () => _showTicketDialog(context, ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: ticket.status),
                  const SizedBox(width: 8),
                  _CategoryBadge(category: ticket.category),
                  const SizedBox(width: 8),
                  _PriorityBadge(priority: ticket.priority),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, h:mm a').format(ticket.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'User: ${ticket.userId.substring(0, 8)}...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (ticket.appVersion != null) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.phone_android,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'v${ticket.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  if (ticket.responses.isNotEmpty) ...[
                    const Spacer(),
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.responses.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDialog(BuildContext context, SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminFeedbackBloc>(),
        child: _TicketDetailDialog(ticket: ticket),
      ),
    );
  }
}

class _TicketDetailDialog extends StatefulWidget {
  final SupportTicket ticket;

  const _TicketDetailDialog({required this.ticket});

  @override
  State<_TicketDetailDialog> createState() => _TicketDetailDialogState();
}

class _TicketDetailDialogState extends State<_TicketDetailDialog> {
  final _responseController = TextEditingController();
  late SupportTicket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    context.read<AdminFeedbackBloc>().add(LoadAdminTicketDetails(_ticket.id));
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminFeedbackBloc, AdminFeedbackState>(
      listener: (context, state) {
        if (state.selectedTicket != null &&
            state.selectedTicket!.id == _ticket.id) {
          setState(() => _ticket = state.selectedTicket!);
        }
      },
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ticket Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),

              // Ticket info
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and actions row
                      Row(
                        children: [
                          _StatusBadge(status: _ticket.status),
                          const SizedBox(width: 8),
                          _CategoryBadge(category: _ticket.category),
                          const Spacer(),
                          // Status change dropdown
                          _ActionDropdown<TicketStatus>(
                            label: 'Status',
                            value: _ticket.status,
                            items: TicketStatus.values,
                            getLabel: (s) => s.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<AdminFeedbackBloc>().add(
                                      UpdateTicketStatus(
                                        ticketId: _ticket.id,
                                        status: value,
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _ActionDropdown<TicketPriority>(
                            label: 'Priority',
                            value: _ticket.priority,
                            items: TicketPriority.values,
                            getLabel: (p) => p.displayName,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<AdminFeedbackBloc>().add(
                                      UpdateTicketPriority(
                                        ticketId: _ticket.id,
                                        priority: value,
                                      ),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subject
                      Text(
                        _ticket.subject,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),

                      // Meta info
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            'Created: ${DateFormat('MMM dd, yyyy h:mm a').format(_ticket.createdAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          if (_ticket.appVersion != null)
                            Text(
                              'App Version: ${_ticket.appVersion}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          if (_ticket.deviceInfo != null)
                            Text(
                              'Device: ${_ticket.deviceInfo}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),

                      // Description
                      const SizedBox(height: 8),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_ticket.description),
                      ),

                      // Responses
                      if (_ticket.responses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Responses',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ..._ticket.responses.map(
                          (response) => _ResponseItem(response: response),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Reply input
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _responseController,
                      decoration: InputDecoration(
                        hintText: 'Type your response...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isUpdating
                            ? null
                            : () {
                                final message =
                                    _responseController.text.trim();
                                if (message.isEmpty) return;
                                context.read<AdminFeedbackBloc>().add(
                                      AddAdminTicketResponse(
                                        ticketId: _ticket.id,
                                        message: message,
                                      ),
                                    );
                                _responseController.clear();
                              },
                        child: state.isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponseItem extends StatelessWidget {
  final TicketResponse response;

  const _ResponseItem({required this.response});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: response.isAdminResponse
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: response.isAdminResponse
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                response.isAdminResponse ? 'Admin' : 'User',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: response.isAdminResponse
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, h:mm a').format(response.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(response.message),
        ],
      ),
    );
  }
}

class _ActionDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;

  const _ActionDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      getLabel(item),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          isDense: true,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final TicketCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TicketPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TicketPriority.low:
        color = Colors.grey;
        break;
      case TicketPriority.medium:
        color = Colors.blue;
        break;
      case TicketPriority.high:
        color = Colors.orange;
        break;
      case TicketPriority.critical:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
