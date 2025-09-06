import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sahabi_guide/features/home/data/datasources/home_remote_data_source.dart';
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
import '../../features/rituals/data/repositories/rituals_repository_impl.dart';
import '../../features/rituals/domain/repositories/rituals_repository.dart';
import '../../features/rituals/domain/usecases/get_rituals_usecase.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';

import '../../features/health/data/datasources/health_remote_data_source.dart';
import '../../features/health/data/repositories/health_repository_impl.dart';
import '../../features/health/domain/repositories/health_repository.dart';
import '../../features/health/domain/usecases/get_health_profile_usecase.dart';
import '../../features/health/domain/usecases/get_pilgrim_health_profile_usecase.dart';

import '../../features/map/data/datasources/position_remote_data_source.dart';
import '../../features/map/data/datasources/makkah_locations_data_source.dart';
import '../../features/map/data/repositories/pilgrim_position_repository_impl.dart';
import '../../features/map/data/repositories/makkah_locations_repository_impl.dart';
import '../../features/map/domain/repository/pilgrim_position_repository.dart';
import '../../features/map/domain/repository/makkah_locations_repository.dart';
import '../../features/map/domain/usecases/get_latest_pilgrim_position_usecase.dart';
import '../../features/map/domain/usecases/get_makkah_locations_usecase.dart';

import '../../features/alerts/data/datasources/alerts_remote_data_source.dart';
import '../../features/alerts/data/repositories/alerts_repository_impl.dart';
import '../../features/alerts/domain/repositories/alerts_repository.dart';
import '../../features/alerts/domain/usecases/get_pilgrim_alerts_usecase.dart';

import '../../shared/services/audio_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/location_service.dart';

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
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      authRepository: sl(),
    ),
  );

  // HomeRemoteDataSource
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      sl(),
      sl(),
    ),
  );

  // Health Feature
  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(sl(), sl()),
  );

  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetHealthProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPilgrimHealthProfileUseCase(sl()));

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

  // Makkah Locations Feature
  sl.registerLazySingleton<MakkahLocationsDataSource>(
    () => MakkahLocationsDataSourceImpl(),
  );

  sl.registerLazySingleton<MakkahLocationsRepository>(
    () => MakkahLocationsRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton(() => GetMakkahLocationsUseCase(repository: sl()));

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
