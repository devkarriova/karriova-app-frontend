import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/config/app_config.dart';
import 'core/services/inactivity_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/follow/presentation/bloc/follow_bloc.dart';
import 'features/follow/presentation/bloc/follow_event.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/notifications/presentation/bloc/notification_state.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/chat_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection
  await configureDependencies();

  runApp(const KarriovaApp());
}

class KarriovaApp extends StatefulWidget {
  const KarriovaApp({super.key});

  @override
  State<KarriovaApp> createState() => _KarriovaAppState();
}

class _KarriovaAppState extends State<KarriovaApp> {
  late final InactivityService _inactivityService;
  late final AuthBloc _authBloc;
  late final ThemeCubit _themeCubit;
  late final ChatBloc _chatBloc;
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _inactivityService = getIt<InactivityService>();
    _authBloc = getIt<AuthBloc>()..add(const AuthCheckStatusRequested());
    _themeCubit = getIt<ThemeCubit>();
    _chatBloc = getIt<ChatBloc>();
    _notificationBloc = getIt<NotificationBloc>();

    // Load theme preference
    _themeCubit.loadThemePreference();

    // Setup token expiration callback
    _setupTokenExpirationCallback();

    // Setup inactivity tracking
    _setupInactivityTracking();
  }

  void _setupTokenExpirationCallback() {
    // Get the auth repository and set up token expiration callback
    final authRepository = getIt<AuthRepository>();
    if (authRepository is AuthRepositoryImpl) {
      authRepository.setTokenExpiredCallback(() {
        // Trigger token expired event
        _authBloc.add(const AuthTokenExpired());
      });
    }
  }

  void _setupInactivityTracking() {
    // Listen to auth state changes to enable/disable inactivity tracking
    _authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        // User is logged in — sync theme from API (overwrites local cache with DB value)
        _themeCubit.loadThemePreference();

        // User is logged in, enable inactivity tracking
        _inactivityService.enable(
          onTimeout: () {
            // Auto logout on inactivity
            _authBloc.add(const AuthLogoutRequested());
          },
        );

        // Register device token for push notifications (disabled - using WebSocket)
        // _pushNotificationService.registerDeviceToken();

        // Connect to notification WebSocket for real-time updates
        _notificationBloc.add(const NotificationWebSocketConnectRequested());

        // Load followingIds for the follow button state across the app
        final followBloc = getIt<FollowBloc>();
        if (followBloc.state.followingIds.isEmpty) {
          followBloc.add(const LoadFollowingIdsEvent());
        }
      } else {
        // User is not logged in, disable tracking
        _inactivityService.disable();

        // Disconnect notification WebSocket and unregister device token when logged out
        if (state.status == AuthStatus.unauthenticated) {
          // _pushNotificationService.unregisterDeviceToken();

          _notificationBloc.add(const NotificationWebSocketDisconnectRequested());
        }
      }
    });
  }

  @override
  void dispose() {
    _inactivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: _authBloc,
        ),
        BlocProvider<ThemeCubit>.value(
          value: _themeCubit,
        ),
        BlocProvider<ChatBloc>.value(
          value: _chatBloc,
        ),
        BlocProvider<NotificationBloc>.value(
          value: _notificationBloc,
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return InactivityDetector(
            inactivityService: _inactivityService,
            child: MaterialApp.router(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return _NotificationListener(child: child!);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Listens to incoming notifications and shows them as snackbars
class _NotificationListener extends StatefulWidget {
  final Widget child;

  const _NotificationListener({required this.child});

  @override
  State<_NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<_NotificationListener> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        // Detect new messages by comparing message counts
        int prevCount = previous.messagesMap.values.fold(0, (sum, msgs) => sum + msgs.length);
        int currCount = current.messagesMap.values.fold(0, (sum, msgs) => sum + msgs.length);
        return currCount > prevCount;
      },
      listener: (context, state) {
        // Find and show newest message
        final allMessages = state.messagesMap.values.expand((list) => list).toList();
        if (allMessages.isNotEmpty) {
          final lastMessage = allMessages.last;
          // Get current user ID to check if message is incoming
          final authState = context.read<AuthBloc>().state;
          final currentUserId = authState.user?.id;
          
          if (currentUserId != null && lastMessage.senderId != currentUserId) {
            _showChatNotification(lastMessage.content);
          }
        }
      },
      child: BlocListener<NotificationBloc, NotificationState>(
        listenWhen: (previous, current) {
          // Only trigger when unread count increases (new notification arrived)
          return current.unreadCount > previous.unreadCount;
        },
        listener: (context, state) {
          // Show snackbar for new notification
          if (state.notifications.isNotEmpty) {
            final latestNotification = state.notifications.first;
            final message = latestNotification.message ?? 'New notification';
            _showGeneralNotification(message);
          }
        },
        child: widget.child,
      ),
    );
  }

  void _showGeneralNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showChatNotification(String messageContent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.message, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'New message: $messageContent',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
