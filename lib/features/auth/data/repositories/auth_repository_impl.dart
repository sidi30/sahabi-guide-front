import '../../../../shared/models/pilgrim_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResponse> loginWithPassport(String passportNo) async {
    try {
      final authResponse = await remoteDataSource.loginWithPassport(passportNo);
      
      if (authResponse.success && authResponse.token != null) {
        await localDataSource.saveAuthToken(authResponse.token!);
        if (authResponse.pilgrim != null) {
          await localDataSource.savePilgrim(authResponse.pilgrim!);
        }
      }
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String passportNo, String otpCode) async {
    try {
      final authResponse = await remoteDataSource.verifyOtp(passportNo, otpCode);
      
      if (authResponse.success && authResponse.token != null) {
        await localDataSource.saveAuthToken(authResponse.token!);
        if (authResponse.pilgrim != null) {
          await localDataSource.savePilgrim(authResponse.pilgrim!);
        }
      }
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    }
    await localDataSource.clearAuthToken();
    await localDataSource.clearPilgrim();
  }

  @override
  Future<void> resendOtp(String passportNo) async {
    await remoteDataSource.resendOtp(passportNo);
  }

  @override
  Future<PilgrimModel?> getCurrentPilgrim() async {
    return await localDataSource.getPilgrim();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getAuthToken();
    return token != null;
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await localDataSource.saveAuthToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await localDataSource.getAuthToken();
  }

  @override
  Future<void> clearAuthToken() async {
    await localDataSource.clearAuthToken();
  }
}
