import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../di/injection.dart';
import '../routes/app_router.dart';

/// Global navigator key for navigation from outside widget tree (legacy support)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Service to handle Firebase Cloud Messaging (FCM) for push notifications
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and request notification permissions
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _messaging.getToken(
          vapidKey: kIsWeb ? _getWebVapidKey() : null,
        );

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _registerTokenWithBackend(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background/terminated state messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Check if the app was opened from a notification
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }
      }
    } catch (_) {
    }
  }

  /// Register device token with the backend
  Future<void> registerDeviceToken() async {
    if (_fcmToken == null) return;
    await _registerTokenWithBackend(_fcmToken!);
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final apiClient = getIt<ApiClient>();
      await apiClient.post(
        '/notifications/device-token',
        requiresAuth: true,
        body: {
          'token': token,
          'platform': _getPlatform(),
          'device_info': _getDeviceInfo(),
        },
      );
    } catch (_) {
    }
  }

  /// Unregister device token when user logs out
  Future<void> unregisterDeviceToken() async {
    if (_fcmToken == null) return;

    try {
      final apiClient = getIt<ApiClient>();
      await apiClient.delete(
        '/notifications/device-token/$_fcmToken',
        requiresAuth: true,
      );
    } catch (_) {
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // The notification will be handled by the system on mobile
    // For web, we may need to show a custom notification
    if (kIsWeb) {
      _showWebNotification(message);
    }

    // You can emit an event here to update the UI
    // e.g., refresh notification count, show a snackbar, etc.
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate to the appropriate screen based on notification data
    final data = message.data;
    final type = data['type'];
    final resourceId = data['resource_id'];

    _navigateBasedOnType(type, resourceId);
  }

  /// Navigate to the appropriate screen based on notification type
  void _navigateBasedOnType(String? type, String? resourceId) {
    if (type == null) return;

    final router = AppRouter.router;

    switch (type) {
      case 'like':
      case 'comment':
      case 'post':
        // Navigate to feed (post detail not implemented yet)
        // TODO: Add post detail route when implemented
        router.push(AppRouter.feed);
        break;

      case 'follow':
      case 'connection':
        // Navigate to user profile
        if (resourceId != null) {
          router.push('${AppRouter.profile}/$resourceId');
        } else {
          router.push(AppRouter.profile);
        }
        break;

      case 'message':
      case 'chat':
        // Navigate to chat conversation
        if (resourceId != null) {
          router.push('${AppRouter.chatConversation}?conversationId=$resourceId&otherUserId=');
        } else {
          router.push(AppRouter.chat);
        }
        break;

      case 'job':
      case 'job_alert':
        // Navigate to search (jobs page not implemented yet)
        // TODO: Add jobs route when implemented
        router.push(AppRouter.search);
        break;

      case 'company':
        // Navigate to search (company page not implemented yet)
        // TODO: Add company profile route when implemented
        router.push(AppRouter.search);
        break;

      case 'notification':
      default:
        // Navigate to notifications list
        router.push(AppRouter.notifications);
        break;
    }
  }

  void _showWebNotification(RemoteMessage message) {
    // Web notifications are handled automatically by the service worker
    // This is a fallback for custom notification display
    // No-op for now.
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  String _getDeviceInfo() {
    // Return basic device info
    // In production, you might want to use device_info_plus package
    return jsonEncode({
      'platform': _getPlatform(),
      'is_web': kIsWeb,
    });
  }

  String? _getWebVapidKey() {
    // TODO: Add your VAPID key from Firebase Console
    // This is required for web push notifications
    // Firebase Console > Project Settings > Cloud Messaging > Web Push certificates
    return null;
  }
}
