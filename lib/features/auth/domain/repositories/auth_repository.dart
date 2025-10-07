import '../../../../shared/models/pilgrim_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> loginWithPassport(String passportNo);
  Future<AuthResponse> verifyOtp(String passportNo, String otpCode);
  Future<void> logout();
  Future<void> resendOtp(String passportNo);
  Future<PilgrimModel?> getCurrentPilgrim();
  Future<bool> isLoggedIn();
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
}
