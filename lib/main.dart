import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  void initState() {
    super.initState();
    _inactivityService = getIt<InactivityService>();
    _authBloc = getIt<AuthBloc>()..add(const AuthCheckStatusRequested());

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
        // User is logged in, enable inactivity tracking
        _inactivityService.enable(
          onTimeout: () {
            // Auto logout on inactivity
            _authBloc.add(const AuthLogoutRequested());
          },
        );

        // Load followingIds for the follow button state across the app
        final followBloc = getIt<FollowBloc>();
        if (followBloc.state.followingIds.isEmpty) {
          followBloc.add(const LoadFollowingIdsEvent());
        }
      } else {
        // User is not logged in, disable tracking
        _inactivityService.disable();
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
      ],
      child: InactivityDetector(
        inactivityService: _inactivityService,
        child: MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
