import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String email, String password, String firstName, String lastName);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Email ou mot de passe incorrect');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password, String firstName, String lastName) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Erreur lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }
}
