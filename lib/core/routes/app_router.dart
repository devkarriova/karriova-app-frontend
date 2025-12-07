import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';

class AppRouter {
  static const String auth = '/';
  static const String login = '/';
  static const String signup = '/?mode=signup';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: auth,
    routes: [
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
      // Add more routes here as you create new features
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
