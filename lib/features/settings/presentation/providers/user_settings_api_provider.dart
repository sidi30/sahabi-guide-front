import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/user_settings_model.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import '../../domain/usecases/update_notification_settings_usecase.dart';
import '../../domain/usecases/reset_settings_usecase.dart';

// Provider pour récupérer les paramètres utilisateur
final userSettingsProvider = FutureProvider<UserSettingsModel?>((ref) async {
  final getUserSettingsUseCase = sl<GetUserSettingsUseCase>();
  try {
    return await getUserSettingsUseCase();
  } catch (e) {
    AppLogger.error('Erreur récupération paramètres', error: e);
    return null;
  }
});

// Notifier pour gérer l'état des paramètres
class UserSettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel?>> {
  final GetUserSettingsUseCase getUserSettingsUseCase;
  final UpdateUserSettingsUseCase updateUserSettingsUseCase;
  final UpdateNotificationSettingsUseCase updateNotificationSettingsUseCase;
  final ResetSettingsUseCase resetSettingsUseCase;

  UserSettingsNotifier({
    required this.getUserSettingsUseCase,
    required this.updateUserSettingsUseCase,
    required this.updateNotificationSettingsUseCase,
    required this.resetSettingsUseCase,
  }) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await getUserSettingsUseCase();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    try {
      final updated = await updateUserSettingsUseCase(settings);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateNotifications(UserSettingsModel settings) async {
    try {
      final updated = await updateNotificationSettingsUseCase(settings);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaults = await resetSettingsUseCase();
      state = AsyncValue.data(defaults);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

// Provider pour le notifier
final userSettingsNotifierProvider = StateNotifierProvider<UserSettingsNotifier, AsyncValue<UserSettingsModel?>>((ref) {
  return UserSettingsNotifier(
    getUserSettingsUseCase: sl<GetUserSettingsUseCase>(),
    updateUserSettingsUseCase: sl<UpdateUserSettingsUseCase>(),
    updateNotificationSettingsUseCase: sl<UpdateNotificationSettingsUseCase>(),
    resetSettingsUseCase: sl<ResetSettingsUseCase>(),
  );
});




