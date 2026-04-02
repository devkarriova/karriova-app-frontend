import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/admin/presentation/pages/admin_events_page.dart';
import '../../features/admin/presentation/pages/admin_assessments_page.dart';
import '../../features/admin/presentation/pages/admin_feedback_page.dart';
import '../../features/admin/presentation/pages/admin_reminders_page.dart';
import '../../features/admin/presentation/pages/admin_moderation_page.dart';
import '../../features/assessment/presentation/pages/assessment_page.dart';
import '../../features/assessment/presentation/bloc/assessment_bloc.dart';
import '../../features/profile/presentation/pages/profile_setup_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/account_settings_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/privacy_settings_page.dart';
import '../../features/settings/presentation/pages/appearance_settings_page.dart';
import '../../features/settings/presentation/pages/help_center_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_of_service_page.dart';
import '../../features/opportunities/presentation/pages/internships_page.dart';
import '../../features/opportunities/presentation/pages/events_page.dart';
import '../di/injection.dart';

/// Listenable that notifies when auth state changes - triggers GoRouter refresh
class AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;
  AuthState? _previousState;

  AuthChangeNotifier(AuthBloc authBloc) {
    // Get initial state
    _previousState = authBloc.state;

    // Listen to both the stream AND use a periodic check as fallback
    _subscription = authBloc.stream.listen((state) {
      if (_previousState != state) {
        _previousState = state;
        notifyListeners();
      }
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
  static const String internships = '/internships';
  static const String events = '/events';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminEvents = '/admin/events';
  static const String adminAssessments = '/admin/assessments';
  static const String adminFeedback = '/admin/feedback';
  static const String adminReminders = '/admin/reminders';
  static const String adminModeration = '/admin/moderation';
  static const String profileSetup = '/profile-setup';
  static const String assessment = '/assessment';
  static const String assessmentResults = '/assessment/results';

  // Chat routes
  static const String chatConversation = '/chat/conversation';

  // Settings routes
  static const String settings = '/settings';
  static const String settingsAccount = '/settings/account';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsHelp = '/settings/help';
  static const String settingsAbout = '/settings/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

  // Routes that don't require authentication
  static const List<String> _publicRoutes = [
    '/',
    '/privacy-policy',
    '/terms-of-service',
  ];

  // Auth change notifier for reactive route refresh
  static AuthChangeNotifier? _authNotifier;
  static AuthChangeNotifier get _authChangeNotifier {
    _authNotifier ??= AuthChangeNotifier(getIt<AuthBloc>());
    return _authNotifier!;
  }

  static final GoRouter router = GoRouter(
    initialLocation: auth, // Default landing page is login
    refreshListenable: _authChangeNotifier, // Refresh routes when auth changes
    redirect: (context, state) {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final currentPath = state.uri.path;
      final isPublicRoute =
          _publicRoutes.contains(currentPath) || currentPath.isEmpty;

      // If NOT authenticated and trying to access protected route,
      // redirect to auth page
      if (!isAuthenticated && !isPublicRoute) {
        return auth;
      }

      // If authenticated user is on auth page, redirect based on assessment status
      if (isAuthenticated && (currentPath == '/' || currentPath.isEmpty)) {
        // Wait for assessment status to be determined before redirecting
        // The auth page will trigger the assessment check
        if (authState.assessmentCompleted == null) {
          // Don't redirect yet - let auth page check assessment status
          // This will trigger another state change and redirect will run again
          return null;
        }

        if (authState.assessmentCompleted == false) {
          return profileSetup;
        }
        return feed;
      }

      return null; // No redirect needed
    },
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

      // Chat Conversation Page (direct conversation view)
      GoRoute(
        path: '/chat/conversation',
        name: 'chat-conversation',
        pageBuilder: (context, state) {
          final conversationId =
              state.uri.queryParameters['conversationId'] ?? '';
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          return MaterialPage(
            child: ChatConversationPage(
              conversationId: conversationId,
              otherUserId: otherUserId,
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

      GoRoute(
        path: '/internships',
        name: 'internships',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: InternshipsPage(),
          );
        },
      ),

      GoRoute(
        path: '/events',
        name: 'events',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: EventsPage(),
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

      // Admin Events Page
      GoRoute(
        path: '/admin/events',
        name: 'admin-events',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminEventsPage(),
          );
        },
      ),

      // Admin Assessments Page
      GoRoute(
        path: '/admin/assessments',
        name: 'admin-assessments',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminAssessmentsPage(),
          );
        },
      ),

      // Admin Feedback Page
      GoRoute(
        path: '/admin/feedback',
        name: 'admin-feedback',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminFeedbackPage(),
          );
        },
      ),

      // Admin Reminders Page
      GoRoute(
        path: '/admin/reminders',
        name: 'admin-reminders',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminRemindersPage(),
          );
        },
      ),

      // Admin Moderation Page
      GoRoute(
        path: '/admin/moderation',
        name: 'admin-moderation',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AdminModerationPage(),
          );
        },
      ),

      // Profile Setup Page (for first-time users)
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: ProfileSetupPage(),
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
                context
                    .read<AuthBloc>()
                    .add(const AuthSetAssessmentCompleted());
                // Navigate to feed after assessment completion
                GoRouter.of(context).go(AppRouter.feed);
              },
            ),
          );
        },
      ),

      // Assessment Results Page
      GoRoute(
        path: '/assessment/results',
        name: 'assessment-results',
        pageBuilder: (context, state) {
          final bloc = getIt<AssessmentBloc>();
          final result = bloc.state.result;
          return MaterialPage(
            child: AssessmentResultsFullPage(
              result: result!,
              onContinue: () {
                // Mark assessment as completed in auth state
                context
                    .read<AuthBloc>()
                    .add(const AuthSetAssessmentCompleted());
                // Navigate to feed
                GoRouter.of(context).go(AppRouter.feed);
              },
            ),
          );
        },
      ),

      // Settings Page
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: SettingsPage(),
          );
        },
      ),

      // Account Settings Page
      GoRoute(
        path: '/settings/account',
        name: 'settings-account',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AccountSettingsPage(),
          );
        },
      ),

      // Notification Settings Page
      GoRoute(
        path: '/settings/notifications',
        name: 'settings-notifications',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: NotificationSettingsPage(),
          );
        },
      ),

      // Privacy Settings Page
      GoRoute(
        path: '/settings/privacy',
        name: 'settings-privacy',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: PrivacySettingsPage(),
          );
        },
      ),

      // Appearance Settings Page
      GoRoute(
        path: '/settings/appearance',
        name: 'settings-appearance',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AppearanceSettingsPage(),
          );
        },
      ),

      // Help Center Page
      GoRoute(
        path: '/settings/help',
        name: 'settings-help',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: HelpCenterPage(),
          );
        },
      ),

      // About Page
      GoRoute(
        path: '/settings/about',
        name: 'settings-about',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: AboutPage(),
          );
        },
      ),

      // Privacy Policy Page
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: PrivacyPolicyPage(),
          );
        },
      ),

      // Terms of Service Page
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: TermsOfServicePage(),
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
