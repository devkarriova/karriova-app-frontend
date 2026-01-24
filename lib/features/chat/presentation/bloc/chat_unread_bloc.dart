import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_unread_event.dart';
import 'chat_unread_state.dart';

class ChatUnreadBloc extends Bloc<ChatUnreadEvent, ChatUnreadState> {
  final ChatRepository chatRepository;

  ChatUnreadBloc({required this.chatRepository})
      : super(const ChatUnreadState()) {
    on<ChatUnreadCountRefreshRequested>(_onRefreshRequested);
    on<ChatUnreadCountDecremented>(_onDecremented);
    on<ChatUnreadCountIncremented>(_onIncremented);
  }

  Future<void> _onRefreshRequested(
    ChatUnreadCountRefreshRequested event,
    Emitter<ChatUnreadState> emit,
  ) async {
    emit(state.copyWith(status: ChatUnreadStatus.loading));

    final result = await chatRepository.getTotalUnreadCount();

    result.fold(
      (error) => emit(state.copyWith(
        status: ChatUnreadStatus.error,
        errorMessage: error,
      )),
      (count) => emit(state.copyWith(
        status: ChatUnreadStatus.success,
        unreadCount: count,
      )),
    );
  }

  void _onDecremented(
    ChatUnreadCountDecremented event,
    Emitter<ChatUnreadState> emit,
  ) {
    final newCount = (state.unreadCount - event.by).clamp(0, 999);
    emit(state.copyWith(unreadCount: newCount));
  }

  void _onIncremented(
    ChatUnreadCountIncremented event,
    Emitter<ChatUnreadState> emit,
  ) {
    emit(state.copyWith(unreadCount: state.unreadCount + 1));
  }
}
