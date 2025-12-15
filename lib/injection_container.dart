// lib/injection_container.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========================================
// CORE
// ========================================
import 'core/config/app_config.dart';
import 'core/network/interceptors/dio_logger_interceptor.dart';

// ========================================
// AUTH FEATURE
// ========================================
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_remote_datasource.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/ui/providers/auth_provider.dart';

// ========================================
// ASSISTANT FEATURE
// ========================================
import 'features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'features/assistant/data/repositories/assistant_repository_impl.dart';
import 'features/assistant/domain/repositories/assistant_repository.dart';
import 'features/assistant/domain/usecases/assistant_usecases.dart';
import 'features/assistant/ui/providers/assistant_provider.dart';

// ========================================
// DOCUMENTS FEATURE (📌 SINGULAR: document)
// ========================================
import 'features/document/data/datasources/documents_local_datasource.dart';
import 'features/document/data/datasources/documents_remote_datasource.dart';
import 'features/document/data/repositories/documents_repository_impl.dart';
import 'features/document/domain/repositories/documents_repository.dart';
import 'features/document/domain/usecases/documents_usecases.dart';
import 'features/document/ui/providers/documents_provider.dart';

// ========================================
// PROFILE FEATURE
// ========================================
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/profile_usecases.dart';
import 'features/profile/ui/providers/profile_provider.dart';

// ========================================
// HOME FEATURE (FilesProvider)
// ========================================
import 'features/home/ui/providers/files_provider.dart';

// Instancia global de GetIt (Service Locator)
final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app
Future<void> init() async {
  // ========================================
  // EXTERNAL
  // ========================================

  // SharedPreferences (Singleton)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ========================================
  // CORE - DIO CLIENTS
  // ========================================

  // Dio (HTTP Client) - Gateway API
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiGatewayBaseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptor de logging
    if (AppConfig.enableDebugLogs) {
      dio.interceptors.add(DioLoggerInterceptor(serviceName: 'API Gateway'));
    }

    return dio;
  }, instanceName: 'gateway');

  // Dio (HTTP Client) - Core IA API
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.coreAIBaseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptor de logging
    if (AppConfig.enableDebugLogs) {
      dio.interceptors.add(DioLoggerInterceptor(serviceName: 'Core IA'));
    }

    return dio;
  }, instanceName: 'coreIA');

  // ========================================
  // AUTH FEATURE
  // ========================================

  // Provider (ViewModel)
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      validateTokenUseCase: sl(),
      getCachedUserUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ValidateTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(instanceName: 'gateway'),
      baseUrl: AppConfig.apiGatewayBaseUrl,
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ========================================
  // ASSISTANT FEATURE (✅ ACTUALIZADO)
  // ========================================

  // Provider
  sl.registerFactory(
    () => AssistantProvider(
      createSessionUseCase: sl(),
      sendMessageUseCase: sl(),
      getHistoryUseCase: sl(),
      deleteSessionUseCase: sl(),
    ),
  );

  // Use Cases (✅ NUEVOS)
  sl.registerLazySingleton(() => CreateSessionUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSessionUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AssistantRemoteDataSource>(
    () => AssistantRemoteDataSourceImpl(
      dio: sl(instanceName: 'coreIA'), // ✅ Usa Core IA
    ),
  );

  // ========================================
  // DOCUMENTS FEATURE
  // ========================================

  // Provider (ViewModel)
  sl.registerFactory(
    () => DocumentsProvider(
      getDocumentsUseCase: sl(),
      getDocumentByIdUseCase: sl(),
      uploadDocumentUseCase: sl(),
      deleteDocumentUseCase: sl(),
      searchDocumentsUseCase: sl(),
      watchDocumentStatusUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentByIdUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDocumentUseCase(sl()));
  sl.registerLazySingleton(() => SearchDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => WatchDocumentStatusUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DocumentsRepository>(
    () =>
        DocumentsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<DocumentsRemoteDataSource>(
    () => DocumentsRemoteDataSourceImpl(
      dio: sl(instanceName: 'gateway'),
      baseUrl: AppConfig.apiGatewayBaseUrl,
    ),
  );

  sl.registerLazySingleton<DocumentsLocalDataSource>(
    () => DocumentsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ========================================
  // PROFILE FEATURE
  // ========================================

  // Provider (ViewModel)
  sl.registerFactory(
    () => ProfileProvider(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      updatePreferencesUseCase: sl(),
      getCachedProfileUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePreferencesUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: sl(instanceName: 'gateway'),
      baseUrl: AppConfig.apiGatewayBaseUrl,
    ),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ========================================
  // HOME FEATURE (FilesProvider)
  // ========================================

  // Provider simple sin dependencias complejas
  sl.registerFactory(() => FilesProvider());
}
