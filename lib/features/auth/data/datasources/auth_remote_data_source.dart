import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/pilgrim_model.dart';
import '../../../../core/utils/constants.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> loginWithPassport(String passportNo);
  Future<AuthResponse> verifyOtp(String passportNo, String otpCode);
  Future<void> logout();
  Future<void> resendOtp(String passportNo);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthResponse> loginWithPassport(String passportNo) async {
    try {
      final response = await dioClient.post(
        '/api/auth/passport/login',
        data: PassportLoginRequest(passportNo: passportNo).toJson(),
      );
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String passportNo, String otpCode) async {
    try {
      final response = await dioClient.post(
        '/api/auth/passport/verify',
        data: PassportVerifyRequest(
          passportNo: passportNo,
          otpCode: otpCode,
        ).toJson(),
      );
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur de vérification: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/api/auth/passport/logout');
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  @override
  Future<void> resendOtp(String passportNo) async {
    try {
      await dioClient.post(
        '/api/auth/passport/resend',
        data: PassportLoginRequest(passportNo: passportNo).toJson(),
      );
    } catch (e) {
      throw Exception('Erreur de renvoi: $e');
    }
  }
}
