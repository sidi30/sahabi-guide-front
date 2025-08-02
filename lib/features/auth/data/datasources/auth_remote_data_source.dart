import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String firstName, String lastName);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful login
      if (email == 'test@example.com' && password == 'password') {
        return UserModel(
          id: '1',
          email: email,
          firstName: 'Test',
          lastName: 'User',
          isVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Email ou mot de passe incorrect');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String firstName, String lastName) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful registration
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }
}
