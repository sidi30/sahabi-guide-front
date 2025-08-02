import '../../../../shared/models/user_model.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email et mot de passe requis');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Format d\'email invalide');
    }

    if (password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    return await repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
