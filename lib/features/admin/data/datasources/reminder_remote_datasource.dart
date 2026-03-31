import '../../../../core/network/api_client.dart';
import '../../domain/models/reminder_model.dart';

/// Remote data source for reminder management
abstract class ReminderRemoteDataSource {
  // System Notifications
  Future<List<SystemNotificationSetting>> getSystemNotificationSettings();
  Future<SystemNotificationSetting> getSystemNotificationSetting(String type);
  Future<SystemNotificationSetting> updateSystemNotificationSetting(String type, Map<String, dynamic> updates);
  Future<int> triggerSystemNotification(String type);

  // Admin Reminders
  Future<ReminderListResponse> getReminders({int limit = 20, int offset = 0, bool? activeOnly, String? triggerType});
  Future<AdminReminder> getReminder(String id);
  Future<AdminReminder> createReminder(Map<String, dynamic> reminderData);
  Future<AdminReminder> updateReminder(String id, Map<String, dynamic> updates);
  Future<void> deleteReminder(String id);
  Future<int> triggerReminder(String id);
  Future<ReminderLogResponse> getReminderLogs(String reminderId, {int limit = 50, int offset = 0});
  Future<ReminderStats> getReminderStats();
}

/// Implementation of ReminderRemoteDataSource
class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final ApiClient apiClient;

  ReminderRemoteDataSourceImpl({required this.apiClient});

  // =============================================================================
  // SYSTEM NOTIFICATIONS
  // =============================================================================

  @override
  Future<List<SystemNotificationSetting>> getSystemNotificationSettings() async {
    final response = await apiClient.get(
      '/admin/notifications/system',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load system notification settings');
    }

    final settingsList = (response.data as Map<String, dynamic>)['settings'] as List? ?? [];
    return settingsList
        .map((json) => SystemNotificationSetting.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SystemNotificationSetting> getSystemNotificationSetting(String type) async {
    final response = await apiClient.get(
      '/admin/notifications/system/$type',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load system notification setting');
    }

    return SystemNotificationSetting.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SystemNotificationSetting> updateSystemNotificationSetting(
    String type,
    Map<String, dynamic> updates,
  ) async {
    final response = await apiClient.put(
      '/admin/notifications/system/$type',
      requiresAuth: true,
      body: updates,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to update system notification setting');
    }

    return SystemNotificationSetting.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<int> triggerSystemNotification(String type) async {
    final response = await apiClient.post(
      '/admin/notifications/system/$type/trigger',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to trigger system notification');
    }

    return (response.data as Map<String, dynamic>?)?['sent_count'] ?? 0;
  }

  // =============================================================================
  // ADMIN REMINDERS
  // =============================================================================

  @override
  Future<ReminderListResponse> getReminders({
    int limit = 20,
    int offset = 0,
    bool? activeOnly,
    String? triggerType,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (activeOnly == true) queryParams['active_only'] = 'true';
    if (triggerType != null) queryParams['trigger_type'] = triggerType;

    final response = await apiClient.get(
      '/admin/reminders',
      requiresAuth: true,
      queryParams: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load reminders');
    }

    return ReminderListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AdminReminder> getReminder(String id) async {
    final response = await apiClient.get(
      '/admin/reminders/$id',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load reminder');
    }

    return AdminReminder.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AdminReminder> createReminder(Map<String, dynamic> reminderData) async {
    final response = await apiClient.post(
      '/admin/reminders',
      requiresAuth: true,
      body: reminderData,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create reminder');
    }

    return AdminReminder.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AdminReminder> updateReminder(String id, Map<String, dynamic> updates) async {
    final response = await apiClient.put(
      '/admin/reminders/$id',
      requiresAuth: true,
      body: updates,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to update reminder');
    }

    return AdminReminder.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReminder(String id) async {
    final response = await apiClient.delete(
      '/admin/reminders/$id',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete reminder');
    }
  }

  @override
  Future<int> triggerReminder(String id) async {
    final response = await apiClient.post(
      '/admin/reminders/$id/trigger',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to trigger reminder');
    }

    return (response.data as Map<String, dynamic>?)?['sent_count'] ?? 0;
  }

  @override
  Future<ReminderLogResponse> getReminderLogs(
    String reminderId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await apiClient.get(
      '/admin/reminders/$reminderId/logs',
      requiresAuth: true,
      queryParams: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load reminder logs');
    }

    return ReminderLogResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReminderStats> getReminderStats() async {
    final response = await apiClient.get(
      '/admin/reminders/stats',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load reminder stats');
    }

    return ReminderStats.fromJson(response.data as Map<String, dynamic>);
  }
}
