import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:logger/logger.dart';

/// WebSocket message types
enum WebSocketMessageType {
  message,
  typing,
  read,
  delivered,
}

/// WebSocket message model
class WebSocketMessage {
  final WebSocketMessageType type;
  final String? conversationId;
  final String senderId;
  final String receiverId;
  final String? content;
  final String? messageId;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    this.conversationId,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.messageId,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WebSocketMessageType.message,
      ),
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      messageId: json['message_id'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (conversationId != null) 'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      if (content != null) 'content': content,
      if (messageId != null) 'message_id': messageId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// WebSocket service for real-time chat
class ChatWebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl;
  final Logger _logger = Logger();

  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  String? _authToken;

  ChatWebSocketService({required this.baseUrl});

  /// Stream of incoming WebSocket messages
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// Stream of connection status changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Check if currently connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server
  Future<void> connect(String authToken) async {
    if (_channel != null) {
      _logger.w('WebSocket already connected');
      return;
    }

    _authToken = authToken;
    _isManuallyDisconnected = false;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    try {
      final wsUrl = baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');

      // For WebSocket with authentication, we'll pass token as query parameter
      // and update the backend to accept it from query params
      // Note: baseUrl already includes /api/v1, so we only append /chat/ws
      final uri = Uri.parse('$wsUrl/chat/ws?token=$_authToken');

      _logger.i('Connecting to WebSocket: ${uri.replace(queryParameters: {})}'); // Log without token

      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _logger.i('WebSocket connected successfully');
      _reconnectAttempts = 0;
      _connectionController.add(true);

      // Start listening to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      // Start heartbeat
      _startHeartbeat();

    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String);
      final message = WebSocketMessage.fromJson(json);
      _messageController.add(message);
      _logger.d('Received WebSocket message: ${message.type}');
    } catch (e) {
      _logger.e('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    _logger.e('WebSocket error: $error');
    _connectionController.add(false);
  }

  void _handleDisconnect() {
    _logger.w('WebSocket disconnected');
    _connectionController.add(false);
    _cleanup();

    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    _logger.i('Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isManuallyDisconnected && _authToken != null) {
        _establishConnection();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_channel != null) {
        try {
          // Send ping message
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          _logger.e('Error sending heartbeat: $e');
        }
      }
    });
  }

  void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _channel = null;
  }

  /// Send a message through WebSocket
  void sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) {
    if (_channel == null) {
      _logger.e('Cannot send message: WebSocket not connected');
      return;
    }

    final message = WebSocketMessage(
      type: WebSocketMessageType.message,
      conversationId: conversationId,
      senderId: '', // Will be set by server
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    try {
      _channel!.sink.add(jsonEncode(message.toJson()));
      _logger.d('Message sent through WebSocket');
    } catch (e) {
      _logger.e('Error sending message: $e');
    }
  }

  /// Send typing indicator
  void sendTyping({
    required String conversationId,
    required String receiverId,
  }) {
    if (_channel == null) return;

    final message = WebSocketMessage(
      type: WebSocketMessageType.typing,
      conversationId: conversationId,
      senderId: '',
      receiverId: receiverId,
      timestamp: DateTime.now(),
    );

    try {
      _channel!.sink.add(jsonEncode(message.toJson()));
    } catch (e) {
      _logger.e('Error sending typing indicator: $e');
    }
  }

  /// Send read receipt
  void sendReadReceipt({
    required String messageId,
    required String receiverId,
  }) {
    if (_channel == null) return;

    final message = WebSocketMessage(
      type: WebSocketMessageType.read,
      senderId: '',
      receiverId: receiverId,
      messageId: messageId,
      timestamp: DateTime.now(),
    );

    try {
      _channel!.sink.add(jsonEncode(message.toJson()));
    } catch (e) {
      _logger.e('Error sending read receipt: $e');
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _logger.i('Manually disconnecting WebSocket');
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _cleanup();
    _connectionController.add(false);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
