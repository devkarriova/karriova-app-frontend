import 'package:equatable/equatable.dart';

abstract class ChatUnreadEvent extends Equatable {
  const ChatUnreadEvent();

  @override
  List<Object?> get props => [];
}

/// Request to refresh the unread count
class ChatUnreadCountRefreshRequested extends ChatUnreadEvent {
  const ChatUnreadCountRefreshRequested();
}

/// Request to decrement the unread count (when marking messages as read)
class ChatUnreadCountDecremented extends ChatUnreadEvent {
  final int by;

  const ChatUnreadCountDecremented({this.by = 1});

  @override
  List<Object?> get props => [by];
}

/// Request to increment the unread count (when receiving a new message)
class ChatUnreadCountIncremented extends ChatUnreadEvent {
  const ChatUnreadCountIncremented();
}
