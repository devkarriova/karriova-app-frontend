import 'package:equatable/equatable.dart';

enum ChatUnreadStatus { initial, loading, success, error }

class ChatUnreadState extends Equatable {
  final ChatUnreadStatus status;
  final int unreadCount;
  final String? errorMessage;

  const ChatUnreadState({
    this.status = ChatUnreadStatus.initial,
    this.unreadCount = 0,
    this.errorMessage,
  });

  ChatUnreadState copyWith({
    ChatUnreadStatus? status,
    int? unreadCount,
    String? errorMessage,
  }) {
    return ChatUnreadState(
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, unreadCount, errorMessage];
}
