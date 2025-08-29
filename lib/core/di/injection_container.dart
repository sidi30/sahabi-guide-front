import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';

import '../../features/rituals/data/datasources/rituals_local_data_source.dart';
import '../../features/rituals/data/datasources/rituals_remote_data_source.dart';
import '../../features/rituals/data/repositories/rituals_repository_impl.dart';
import '../../features/rituals/domain/repositories/rituals_repository.dart';
import '../../features/rituals/domain/usecases/get_rituals_usecase.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';

import '../../features/health/data/datasources/health_remote_data_source.dart';
import '../../features/health/data/repositories/health_repository_impl.dart';
import '../../features/health/domain/repositories/health_repository.dart';
import '../../features/health/domain/usecases/get_health_profile_usecase.dart';

import '../../features/map/data/datasources/position_remote_data_source.dart';
import '../../features/map/data/repositories/pilgrim_position_repository_impl.dart';
import '../../features/map/domain/repository/pilgrim_position_repository.dart';
import '../../features/map/domain/usecases/get_latest_pilgrim_position_usecase.dart';

import '../../features/alerts/data/datasources/alerts_remote_data_source.dart';
import '../../features/alerts/data/repositories/alerts_repository_impl.dart';
import '../../features/alerts/domain/repositories/alerts_repository.dart';
import '../../features/alerts/domain/usecases/get_pilgrim_alerts_usecase.dart';

import '../../shared/services/audio_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/location_service.dart';
import '../../shared/services/connectivity_service.dart';

import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => AudioPlayer());
  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton(() => DioClient(sl()));

  // Services
  sl.registerLazySingleton<StorageService>(
    () => StorageService(sl(), sl()),
  );

  sl.registerLazySingleton<AudioService>(
    () => AudioService(sl()),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  sl.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
<<<<<<< HEAD

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(sl(), sl()),
  );

=======

>>>>>>> c6dd083 (impl::api-integrations for health, mapo pilgim psotion and alert)
  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Rituals Feature
  sl.registerLazySingleton<RitualsLocalDataSource>(
    () => RitualsLocalDataSourceImpl(),
  );
<<<<<<< HEAD

  sl.registerLazySingleton<RitualsRemoteDataSource>(
    () => RitualsRemoteDataSource(sl(), sl()),
  );

=======

>>>>>>> c6dd083 (impl::api-integrations for health, mapo pilgim psotion and alert)
  sl.registerLazySingleton<RitualsRepository>(
    () => RitualsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetRitualsUseCase(sl()));

  // Home Feature
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
<<<<<<< HEAD

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl(), sl()),
  );

=======

>>>>>>> c6dd083 (impl::api-integrations for health, mapo pilgim psotion and alert)
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      authRepository: sl(),
    ),
  );

  // Health Feature
  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSource(sl(), sl()),
  );

  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetHealthProfileUseCase(sl()));

  // Map/Position Feature
  sl.registerLazySingleton<PositionRemoteDataSource>(
    () => PositionRemoteDataSource(sl(), sl()),
  );

  sl.registerLazySingleton<PilgrimPositionRepository>(
    () => PilgrimPositionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetLatestPilgrimPositionUseCase(sl()));

  // Alerts Feature
  sl.registerLazySingleton<AlertsRemoteDataSource>(
    () => AlertsRemoteDataSource(sl(), sl()),
  );

  sl.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetPilgrimAlertsUseCase(sl()));

  // Initialize services
  await sl<NotificationService>().initialize();
}
