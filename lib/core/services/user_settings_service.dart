import '../network/api_client.dart';

/// Service for handling user settings operations
class UserSettingsService {
  final ApiClient _apiClient;

  UserSettingsService(this._apiClient);

  // ================================
  // NOTIFICATION SETTINGS
  // ================================

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    final response = await _apiClient.get(
      '/settings/notifications',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to load notification settings');
    }

    return NotificationSettings.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update notification settings
  Future<NotificationSettings> updateNotificationSettings(
      NotificationSettings settings) async {
    final response = await _apiClient.put(
      '/settings/notifications',
      body: settings.toJson(),
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to update notification settings');
    }

    return NotificationSettings.fromJson(response.data as Map<String, dynamic>);
  }

  // ================================
  // PRIVACY SETTINGS
  // ================================

  /// Get privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    final response = await _apiClient.get(
      '/settings/privacy',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to load privacy settings');
    }

    return PrivacySettings.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update privacy settings
  Future<PrivacySettings> updatePrivacySettings(
      PrivacySettings settings) async {
    final response = await _apiClient.put(
      '/settings/privacy',
      body: settings.toJson(),
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to update privacy settings');
    }

    return PrivacySettings.fromJson(response.data as Map<String, dynamic>);
  }

  // ================================
  // APPEARANCE SETTINGS
  // ================================

  /// Get appearance settings
  Future<AppearanceSettings> getAppearanceSettings() async {
    final response = await _apiClient.get(
      '/settings/appearance',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to load appearance settings');
    }

    return AppearanceSettings.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update appearance settings
  Future<AppearanceSettings> updateAppearanceSettings(
      AppearanceSettings settings) async {
    final response = await _apiClient.put(
      '/settings/appearance',
      body: settings.toJson(),
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(
          response.errorMessage ?? 'Failed to update appearance settings');
    }

    return AppearanceSettings.fromJson(response.data as Map<String, dynamic>);
  }

  // ================================
  // ALL SETTINGS
  // ================================

  /// Get all user settings at once
  Future<AllUserSettings> getAllSettings() async {
    final response = await _apiClient.get(
      '/settings',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to load settings');
    }

    return AllUserSettings.fromJson(response.data as Map<String, dynamic>);
  }
}

// ================================
// DATA MODELS
// ================================

/// Notification settings model
class NotificationSettings {
  // Push notifications
  final bool pushEnabled;
  final bool pushLikes;
  final bool pushComments;
  final bool pushFollows;
  final bool pushMessages;
  final bool pushJobAlerts;

  // Email notifications
  final bool emailEnabled;
  final bool emailWeeklyDigest;
  final bool emailJobMatches;
  final bool emailPromotions;

