import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../shared/services/storage_service.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/rituals/data/datasources/rituals_local_data_source.dart';
import '../features/rituals/data/datasources/rituals_remote_data_source.dart';
import '../features/rituals/data/repositories/rituals_repository_impl.dart';
import '../features/rituals/domain/repositories/rituals_repository.dart';
import '../features/alerts/data/datasources/alerts_remote_data_source.dart';
import '../features/alerts/data/repositories/alerts_repository_impl.dart';
import '../features/alerts/domain/repositories/alerts_repository.dart';
import '../features/health/data/datasources/health_remote_data_source.dart';
import '../features/health/data/repositories/health_repository_impl.dart';
import '../features/health/domain/repositories/health_repository.dart';
import '../features/map/data/datasources/geo_remote_data_source.dart';
import '../features/map/data/repositories/geo_repository_impl.dart';
import '../features/map/domain/repositories/geo_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core dependencies
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<Dio>()));
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // Auth dependencies
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Rituals dependencies
  getIt.registerLazySingleton<RitualsLocalDataSource>(
    () => RitualsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<RitualsRemoteDataSource>(
    () => RitualsRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<RitualsRepository>(
    () => RitualsRepositoryImpl(
      localDataSource: getIt<RitualsLocalDataSource>(),
      remoteDataSource: getIt<RitualsRemoteDataSource>(),
    ),
  );

  // Alerts dependencies
  getIt.registerLazySingleton<AlertsRemoteDataSource>(
    () => AlertsRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(remoteDataSource: getIt<AlertsRemoteDataSource>()),
  );

  // Health dependencies
  getIt.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(remoteDataSource: getIt<HealthRemoteDataSource>()),
  );

  // Geo dependencies
  getIt.registerLazySingleton<GeoRemoteDataSource>(
    () => GeoRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<GeoRepository>(
    () => GeoRepositoryImpl(remoteDataSource: getIt<GeoRemoteDataSource>()),
  );
}