import '../../data/models/passport_auth_models.dart';
import '../../data/repositories/passport_auth_repository_impl.dart';

class PassportLoginUseCase {
  final PassportAuthRepository repository;

  PassportLoginUseCase(this.repository);

  Future<PassportAuthResponse> call(String passportNo) async {
    if (passportNo.isEmpty) {
      throw Exception('Le numéro de passeport est requis');
    }
    return await repository.login(passportNo);
  }
}

class PassportVerifyOtpUseCase {
  final PassportAuthRepository repository;

  PassportVerifyOtpUseCase(this.repository);

  Future<PassportAuthResponse> call(String passportNo, String otpCode) async {
    if (passportNo.isEmpty) {
      throw Exception('Le numéro de passeport est requis');
    }
    if (otpCode.isEmpty) {
      throw Exception('Le code OTP est requis');
    }
    if (otpCode.length != 6) {
      throw Exception('Le code OTP doit contenir 6 chiffres');
    }
    return await repository.verifyOtp(passportNo, otpCode);
  }
}

class PassportResendOtpUseCase {
  final PassportAuthRepository repository;

  PassportResendOtpUseCase(this.repository);

  Future<PassportAuthResponse> call(String passportNo) async {
    if (passportNo.isEmpty) {
      throw Exception('Le numéro de passeport est requis');
    }
    return await repository.resendOtp(passportNo);
  }
}

class PassportLogoutUseCase {
  final PassportAuthRepository repository;

  PassportLogoutUseCase(this.repository);

  Future<PassportAuthResponse> call() async {
    return await repository.logout();
  }
}

class GetPilgrimProfileUseCase {
  final PassportAuthRepository repository;

  GetPilgrimProfileUseCase(this.repository);

  Future<PilgrimProfile?> call({bool forceRefresh = false}) async {
    return await repository.getPilgrimProfile(forceRefresh: forceRefresh);
  }
}

class CheckAuthStatusUseCase {
  final PassportAuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}
