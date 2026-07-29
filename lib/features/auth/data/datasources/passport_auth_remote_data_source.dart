import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/passport_auth_models.dart';
import '../exceptions/auth_exceptions.dart';

abstract class PassportAuthRemoteDataSource {
  Future<PassportAuthResponse> login(String passportNo);
  Future<PassportAuthResponse> verifyOtp(String passportNo, String otpCode);
  Future<PassportAuthResponse> validateToken(String token);
  Future<PassportAuthResponse> resendOtp(String passportNo);
  Future<PassportAuthResponse> logout(String token);
  Future<PilgrimProfile> getPilgrimProfile(String token);

  // Auth par email (self-signup passwordless)
  Future<PassportAuthResponse> requestEmailCode(String email);
  Future<PassportAuthResponse> verifyEmailCode(String email, String otpCode);
  Future<PassportAuthResponse> resendEmailCode(String email);

  // Suppression de compte (JWT requis)
  Future<PassportAuthResponse> deleteAccount(String token);

  // Mise à jour du profil par le pèlerin (self-service, JWT requis)
  Future<PilgrimProfile> updatePilgrimProfile(String token, Map<String, dynamic> data);
}

class PassportAuthRemoteDataSourceImpl implements PassportAuthRemoteDataSource {
  final DioClient dioClient;

  PassportAuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<PassportAuthResponse> login(String passportNo) async {
    try {
      final request = PassportLoginRequest(passportNo: passportNo);
      final response = await dioClient.post(
        '/api/auth/passport/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PassportAuthResponse.fromJson(response.data);
      } else {
        throw Exception('Numéro de passeport non trouvé');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw PassportNotFoundException(
          'Numéro de passeport non enregistré',
        );
      } else if (e.response?.statusCode == 400) {
        throw PassportValidationException(
          e.response?.data['message'] ?? 'Numéro de passeport invalide',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<PassportAuthResponse> verifyOtp(String passportNo, String otpCode) async {
    try {
      final request = PassportVerifyRequest(
        passportNo: passportNo,
        otpCode: otpCode,
      );
      
      final response = await dioClient.post(
        '/api/auth/passport/verify',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PassportAuthResponse.fromJson(response.data);
      } else {
        throw Exception('Code OTP invalide');
      }
    } on DioException catch (e) {
      // Extraire le message d'erreur du backend
      String errorMessage = 'Code OTP invalide';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? errorMessage;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erreur de vérification OTP: $e');
    }
  }

  @override
  Future<PassportAuthResponse> validateToken(String token) async {
    try {
      final request = PassportValidateRequest(token: token);
      final response = await dioClient.post(
        '/api/auth/passport/validate',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PassportAuthResponse.fromJson(response.data);
      } else {
        throw AuthNetworkException(
            'Réponse inattendue du serveur (${response.statusCode})');
      }
    } on DioException catch (e) {
      // Distinguer un VRAI rejet d'auth (401/403) d'une erreur réseau/serveur :
      // seul le rejet explicite doit entraîner la destruction de la session.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw AuthRejectedException('Token invalide ou expiré');
      }
      throw AuthNetworkException('Erreur réseau lors de la validation: ${e.message}');
    } on AuthNetworkException {
      rethrow;
    } catch (e) {
      throw AuthNetworkException('Erreur de validation du token: $e');
    }
  }

  @override
  Future<PassportAuthResponse> resendOtp(String passportNo) async {
    try {
      final request = PassportResendRequest(passportNo: passportNo);
      final response = await dioClient.post(
        '/api/auth/passport/resend',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PassportAuthResponse.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du renvoi du code OTP');
      }
    } catch (e) {
      throw Exception('Erreur de renvoi OTP: $e');
    }
  }

  @override
  Future<PassportAuthResponse> logout(String token) async {
    try {
      final response = await dioClient.post(
        '/api/auth/passport/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PassportAuthResponse.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la déconnexion');
      }
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  @override
  Future<PassportAuthResponse> requestEmailCode(String email) async {
    try {
      final response = await dioClient.post(
        '/api/auth/email/request',
        data: {'email': email},
      );
      return PassportAuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      String msg = 'Impossible d\'envoyer le code';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<PassportAuthResponse> verifyEmailCode(String email, String otpCode) async {
    try {
      final response = await dioClient.post(
        '/api/auth/email/verify',
        data: {'email': email, 'otpCode': otpCode},
      );
      return PassportAuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      String msg = 'Code invalide';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur de vérification: $e');
    }
  }

  @override
  Future<PassportAuthResponse> resendEmailCode(String email) async {
    try {
      final response = await dioClient.post(
        '/api/auth/email/resend',
        data: {'email': email},
      );
      return PassportAuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur de renvoi du code: $e');
    }
  }

  @override
  Future<PassportAuthResponse> deleteAccount(String token) async {
    try {
      final response = await dioClient.delete(
        '/api/auth/account',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return PassportAuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      String msg = 'Suppression impossible';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur de suppression: $e');
    }
  }

  @override
  Future<PilgrimProfile> updatePilgrimProfile(String token, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/api/auth/passport/profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        return PilgrimProfile.fromJson(response.data);
      }
      throw Exception('Réponse invalide du serveur (${response.statusCode})');
    } on DioException catch (e) {
      String msg = 'Mise à jour du profil impossible';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur de mise à jour du profil: $e');
    }
  }

  @override
  Future<PilgrimProfile> getPilgrimProfile(String token) async {
    try {
      final response = await dioClient.get(
        '/api/auth/passport/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return PilgrimProfile.fromJson(response.data);
      } else {
        throw Exception('Réponse invalide du serveur (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erreur serveur (${e.response?.statusCode}): ${e.response?.data}');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue lors de la récupération du profil: $e');
    }
  }
}
