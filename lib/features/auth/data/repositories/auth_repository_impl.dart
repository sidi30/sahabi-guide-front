import '../../../../shared/models/user_model.dart';
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
  Future<UserModel> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      
      // Generate mock token
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save token and user locally
      await localDataSource.saveAuthToken(token);
      await localDataSource.saveUser(user);
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register(String email, String password, String firstName, String lastName) async {
    try {
      final user = await remoteDataSource.register(email, password, firstName, lastName);
      
      // Generate mock token
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save token and user locally
      await localDataSource.saveAuthToken(token);
      await localDataSource.saveUser(user);
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuthToken();
    await localDataSource.clearUser();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await localDataSource.getUser();
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
