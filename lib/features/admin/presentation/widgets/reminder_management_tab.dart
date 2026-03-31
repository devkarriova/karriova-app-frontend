import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/reminder_remote_datasource.dart';
import '../../domain/models/reminder_model.dart';

/// Tab widget for managing reminders in the admin panel
class ReminderManagementTab extends StatefulWidget {
  const ReminderManagementTab({super.key});

  @override
  State<ReminderManagementTab> createState() => _ReminderManagementTabState();
}

class _ReminderManagementTabState extends State<ReminderManagementTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReminderRemoteDataSource _dataSource;
  
  bool _isLoading = true;
  String? _error;
  
  List<SystemNotificationSetting> _systemSettings = [];
  List<AdminReminder> _customReminders = [];
  ReminderStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dataSource = ReminderRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _dataSource.getSystemNotificationSettings(),
        _dataSource.getReminders(),
        _dataSource.getReminderStats(),
      ]);

      setState(() {
        _systemSettings = results[0] as List<SystemNotificationSetting>;
        final reminderResult = results[1] as ReminderListResponse;
        _customReminders = reminderResult.reminders;
        _stats = results[2] as ReminderStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stats Cards
        if (_stats != null) _buildStatsSection(),
        const SizedBox(height: 16),
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'System Notifications'),
              Tab(text: 'Custom Reminders'),
              Tab(text: 'Logs'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSystemNotificationsTab(),
              _buildCustomRemindersTab(),
              _buildLogsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'System Today',
            _stats!.systemNotifSentToday.toString(),
            Icons.notification_important,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Custom Today',
            _stats!.totalSentToday.toString(),
            Icons.schedule_send,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'This Week',
            _stats!.totalSentThisWeek.toString(),
            Icons.calendar_view_week,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Active',
            _stats!.activeReminders.toString(),
            Icons.play_circle,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemNotificationsTab() {
    return ListView.builder(
      itemCount: _systemSettings.length,
      itemBuilder: (context, index) {
        final setting = _systemSettings[index];
        return _buildSystemNotificationCard(setting);
      },
    );
  }

  Widget _buildSystemNotificationCard(SystemNotificationSetting setting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      child: ExpansionTile(
        leading: Switch(
          value: setting.isEnabled,
          onChanged: (value) => _toggleSystemNotification(setting, value),
          activeColor: AppColors.primary,
        ),
        title: Text(
          setting.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          setting.description,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          tooltip: 'Trigger Now',
          onPressed: () => _triggerSystemNotification(setting),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Title Template', setting.titleTemplate),
                const SizedBox(height: 8),
                _buildInfoRow('Message Template', setting.messageTemplate),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('Send Time', setting.sendTime)),
                    if (setting.thresholdDays != null)
                      Expanded(child: _buildInfoRow('Threshold', '${setting.thresholdDays} days')),
                    if (setting.sendMonth != null && setting.sendDay != null)
                      Expanded(child: _buildInfoRow('Date', '${setting.sendMonth}/${setting.sendDay}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('Max Reminders', '${setting.maxReminders}')),
                    Expanded(child: _buildInfoRow('Interval', '${setting.reminderIntervalDays} days')),
                  ],
                ),
                if (setting.targetRoles != null && setting.targetRoles!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Target Roles', setting.targetRoles!.join(', ')),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () => _editSystemNotification(setting),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRemindersTab() {
    return Column(
      children: [
        // Add New Button
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _showCreateReminderDialog,
            ),
          ),
        ),
        // List
        Expanded(
          child: _customReminders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text('No custom reminders yet'),
                      Text(
                        'Create one to send targeted notifications',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _customReminders.length,
                  itemBuilder: (context, index) {
                    return _buildReminderCard(_customReminders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(AdminReminder reminder) {
    final priorityColor = _getPriorityColor(reminder.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        reminder.triggerDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) => _toggleReminder(reminder, value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip('Roles: ${reminder.targetRoles.join(", ")}', Colors.blue),
                const SizedBox(width: 8),
                _buildChip('Sent: ${reminder.totalSent}', Colors.green),
                if (reminder.lastTriggeredAt != null) ...[
                  const SizedBox(width: 8),
                  _buildChip(
                    'Last: ${DateFormat.MMMd().format(reminder.lastTriggeredAt!)}',
                    Colors.orange,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.play_arrow, size: 16, color: Colors.green),
                  label: const Text('Trigger', style: TextStyle(color: Colors.green)),
                  onPressed: () => _triggerReminder(reminder),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  onPressed: () => _editReminder(reminder),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => _deleteReminder(reminder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLogsTab() {
    // TODO: Implement logs view with filtering
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text('Reminder Logs'),
          Text(
            'Select a reminder to view its send history',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // =============================================================================
  // ACTIONS
  // =============================================================================

  Future<void> _toggleSystemNotification(SystemNotificationSetting setting, bool enabled) async {
    try {
      await _dataSource.updateSystemNotificationSetting(
        setting.notificationType,
        {'is_enabled': enabled},
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${setting.displayName} ${enabled ? "enabled" : "disabled"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _triggerSystemNotification(SystemNotificationSetting setting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trigger ${setting.displayName}?'),
        content: const Text('This will immediately send notifications to all eligible users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Trigger'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final sentCount = await _dataSource.triggerSystemNotification(setting.notificationType);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent to $sentCount users'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editSystemNotification(SystemNotificationSetting setting) async {
    // TODO: Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit dialog coming soon')),
    );
  }

  Future<void> _toggleReminder(AdminReminder reminder, bool active) async {
    try {
      await _dataSource.updateReminder(reminder.id, {'is_active': active});
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _triggerReminder(AdminReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trigger "${reminder.title}"?'),
        content: Text('This will send the reminder to all ${reminder.targetRoles.join(", ")} users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Trigger'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final sentCount = await _dataSource.triggerReminder(reminder.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent to $sentCount users'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editReminder(AdminReminder reminder) async {
    // TODO: Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit dialog coming soon')),
    );
  }

  Future<void> _deleteReminder(AdminReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "${reminder.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _dataSource.deleteReminder(reminder.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateReminderDialog(
        onCreated: () async {
          await _loadData();
        },
        dataSource: _dataSource,
      ),
    );
  }
}

/// Dialog for creating a new reminder
class _CreateReminderDialog extends StatefulWidget {
  final VoidCallback onCreated;
  final ReminderRemoteDataSource dataSource;

  const _CreateReminderDialog({
    required this.onCreated,
    required this.dataSource,
  });

  @override
  State<_CreateReminderDialog> createState() => _CreateReminderDialogState();
}

class _CreateReminderDialogState extends State<_CreateReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _triggerType = 'scheduled';
  String _priority = 'normal';
  final Set<String> _selectedRoles = {'student'};
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String _recurringFrequency = 'daily';
  
  bool _isLoading = false;

  final _roles = ['student', 'mentor', 'admin', 'employer'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Reminder'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Update Your Profile',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'The notification message...',
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Message is required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Target Roles', style: TextStyle(fontWeight: FontWeight.w500)),
                Wrap(
                  spacing: 8,
                  children: _roles.map((role) {
                    return FilterChip(
                      label: Text(role),
                      selected: _selectedRoles.contains(role),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _triggerType,
                  decoration: const InputDecoration(labelText: 'Trigger Type'),
                  items: const [
                    DropdownMenuItem(value: 'scheduled', child: Text('One-time Scheduled')),
                    DropdownMenuItem(value: 'recurring', child: Text('Recurring')),
                    DropdownMenuItem(value: 'event', child: Text('Event-driven')),
                  ],
                  onChanged: (value) => setState(() => _triggerType = value!),
                ),
                const SizedBox(height: 16),
                if (_triggerType == 'scheduled') _buildScheduledConfig(),
                if (_triggerType == 'recurring') _buildRecurringConfig(),
                if (_triggerType == 'event') _buildEventConfig(),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) => setState(() => _priority = value!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildScheduledConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_scheduledDate != null
                    ? DateFormat.yMMMd().format(_scheduledDate!)
                    : 'Select Date'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _scheduledDate = date);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(_scheduledTime != null
                    ? _scheduledTime!.format(context)
                    : 'Select Time'),
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null) {
                    setState(() => _scheduledTime = time);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurringConfig() {
    return DropdownButtonFormField<String>(
      value: _recurringFrequency,
      decoration: const InputDecoration(labelText: 'Frequency'),
      items: const [
        DropdownMenuItem(value: 'daily', child: Text('Daily')),
        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
        DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
      ],
      onChanged: (value) => setState(() => _recurringFrequency = value!),
    );
  }

  Widget _buildEventConfig() {
    return const Text(
      'Event-driven reminders trigger based on user actions like profile updates or assessment completions.',
      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one target role')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> triggerConfig = {};
      
      if (_triggerType == 'scheduled' && _scheduledDate != null) {
        final dateTime = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime?.hour ?? 9,
          _scheduledTime?.minute ?? 0,
        );
        triggerConfig = {
          'send_at': dateTime.toIso8601String(),
          'timezone': 'UTC',
        };
      } else if (_triggerType == 'recurring') {
        triggerConfig = {
          'frequency': _recurringFrequency,
          'time': '09:00',
          'timezone': 'UTC',
        };
      }

      await widget.dataSource.createReminder({
        'title': _titleController.text,
        'message': _messageController.text,
        'target_roles': _selectedRoles.toList(),
        'trigger_type': _triggerType,
        'trigger_config': triggerConfig,
        'priority': _priority,
      });

      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