  NotificationSettings({
    this.pushEnabled = true,
    this.pushLikes = true,
    this.pushComments = true,
    this.pushFollows = true,
    this.pushMessages = true,
    this.pushJobAlerts = true,
    this.emailEnabled = true,
    this.emailWeeklyDigest = true,
    this.emailJobMatches = true,
    this.emailPromotions = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['push_enabled'] ?? true,
      pushLikes: json['push_likes'] ?? true,
      pushComments: json['push_comments'] ?? true,
      pushFollows: json['push_follows'] ?? true,
      pushMessages: json['push_messages'] ?? true,
      pushJobAlerts: json['push_job_alerts'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      emailWeeklyDigest: json['email_weekly_digest'] ?? true,
      emailJobMatches: json['email_job_matches'] ?? true,
      emailPromotions: json['email_promotions'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'push_likes': pushLikes,
      'push_comments': pushComments,
      'push_follows': pushFollows,
      'push_messages': pushMessages,
      'push_job_alerts': pushJobAlerts,
      'email_enabled': emailEnabled,
      'email_weekly_digest': emailWeeklyDigest,
      'email_job_matches': emailJobMatches,
      'email_promotions': emailPromotions,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? pushLikes,
    bool? pushComments,
    bool? pushFollows,
    bool? pushMessages,
    bool? pushJobAlerts,
    bool? emailEnabled,
    bool? emailWeeklyDigest,
    bool? emailJobMatches,
    bool? emailPromotions,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      pushLikes: pushLikes ?? this.pushLikes,
      pushComments: pushComments ?? this.pushComments,
      pushFollows: pushFollows ?? this.pushFollows,
      pushMessages: pushMessages ?? this.pushMessages,
      pushJobAlerts: pushJobAlerts ?? this.pushJobAlerts,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailWeeklyDigest: emailWeeklyDigest ?? this.emailWeeklyDigest,
      emailJobMatches: emailJobMatches ?? this.emailJobMatches,
      emailPromotions: emailPromotions ?? this.emailPromotions,
    );
  }
}

/// Privacy settings model
class PrivacySettings {
  final String profileVisibility; // public, connections, private
  final bool showEmail;
  final bool showPhone;
  final bool showLocation;
  final bool allowMessagesFromAnyone;
  final bool showOnlineStatus;
  final bool allowProfileInSearch;
  final bool showActivityStatus;
  final bool shareProfileViews;

  PrivacySettings({
    this.profileVisibility = 'public',
    this.showEmail = false,
    this.showPhone = false,
    this.showLocation = true,
    this.allowMessagesFromAnyone = true,
    this.showOnlineStatus = true,
    this.allowProfileInSearch = true,
    this.showActivityStatus = true,
    this.shareProfileViews = false,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profile_visibility'] ?? 'public',
      showEmail: json['show_email'] ?? false,
      showPhone: json['show_phone'] ?? false,
      showLocation: json['show_location'] ?? true,
      allowMessagesFromAnyone: json['allow_messages_from_anyone'] ?? true,
      showOnlineStatus: json['show_online_status'] ?? true,
      allowProfileInSearch: json['allow_profile_in_search'] ?? true,
      showActivityStatus: json['show_activity_status'] ?? true,
      shareProfileViews: json['share_profile_views'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_visibility': profileVisibility,
      'show_email': showEmail,
      'show_phone': showPhone,
      'show_location': showLocation,
      'allow_messages_from_anyone': allowMessagesFromAnyone,
      'show_online_status': showOnlineStatus,
      'allow_profile_in_search': allowProfileInSearch,
      'show_activity_status': showActivityStatus,
      'share_profile_views': shareProfileViews,
    };
  }

  PrivacySettings copyWith({
    String? profileVisibility,
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    bool? allowMessagesFromAnyone,
    bool? showOnlineStatus,
    bool? allowProfileInSearch,
    bool? showActivityStatus,
    bool? shareProfileViews,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      showLocation: showLocation ?? this.showLocation,
      allowMessagesFromAnyone:
          allowMessagesFromAnyone ?? this.allowMessagesFromAnyone,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowProfileInSearch: allowProfileInSearch ?? this.allowProfileInSearch,
      showActivityStatus: showActivityStatus ?? this.showActivityStatus,
      shareProfileViews: shareProfileViews ?? this.shareProfileViews,
    );
  }
}

/// Appearance settings model
class AppearanceSettings {
  final String theme; // light, dark, system
  final String fontSize; // small, medium, large
  final bool compactMode;
  final String language;

  AppearanceSettings({
    this.theme = 'system',
    this.fontSize = 'medium',
    this.compactMode = false,
    this.language = 'en',
  });

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) {
    return AppearanceSettings(
      theme: json['theme'] ?? 'system',
      fontSize: json['font_size'] ?? 'medium',
      compactMode: json['compact_mode'] ?? false,
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'font_size': fontSize,
      'compact_mode': compactMode,
      'language': language,
    };
  }

  AppearanceSettings copyWith({
    String? theme,
    String? fontSize,
    bool? compactMode,
    String? language,
  }) {
    return AppearanceSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      compactMode: compactMode ?? this.compactMode,
      language: language ?? this.language,
    );
  }
}

/// Combined settings model (for getAllSettings)
class AllUserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AppearanceSettings appearance;

  AllUserSettings({
    required this.notifications,
    required this.privacy,
    required this.appearance,
  });

  factory AllUserSettings.fromJson(Map<String, dynamic> json) {
    // The backend returns all fields at top level, not nested
    return AllUserSettings(
      notifications: NotificationSettings(
        pushEnabled: json['push_enabled'] ?? true,
        pushLikes: json['push_likes'] ?? true,
        pushComments: json['push_comments'] ?? true,
        pushFollows: json['push_follows'] ?? true,
        pushMessages: json['push_messages'] ?? true,
        pushJobAlerts: json['push_job_alerts'] ?? true,
        emailEnabled: json['email_enabled'] ?? true,
        emailWeeklyDigest: json['email_weekly_digest'] ?? true,
        emailJobMatches: json['email_job_matches'] ?? true,
        emailPromotions: json['email_promotions'] ?? false,
      ),
      privacy: PrivacySettings(
        profileVisibility: json['profile_visibility'] ?? 'public',
        showEmail: json['show_email'] ?? false,
        showPhone: json['show_phone'] ?? false,
        showLocation: json['show_location'] ?? true,
        allowMessagesFromAnyone: json['allow_messages_from_anyone'] ?? true,
        showOnlineStatus: json['show_online_status'] ?? true,
        allowProfileInSearch: json['allow_profile_in_search'] ?? true,
        showActivityStatus: json['show_activity_status'] ?? true,
        shareProfileViews: json['share_profile_views'] ?? false,
      ),
      appearance: AppearanceSettings(
        theme: json['theme'] ?? 'system',
        fontSize: json['font_size'] ?? 'medium',
        compactMode: json['compact_mode'] ?? false,
        language: json['language'] ?? 'en',
      ),
    );
  }
}
