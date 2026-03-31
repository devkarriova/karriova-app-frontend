import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/models/notification_model.dart';

/// Service to handle WebSocket connections for real-time notifications
class NotificationWebSocketService {
  final String baseUrl;
  final FlutterSecureStorage storage;
  final _logger = Logger();

  WebSocketChannel? _channel;
  String? _authToken;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Stream controllers
  final _notificationController = StreamController<NotificationModel>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Streams
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  NotificationWebSocketService({required this.baseUrl, required this.storage});

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnected) {
      _logger.i('Notification WebSocket already connected');
      return;
    }

    try {
      // Get the auth token from secure storage
      _authToken = await storage.read(key: 'access_token');
      if (_authToken == null || _authToken!.isEmpty) {
        _logger.w('No auth token found for notification WebSocket connection, will retry...');
        // Token might not be saved yet, schedule retry
        _scheduleReconnect();
        return;
      }

      await _establishConnection();
    } catch (e) {
      _logger.e('Error connecting to notification WebSocket: $e');
      _scheduleReconnect();
    }
  }

  Future<void> _establishConnection() async {
    try {
      final wsUrl = baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');

      // Note: baseUrl already includes /api/v1, so we only append /notifications/ws
      final uri = Uri.parse('$wsUrl/notifications/ws?token=$_authToken');

      _logger.i('Connecting to notification WebSocket: ${uri.replace(queryParameters: {})}'); // Log without token

      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _logger.i('Notification WebSocket connected successfully');
      _reconnectAttempts = 0;
      _connectionController.add(true);

      // Start listening to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _isConnected = true;
      _startHeartbeat();
    } catch (e) {
      _logger.e('Failed to establish notification WebSocket connection: $e');
      _isConnected = false;
      _connectionController.add(false);
      _scheduleReconnect();
      rethrow;
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final jsonData = json.decode(data as String);
      _logger.d('Notification WebSocket message received: $jsonData');

      // Parse the notification
      final notification = NotificationModel.fromJson(jsonData);
      _notificationController.add(notification);
    } catch (e) {
      _logger.e('Error parsing notification WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    _logger.e('Notification WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _handleDisconnect() {
    _logger.w('Notification WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('Max notification WebSocket reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    _logger.i('Scheduling notification WebSocket reconnection (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _logger.i('Attempting to reconnect notification WebSocket...');
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(json.encode({'type': 'ping'}));
        } catch (e) {
          _logger.e('Error sending notification heartbeat: $e');
        }
      }
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _logger.i('Disconnecting from notification WebSocket');
    _isConnected = false;
    _reconnectAttempts = 0; // Reset for next connection
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionController.close();
  }
}
