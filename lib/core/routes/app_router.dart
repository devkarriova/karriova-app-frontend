import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_conversation_page.dart';

class AppRouter {
  // Auth routes
  static const String auth = '/';
  static const String login = '/';
  static const String signup = '/?mode=signup';

  // Main app routes
  static const String home = '/home';
  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String chat = '/chat';

  // Chat sub-routes
  static const String chatConversation = '/chat/:conversationId';

  static final GoRouter router = GoRouter(
    initialLocation: auth, // Default landing page is login
    routes: [
      // Auth Page (Login/Signup)
      GoRoute(
        path: '/',
        name: 'auth',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          return MaterialPage(
            key: state.pageKey,
            child: AuthPage(initiallyShowLogin: mode != 'signup'),
          );
        },
      ),

      // Home/Feed Page
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: FeedPage(),
          );
        },
      ),

      // Feed Page
      GoRoute(
        path: '/feed',
        name: 'feed',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: FeedPage(),
          );
        },
      ),

      // Profile Page
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) {
          final userId = state.uri.queryParameters['userId'];
          return MaterialPage(
            child: ProfilePage(userId: userId),
          );
        },
      ),

      // Chat List Page
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: ChatListPage(),
          );
        },
      ),

      // Chat Conversation Page
      GoRoute(
        path: '/chat/:conversationId',
        name: 'conversation',
        pageBuilder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          return MaterialPage(
            child: ChatConversationPage(
              conversationId: conversationId,
              otherUserId: otherUserId,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
