import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/passport_auth_models.dart';

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
        '/api/pilgrim/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PilgrimProfile.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      throw Exception('Erreur de récupération du profil: $e');
    }
  }
}
