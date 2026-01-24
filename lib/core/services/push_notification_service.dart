import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../di/injection.dart';

/// Global navigator key for navigation from outside widget tree
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
        debugPrint('Push notifications authorized');

        // Get FCM token
        _fcmToken = await _messaging.getToken(
          vapidKey: kIsWeb ? _getWebVapidKey() : null,
        );
        debugPrint('FCM Token: $_fcmToken');

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
      } else {
        debugPrint('Push notifications not authorized');
      }
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
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
      debugPrint('Device token registered with backend');
    } catch (e) {
      debugPrint('Error registering device token: $e');
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
      debugPrint('Device token unregistered from backend');
    } catch (e) {
      debugPrint('Error unregistering device token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');

    // The notification will be handled by the system on mobile
    // For web, we may need to show a custom notification
    if (kIsWeb) {
      _showWebNotification(message);
    }

    // You can emit an event here to update the UI
    // e.g., refresh notification count, show a snackbar, etc.
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');

    // Navigate to the appropriate screen based on notification data
    final data = message.data;
    final type = data['type'];
    final resourceId = data['resource_id'];

    _navigateBasedOnType(type, resourceId);
  }

  /// Navigate to the appropriate screen based on notification type
  void _navigateBasedOnType(String? type, String? resourceId) {
    if (type == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('Navigator not available for push notification navigation');
      return;
    }

    switch (type) {
      case 'like':
      case 'comment':
      case 'post':
        // Navigate to post detail
        if (resourceId != null) {
          navigator.pushNamed('/post/$resourceId');
        }
        break;

      case 'follow':
      case 'connection':
        // Navigate to user profile
        if (resourceId != null) {
          navigator.pushNamed('/profile/$resourceId');
        }
        break;

      case 'message':
      case 'chat':
        // Navigate to chat conversation
        if (resourceId != null) {
          navigator.pushNamed('/chat/$resourceId');
        } else {
          navigator.pushNamed('/chat');
        }
        break;

      case 'job':
      case 'job_alert':
        // Navigate to job detail
        if (resourceId != null) {
          navigator.pushNamed('/job/$resourceId');
        } else {
          navigator.pushNamed('/jobs');
        }
        break;

      case 'company':
        // Navigate to company profile
        if (resourceId != null) {
          navigator.pushNamed('/company/$resourceId');
        }
        break;

      case 'notification':
      default:
        // Navigate to notifications list
        navigator.pushNamed('/notifications');
        break;
    }

    debugPrint('Navigated based on notification type: $type, resource_id: $resourceId');
  }

  void _showWebNotification(RemoteMessage message) {
    // Web notifications are handled automatically by the service worker
    // This is a fallback for custom notification display
    debugPrint('Web notification: ${message.notification?.title}');
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
