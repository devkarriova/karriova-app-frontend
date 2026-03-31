/// Model for system notification settings
class SystemNotificationSetting {
  final String id;
  final String notificationType;
  final String displayName;
  final String description;
  final String titleTemplate;
  final String messageTemplate;
  final bool isEnabled;
  final String sendTime;
  final int daysBefore;
  final int? sendMonth;
  final int? sendDay;
  final int? thresholdDays;
  final int maxReminders;
  final int reminderIntervalDays;
  final List<String>? targetRoles;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final DateTime createdAt;
  final DateTime updatedAt;

  SystemNotificationSetting({
    required this.id,
    required this.notificationType,
    required this.displayName,
    required this.description,
    required this.titleTemplate,
    required this.messageTemplate,
    required this.isEnabled,
    required this.sendTime,
    required this.daysBefore,
    this.sendMonth,
    this.sendDay,
    this.thresholdDays,
    required this.maxReminders,
    required this.reminderIntervalDays,
    this.targetRoles,
    this.actionType,
    this.actionData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemNotificationSetting.fromJson(Map<String, dynamic> json) {
    return SystemNotificationSetting(
      id: json['id'] ?? '',
      notificationType: json['notification_type'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      titleTemplate: json['title_template'] ?? '',
      messageTemplate: json['message_template'] ?? '',
      isEnabled: json['is_enabled'] ?? false,
      sendTime: json['send_time'] ?? '09:00:00',
      daysBefore: json['days_before'] ?? 0,
      sendMonth: json['send_month'],
      sendDay: json['send_day'],
      thresholdDays: json['threshold_days'],
      maxReminders: json['max_reminders'] ?? 3,
      reminderIntervalDays: json['reminder_interval_days'] ?? 7,
      targetRoles: json['target_roles'] != null
          ? List<String>.from(json['target_roles'])
          : null,
      actionType: json['action_type'],
      actionData: json['action_data'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'display_name': displayName,
      'description': description,
      'title_template': titleTemplate,
      'message_template': messageTemplate,
      'is_enabled': isEnabled,
      'send_time': sendTime,
      'days_before': daysBefore,
      'send_month': sendMonth,
      'send_day': sendDay,
      'threshold_days': thresholdDays,
      'max_reminders': maxReminders,
      'reminder_interval_days': reminderIntervalDays,
      'target_roles': targetRoles,
      'action_type': actionType,
      'action_data': actionData,
    };
  }

  SystemNotificationSetting copyWith({
    String? id,
    String? notificationType,
    String? displayName,
    String? description,
    String? titleTemplate,
    String? messageTemplate,
    bool? isEnabled,
    String? sendTime,
    int? daysBefore,
    int? sendMonth,
    int? sendDay,
    int? thresholdDays,
    int? maxReminders,
    int? reminderIntervalDays,
    List<String>? targetRoles,
    String? actionType,
    Map<String, dynamic>? actionData,
  }) {
    return SystemNotificationSetting(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      isEnabled: isEnabled ?? this.isEnabled,
      sendTime: sendTime ?? this.sendTime,
      daysBefore: daysBefore ?? this.daysBefore,
      sendMonth: sendMonth ?? this.sendMonth,
      sendDay: sendDay ?? this.sendDay,
      thresholdDays: thresholdDays ?? this.thresholdDays,
      maxReminders: maxReminders ?? this.maxReminders,
      reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
      targetRoles: targetRoles ?? this.targetRoles,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Model for admin-created reminders
class AdminReminder {
  final String id;
  final String title;
  final String message;
  final String? shortMessage;
  final List<String> targetRoles;
  final Map<String, dynamic>? targetFilters;
  final String triggerType;
  final Map<String, dynamic> triggerConfig;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final bool isActive;
  final String priority;
  final DateTime? lastTriggeredAt;
  final int totalSent;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminReminder({
    required this.id,
    required this.title,
    required this.message,
    this.shortMessage,
    required this.targetRoles,
    this.targetFilters,
    required this.triggerType,
    required this.triggerConfig,
    this.actionType,
    this.actionData,
    required this.isActive,
    required this.priority,
    this.lastTriggeredAt,
    required this.totalSent,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminReminder.fromJson(Map<String, dynamic> json) {
    return AdminReminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      shortMessage: json['short_message'],
      targetRoles: json['target_roles'] != null
          ? List<String>.from(json['target_roles'])
          : [],
      targetFilters: json['target_filters'],
      triggerType: json['trigger_type'] ?? 'scheduled',
      triggerConfig: json['trigger_config'] ?? {},
      actionType: json['action_type'],
      actionData: json['action_data'],
      isActive: json['is_active'] ?? false,
      priority: json['priority'] ?? 'normal',
      lastTriggeredAt: json['last_triggered_at'] != null
          ? DateTime.parse(json['last_triggered_at'])
          : null,
      totalSent: json['total_sent'] ?? 0,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'short_message': shortMessage,
      'target_roles': targetRoles,
      'target_filters': targetFilters,
      'trigger_type': triggerType,
      'trigger_config': triggerConfig,
      'action_type': actionType,
      'action_data': actionData,
      'is_active': isActive,
      'priority': priority,
    };
  }

  AdminReminder copyWith({
    String? id,
    String? title,
    String? message,
    String? shortMessage,
    List<String>? targetRoles,
    Map<String, dynamic>? targetFilters,
    String? triggerType,
    Map<String, dynamic>? triggerConfig,
    String? actionType,
    Map<String, dynamic>? actionData,
    bool? isActive,
    String? priority,
  }) {
    return AdminReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      shortMessage: shortMessage ?? this.shortMessage,
      targetRoles: targetRoles ?? this.targetRoles,
      targetFilters: targetFilters ?? this.targetFilters,
      triggerType: triggerType ?? this.triggerType,
      triggerConfig: triggerConfig ?? this.triggerConfig,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      lastTriggeredAt: lastTriggeredAt,
      totalSent: totalSent,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String get triggerDescription {
    switch (triggerType) {
      case 'scheduled':
        final sendAt = triggerConfig['send_at'];
        return sendAt != null ? 'Scheduled: $sendAt' : 'One-time scheduled';
      case 'recurring':
        final frequency = triggerConfig['frequency'] ?? 'unknown';
        return 'Recurring: $frequency';
      case 'event':
        final event = triggerConfig['event'] ?? 'unknown';
        return 'Event: $event';
      default:
        return triggerType;
    }
  }
}

/// Stats for reminders
class ReminderStats {
  final int totalReminders;
  final int activeReminders;
  final int totalSentToday;
  final int totalSentThisWeek;
  final int totalSentThisMonth;
  final int systemNotifSentToday;

  ReminderStats({
    required this.totalReminders,
    required this.activeReminders,
    required this.totalSentToday,
    required this.totalSentThisWeek,
    required this.totalSentThisMonth,
    required this.systemNotifSentToday,
  });

  factory ReminderStats.fromJson(Map<String, dynamic> json) {
    return ReminderStats(
      totalReminders: json['total_reminders'] ?? 0,
      activeReminders: json['active_reminders'] ?? 0,
      totalSentToday: json['total_sent_today'] ?? 0,
      totalSentThisWeek: json['total_sent_this_week'] ?? 0,
      totalSentThisMonth: json['total_sent_this_month'] ?? 0,
      systemNotifSentToday: json['system_notif_sent_today'] ?? 0,
    );
  }
}

/// User reminder log entry
class ReminderLog {
  final String id;
  final String reminderId;
  final String userId;
  final DateTime sentAt;
  final String? notificationId;
  final String status;
  final DateTime? actionedAt;
  final String userName;
  final String userEmail;
  final String userRole;

  ReminderLog({
    required this.id,
    required this.reminderId,
    required this.userId,
    required this.sentAt,
    this.notificationId,
    required this.status,
    this.actionedAt,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  factory ReminderLog.fromJson(Map<String, dynamic> json) {
    return ReminderLog(
      id: json['id'] ?? '',
      reminderId: json['reminder_id'] ?? '',
      userId: json['user_id'] ?? '',
      sentAt: DateTime.parse(json['sent_at'] ?? DateTime.now().toIso8601String()),
      notificationId: json['notification_id'],
      status: json['status'] ?? 'sent',
      actionedAt: json['actioned_at'] != null
          ? DateTime.parse(json['actioned_at'])
          : null,
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userRole: json['user_role'] ?? '',
    );
  }
}

/// Response wrapper for reminder list API
class ReminderListResponse {
  final List<AdminReminder> reminders;
  final int total;

  ReminderListResponse({
    required this.reminders,
    required this.total,
  });

  factory ReminderListResponse.fromJson(Map<String, dynamic> json) {
    final remindersList = json['reminders'] as List? ?? [];
    return ReminderListResponse(
      reminders: remindersList
          .map((item) => AdminReminder.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}

/// Response wrapper for reminder logs API
class ReminderLogResponse {
  final List<ReminderLog> logs;
  final int total;

  ReminderLogResponse({
    required this.logs,
    required this.total,
  });

  factory ReminderLogResponse.fromJson(Map<String, dynamic> json) {
    final logsList = json['logs'] as List? ?? [];
    return ReminderLogResponse(
      logs: logsList
          .map((item) => ReminderLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}
