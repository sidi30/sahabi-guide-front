import '../../../../shared/models/user_model.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserModel> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      throw Exception('Tous les champs sont requis');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Format d\'email invalide');
    }

    if (password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    if (password != confirmPassword) {
      throw Exception('Les mots de passe ne correspondent pas');
    }

    if (firstName.length < 2) {
      throw Exception('Le prénom doit contenir au moins 2 caractères');
    }

    if (lastName.length < 2) {
      throw Exception('Le nom doit contenir au moins 2 caractères');
    }

    return await repository.register(email, password, firstName, lastName);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
