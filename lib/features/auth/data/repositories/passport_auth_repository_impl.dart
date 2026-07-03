import '../datasources/passport_auth_local_data_source.dart';
import '../datasources/passport_auth_remote_data_source.dart';
import '../models/passport_auth_models.dart';

abstract class PassportAuthRepository {
  Future<PassportAuthResponse> login(String passportNo);
  Future<PassportAuthResponse> verifyOtp(String passportNo, String otpCode);
  Future<PassportAuthResponse> validateToken(String token);
  Future<PassportAuthResponse> resendOtp(String passportNo);
  Future<PassportAuthResponse> logout();
  Future<PilgrimProfile?> getPilgrimProfile({bool forceRefresh = false});
  Future<bool> isLoggedIn();
  Future<void> clearSession();

  // Auth par email (self-signup passwordless)
  Future<PassportAuthResponse> requestEmailCode(String email);
  Future<PassportAuthResponse> verifyEmailCode(String email, String otpCode);
  Future<PassportAuthResponse> resendEmailCode(String email);

  // Suppression de compte in-app
  Future<PassportAuthResponse> deleteAccount();

  // Mise à jour du profil (self-service)
  Future<PilgrimProfile> updatePilgrimProfile(Map<String, dynamic> data);
}

class PassportAuthRepositoryImpl implements PassportAuthRepository {
  final PassportAuthRemoteDataSource remoteDataSource;
  final PassportAuthLocalDataSource localDataSource;

  PassportAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PassportAuthResponse> login(String passportNo) async {
    try {
      final response = await remoteDataSource.login(passportNo);
      if (response.success) {
        await localDataSource.savePassportNo(passportNo);
      }
      return response;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<PassportAuthResponse> verifyOtp(String passportNo, String otpCode) async {
    try {
      final response = await remoteDataSource.verifyOtp(passportNo, otpCode);
      if (response.success && response.token != null) {
        await localDataSource.saveToken(response.token!);
        // NE PAS récupérer le profil ici car cela peut bloquer l'authentification
        // Le profil sera récupéré par le AuthProvider après la navigation
      }
      return response;
    } catch (e) {
      throw Exception('Erreur de vérification OTP: $e');
    }
  }

  @override
  Future<PassportAuthResponse> validateToken(String token) async {
    try {
      return await remoteDataSource.validateToken(token);
    } catch (e) {
      throw Exception('Erreur de validation du token: $e');
    }
  }

  @override
  Future<PassportAuthResponse> resendOtp(String passportNo) async {
    try {
      return await remoteDataSource.resendOtp(passportNo);
    } catch (e) {
      throw Exception('Erreur de renvoi OTP: $e');
    }
  }

  @override
  Future<PassportAuthResponse> logout() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        final response = await remoteDataSource.logout(token);
        await clearSession();
        return response;
      } else {
        await clearSession();
        return PassportAuthResponse(
          success: true,
          message: 'Déconnexion réussie',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      // Même en cas d'erreur, on nettoie la session locale
      await clearSession();
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  @override
  Future<PilgrimProfile?> getPilgrimProfile({bool forceRefresh = false}) async {
    try {
      // Sauf rafraîchissement forcé, essayer d'abord le cache local.
      if (!forceRefresh) {
        final localProfile = await localDataSource.getPilgrimProfile();
        if (localProfile != null) {
          return localProfile;
        }
      }

      // Pas de cache (ou rafraîchissement forcé) : récupérer depuis le serveur
      final token = await localDataSource.getToken();
      if (token != null) {
        final profile = await remoteDataSource.getPilgrimProfile(token);
        await localDataSource.savePilgrimProfile(profile);
        return profile;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur de récupération du profil: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    if (token == null) return false;

    try {
      final response = await validateToken(token);
      return response.success;
    } catch (e) {
      // Si le token est invalide, nettoyer la session
      await clearSession();
      return false;
    }
  }

  @override
  Future<void> clearSession() async {
    await localDataSource.deleteToken();
    await localDataSource.deletePilgrimProfile();
    await localDataSource.deletePassportNo();
  }

  @override
  Future<PassportAuthResponse> requestEmailCode(String email) async {
    return await remoteDataSource.requestEmailCode(email);
  }

  @override
  Future<PassportAuthResponse> verifyEmailCode(String email, String otpCode) async {
    final response = await remoteDataSource.verifyEmailCode(email, otpCode);
    if (response.success && response.token != null) {
      await localDataSource.saveToken(response.token!);
    }
    return response;
  }

  @override
  Future<PassportAuthResponse> resendEmailCode(String email) async {
    return await remoteDataSource.resendEmailCode(email);
  }

  @override
  Future<PilgrimProfile> updatePilgrimProfile(Map<String, dynamic> data) async {
    final token = await localDataSource.getToken();
    if (token == null) {
      throw Exception('Aucune session active');
    }
    final updated = await remoteDataSource.updatePilgrimProfile(token, data);
    // Rafraîchir le cache local du profil.
    await localDataSource.savePilgrimProfile(updated);
    return updated;
  }

  @override
  Future<PassportAuthResponse> deleteAccount() async {
    final token = await localDataSource.getToken();
    if (token == null) {
      throw Exception('Aucune session active');
    }
    final response = await remoteDataSource.deleteAccount(token);
    // Quelle que soit la réponse, on nettoie la session locale.
    await clearSession();
    return response;
  }
}
