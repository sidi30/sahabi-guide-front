import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

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
    ),
  );
  
  // Initialize services
  await sl<NotificationService>().initialize();
}
