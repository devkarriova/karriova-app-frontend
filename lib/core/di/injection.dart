import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../services/inactivity_service.dart';
import '../config/app_config.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/feed/data/datasources/post_remote_datasource.dart';
import '../../features/feed/data/datasources/media_remote_datasource.dart';
import '../../features/feed/data/repositories/post_repository_impl.dart';
import '../../features/feed/domain/repositories/post_repository.dart';
import '../../features/feed/presentation/bloc/feed_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/datasources/chat_websocket_service.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(),
  );

  // Dio for Retrofit-based services
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getIt<FlutterSecureStorage>().read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    return dio;
  });

  // Services
  getIt.registerLazySingleton<InactivityService>(
    () => InactivityService(
      inactivityDuration: const Duration(minutes: 15),
    ),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt(),
      secureStorage: getIt(),
    ),
  );

  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<MediaRemoteDataSource>(
    () => MediaRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: getIt()),
  );

  // WebSocket Service for real-time chat
  getIt.registerLazySingleton<ChatWebSocketService>(
    () => ChatWebSocketService(
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      apiClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt()),
  );

  getIt.registerFactory<FeedBloc>(
    () => FeedBloc(
      postRepository: getIt(),
      mediaDataSource: getIt(),
    ),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: getIt()),
  );

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      chatRepository: getIt(),
      webSocketService: getIt(),
    ),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(searchRepository: getIt()),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(notificationRepository: getIt()),
  );
}
