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
        throw Exception('Token invalide');
      }
    } catch (e) {
      throw Exception('Erreur de validation du token: $e');
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
