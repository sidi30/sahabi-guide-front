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

// Passport Auth
import '../../features/auth/data/datasources/passport_auth_local_data_source.dart';
import '../../features/auth/data/datasources/passport_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/passport_auth_repository_impl.dart';
import '../../features/auth/domain/usecases/passport_auth_usecases.dart';

import '../../features/rituals/data/datasources/rituals_local_data_source.dart';
import '../../features/rituals/data/datasources/rituals_remote_data_source.dart';
import '../../features/rituals/data/repositories/rituals_repository_impl.dart';
import '../../features/rituals/domain/repositories/rituals_repository.dart';
import '../../features/rituals/domain/usecases/get_rituals_usecase.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';

import '../../features/health/domain/usecases/get_health_profile_usecase.dart';

// Connectivity Feature
import '../../features/connectivity/data/datasources/connectivity_remote_data_source.dart';
import '../../features/connectivity/data/datasources/connectivity_local_data_source.dart';
import '../../features/connectivity/data/repositories/connectivity_repository_impl.dart';
import '../../features/connectivity/domain/repositories/connectivity_repository.dart';
import '../../features/connectivity/domain/usecases/get_connectivity_plans_usecase.dart';
import '../../features/connectivity/domain/usecases/get_user_subscriptions_usecase.dart';
import '../../features/connectivity/domain/usecases/subscribe_to_plan_usecase.dart';
import '../../features/connectivity/domain/usecases/topup_subscription_usecase.dart';

import '../../features/map/data/datasources/position_remote_data_source.dart';
import '../../features/map/data/repositories/pilgrim_position_repository_impl.dart';
import '../../features/map/domain/repository/pilgrim_position_repository.dart';
import '../../features/map/domain/usecases/get_latest_pilgrim_position_usecase.dart';
import '../../features/map/data/services/poi_service.dart';

// Tracking Feature
import '../../features/tracking/data/repositories/position_repository.dart';
import '../../features/tracking/data/services/position_tracking_service.dart';

// Alerts Feature
import '../../features/alerts/data/services/alerts_service.dart';

// Emergency Contacts Feature
import '../../features/emergency_contacts/data/services/emergency_contacts_service.dart';

import '../../features/alerts/data/datasources/alerts_remote_data_source.dart';
import '../../features/alerts/data/repositories/alerts_repository_impl.dart';
import '../../features/alerts/domain/repositories/alerts_repository.dart';
import '../../features/alerts/domain/usecases/get_pilgrim_alerts_usecase.dart';

// Settings Feature
import '../../features/settings/data/datasources/user_settings_remote_data_source.dart';
import '../../features/settings/data/datasources/user_settings_local_data_source.dart';
import '../../features/settings/data/datasources/contact_message_remote_data_source.dart';
import '../../features/settings/data/repositories/user_settings_repository_impl.dart';
import '../../features/settings/data/repositories/contact_message_repository_impl.dart';
import '../../features/settings/domain/repositories/user_settings_repository.dart';
import '../../features/settings/domain/repositories/contact_message_repository.dart';
import '../../features/settings/domain/usecases/get_user_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_user_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_notification_settings_usecase.dart';
import '../../features/settings/domain/usecases/reset_settings_usecase.dart';
import '../../features/settings/domain/usecases/send_contact_message_usecase.dart';
import '../../features/settings/domain/usecases/get_my_messages_usecase.dart';

// Health Feature
import '../../features/health/data/datasources/health_profile_remote_data_source.dart';
import '../../features/health/data/datasources/health_profile_local_data_source.dart';
import '../../features/health/data/repositories/health_profile_repository_impl.dart';
import '../../features/health/domain/repositories/health_profile_repository.dart';
import '../../features/health/domain/usecases/update_health_profile_usecase.dart';

import '../../shared/services/storage_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/location_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

import '../network/dio_client.dart';
import '../cache/cache_service.dart';

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
  sl.registerLazySingleton(() => CacheService(sl<SharedPreferences>()));

  // Services
  sl.registerLazySingleton<StorageService>(
    () => StorageService(sl(), sl()),
  );

  sl.registerLazySingleton<AudioService>(
    () => AudioService(),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  sl.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  // Auth Service
  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl(), sl()),
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

  // Passport Auth Feature
  sl.registerLazySingleton<PassportAuthRemoteDataSource>(
    () => PassportAuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PassportAuthLocalDataSource>(
    () => PassportAuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PassportAuthRepository>(
    () => PassportAuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => PassportLoginUseCase(sl()));
  sl.registerLazySingleton(() => PassportVerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => PassportResendOtpUseCase(sl()));
  sl.registerLazySingleton(() => PassportLogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetPilgrimProfileUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // Rituals Feature
  sl.registerLazySingleton<RitualsLocalDataSource>(
    () => RitualsLocalDataSourceImpl(sl<CacheService>()),
  );

  sl.registerLazySingleton<RitualsRemoteDataSource>(
    () => RitualsRemoteDataSource(sl(), sl()),
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

  // POI Service
  sl.registerLazySingleton(
      () => PoiService(dioClient: sl(), secureStorage: sl()));

// Position Tracking Feature
  sl.registerLazySingleton(() => PositionRepository(
        dioClient: sl(),
        secureStorage: sl(),
      ));

  sl.registerLazySingleton(() => PositionTrackingService(
        positionRepository: sl(),
        locationService: sl(),
      ));

  // Route History Feature - Commented out until implementation is ready
  // sl.registerLazySingleton(() => RouteHistoryRepository(
  //       dioClient: sl(),
  //       secureStorage: sl(),
  //     ));

  // Local Geofencing Service - Commented out until implementation is ready
  // sl.registerLazySingleton(() => LocalGeofencingService());

  // Alerts Feature
  sl.registerLazySingleton(
      () => AlertsService(dioClient: sl(), secureStorage: sl()));
  sl.registerLazySingleton<AlertsRemoteDataSource>(
    () => AlertsRemoteDataSource(sl(), sl()),
  );

  // Emergency Contacts Feature
  sl.registerLazySingleton(
      () => EmergencyContactsService(dioClient: sl(), secureStorage: sl()));

  sl.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetPilgrimAlertsUseCase(sl()));

  // Settings Feature
  sl.registerLazySingleton<UserSettingsRemoteDataSource>(
    () => UserSettingsRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<UserSettingsLocalDataSource>(
    () => UserSettingsLocalDataSourceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<UserSettingsRepository>(
    () => UserSettingsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => ResetSettingsUseCase(sl()));

  // Contact Feature
  sl.registerLazySingleton<ContactMessageRemoteDataSource>(
    () => ContactMessageRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ContactMessageRepository>(
    () => ContactMessageRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SendContactMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetMyMessagesUseCase(sl()));

  // Health Feature
  sl.registerLazySingleton<HealthProfileRemoteDataSource>(
    () => HealthProfileRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<HealthProfileLocalDataSource>(
    () => HealthProfileLocalDataSourceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<HealthProfileRepository>(
    () => HealthProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetHealthProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHealthProfileUseCase(sl()));

  // Connectivity Feature
  sl.registerLazySingleton<ConnectivityRemoteDataSource>(
    () =>
        ConnectivityRemoteDataSourceImpl(dioClient: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<ConnectivityLocalDataSource>(
    () => ConnectivityLocalDataSourceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<ConnectivityRepository>(
    () => ConnectivityRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetConnectivityPlansUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSubscriptionsUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToPlanUseCase(sl()));
  sl.registerLazySingleton(() => TopupSubscriptionUseCase(sl()));

  // Initialize services
  await sl<NotificationService>().initialize();
}
