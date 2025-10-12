import '../../../auth/data/datasources/passport_auth_local_data_source.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../datasources/health_profile_local_data_source.dart';
import '../datasources/health_profile_remote_data_source.dart';
import '../models/health_profile_model.dart';

class HealthProfileRepositoryImpl implements HealthProfileRepository {
  final HealthProfileRemoteDataSource remoteDataSource;
  final HealthProfileLocalDataSource localDataSource;
  final PassportAuthLocalDataSource authLocalDataSource;

  HealthProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  Future<String> _getToken() async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }
    return token;
  }

  Future<String> _getUserId() async {
    // Extraire l'userId depuis le profil pilgrim sauvegardé
    final profile = await authLocalDataSource.getPilgrimProfile();
    if (profile?.id == null) {
      throw Exception('Utilisateur non identifié');
    }
    return profile!.id!;
  }

  @override
  Future<HealthProfileModel> getHealthProfile() async {
    try {
      // Essayer d'abord le cache local
      final cachedProfile = await localDataSource.getCachedHealthProfile();
      if (cachedProfile != null) {
        // Récupérer depuis le serveur en arrière-plan pour la prochaine fois
        _refreshHealthProfile();
        return cachedProfile;
      }

      // Si pas de cache, récupérer depuis le serveur
      final token = await _getToken();
      final userId = await _getUserId();
      final profile = await remoteDataSource.getHealthProfile(userId, token);
      
      // Mettre en cache
      await localDataSource.cacheHealthProfile(profile);
      
      return profile;
    } catch (e) {
      // Si erreur réseau, retourner le cache si disponible
      final cachedProfile = await localDataSource.getCachedHealthProfile();
      if (cachedProfile != null) {
        return cachedProfile;
      }
      throw Exception('Erreur de récupération du profil santé: $e');
    }
  }

  Future<void> _refreshHealthProfile() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      final profile = await remoteDataSource.getHealthProfile(userId, token);
      await localDataSource.cacheHealthProfile(profile);
    } catch (e) {
      print('Erreur lors du rafraîchissement du profil santé: $e');
    }
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(HealthProfileModel profile) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      final updatedProfile = await remoteDataSource.updateHealthProfile(userId, profile, token);
      
      // Mettre à jour le cache
      await localDataSource.cacheHealthProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e) {
      throw Exception('Erreur de mise à jour du profil santé: $e');
    }
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }
}

