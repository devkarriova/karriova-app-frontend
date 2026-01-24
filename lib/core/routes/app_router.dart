import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/assessment/presentation/pages/assessment_page.dart';

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
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String assessment = '/assessment';

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

      // Profile Page (own profile)
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

      // Profile Page (other user's profile)
      GoRoute(
        path: '/profile/:userId',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId'];
          return MaterialPage(
            child: ProfilePage(userId: userId),
          );
        },
      ),

      // Chat Page (unified with conversation list + conversation view)
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) {
          final userId = state.uri.queryParameters['userId'];
          final userName = state.uri.queryParameters['userName'];
          return MaterialPage(
            child: ChatPage(
              initialUserId: userId,
              initialUserName: userName,
            ),
          );
        },
      ),

      // Search Page
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: SearchPage(),
          );
        },
      ),

      // Notifications Page
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: NotificationsPage(),
          );
        },
      ),

      // Admin Page
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminPage(),
          );
        },
      ),

      // Assessment Page (mandatory for first-time users)
      GoRoute(
        path: '/assessment',
        name: 'assessment',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: AssessmentPage(
              onComplete: () {
                // Mark assessment as completed in auth state
                context.read<AuthBloc>().add(const AuthSetAssessmentCompleted());
                // Navigate to feed after assessment completion
                GoRouter.of(context).go(AppRouter.feed);
              },
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
