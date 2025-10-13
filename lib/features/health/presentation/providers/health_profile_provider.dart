import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/health_profile_model.dart';
import '../../domain/usecases/get_health_profile_usecase.dart';
import '../../domain/usecases/update_health_profile_usecase.dart';

// Provider pour récupérer le profil santé
final healthProfileProvider = FutureProvider<HealthProfileModel?>((ref) async {
  final getHealthProfileUseCase = sl<GetHealthProfileUseCase>();
  try {
    return await getHealthProfileUseCase();
  } catch (e) {
    print('Erreur récupération profil santé: $e');
    return null;
  }
});

// Notifier pour gérer l'état du profil santé
class HealthProfileNotifier extends StateNotifier<AsyncValue<HealthProfileModel?>> {
  final GetHealthProfileUseCase getHealthProfileUseCase;
  final UpdateHealthProfileUseCase updateHealthProfileUseCase;

  HealthProfileNotifier({
    required this.getHealthProfileUseCase,
    required this.updateHealthProfileUseCase,
  }) : super(const AsyncValue.loading()) {
    loadHealthProfile();
  }

  Future<void> loadHealthProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await getHealthProfileUseCase();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateHealthProfile(HealthProfileModel profile) async {
    try {
      final updated = await updateHealthProfileUseCase(profile);
      state = AsyncValue.data(updated);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  void setProfile(HealthProfileModel profile) {
    state = AsyncValue.data(profile);
  }
}

// Provider pour le notifier
final healthProfileNotifierProvider = StateNotifierProvider<HealthProfileNotifier, AsyncValue<HealthProfileModel?>>((ref) {
  return HealthProfileNotifier(
    getHealthProfileUseCase: sl<GetHealthProfileUseCase>(),
    updateHealthProfileUseCase: sl<UpdateHealthProfileUseCase>(),
  );
});


