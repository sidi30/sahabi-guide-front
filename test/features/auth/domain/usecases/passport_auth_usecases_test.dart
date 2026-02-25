import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sahabi_guide/features/auth/data/models/passport_auth_models.dart';
import 'package:sahabi_guide/features/auth/data/repositories/passport_auth_repository_impl.dart';
import 'package:sahabi_guide/features/auth/domain/usecases/passport_auth_usecases.dart';

@GenerateMocks([PassportAuthRepository])
import 'passport_auth_usecases_test.mocks.dart';

void main() {
  late MockPassportAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockPassportAuthRepository();
  });

  final successResponse = PassportAuthResponse(
    success: true,
    message: 'OTP envoyé',
    timestamp: 1234567890,
  );

  final successResponseWithToken = PassportAuthResponse(
    success: true,
    message: 'Authentification réussie',
    token: 'jwt-token-here',
    timestamp: 1234567890,
  );

  final testProfile = PilgrimProfile(
    id: '1',
    passportNo: 'AB123456',
    fullName: 'Test User',
    firstName: 'Test',
    lastName: 'User',
  );

  group('PassportLoginUseCase', () {
    late PassportLoginUseCase useCase;

    setUp(() {
      useCase = PassportLoginUseCase(mockRepository);
    });

    test('calls repository.login with passport number', () async {
      when(mockRepository.login('AB123456'))
          .thenAnswer((_) async => successResponse);

      final result = await useCase('AB123456');

      expect(result.success, true);
      verify(mockRepository.login('AB123456')).called(1);
    });

    test('throws exception for empty passport number', () async {
      expect(() => useCase(''), throwsA(isA<Exception>()));
      verifyNever(mockRepository.login(any));
    });

    test('propagates repository exceptions', () async {
      when(mockRepository.login('AB123456'))
          .thenThrow(Exception('Network error'));

      expect(() => useCase('AB123456'), throwsA(isA<Exception>()));
    });
  });

  group('PassportVerifyOtpUseCase', () {
    late PassportVerifyOtpUseCase useCase;

    setUp(() {
      useCase = PassportVerifyOtpUseCase(mockRepository);
    });

    test('calls repository.verifyOtp with passport and OTP', () async {
      when(mockRepository.verifyOtp('AB123456', '123456'))
          .thenAnswer((_) async => successResponseWithToken);

      final result = await useCase('AB123456', '123456');

      expect(result.success, true);
      expect(result.token, 'jwt-token-here');
      verify(mockRepository.verifyOtp('AB123456', '123456')).called(1);
    });

    test('throws exception for empty passport number', () async {
      expect(() => useCase('', '123456'), throwsA(isA<Exception>()));
      verifyNever(mockRepository.verifyOtp(any, any));
    });

    test('throws exception for empty OTP code', () async {
      expect(() => useCase('AB123456', ''), throwsA(isA<Exception>()));
      verifyNever(mockRepository.verifyOtp(any, any));
    });

    test('throws exception for OTP not 6 digits', () async {
      expect(() => useCase('AB123456', '123'), throwsA(isA<Exception>()));
      expect(() => useCase('AB123456', '1234567'), throwsA(isA<Exception>()));
      verifyNever(mockRepository.verifyOtp(any, any));
    });

    test('accepts exactly 6-digit OTP', () async {
      when(mockRepository.verifyOtp('AB123456', '654321'))
          .thenAnswer((_) async => successResponseWithToken);

      await useCase('AB123456', '654321');
      verify(mockRepository.verifyOtp('AB123456', '654321')).called(1);
    });
  });

  group('PassportResendOtpUseCase', () {
    late PassportResendOtpUseCase useCase;

    setUp(() {
      useCase = PassportResendOtpUseCase(mockRepository);
    });

    test('calls repository.resendOtp with passport number', () async {
      when(mockRepository.resendOtp('AB123456'))
          .thenAnswer((_) async => successResponse);

      final result = await useCase('AB123456');

      expect(result.success, true);
      verify(mockRepository.resendOtp('AB123456')).called(1);
    });

    test('throws exception for empty passport number', () async {
      expect(() => useCase(''), throwsA(isA<Exception>()));
      verifyNever(mockRepository.resendOtp(any));
    });
  });

  group('PassportLogoutUseCase', () {
    late PassportLogoutUseCase useCase;

    setUp(() {
      useCase = PassportLogoutUseCase(mockRepository);
    });

    test('calls repository.logout', () async {
      when(mockRepository.logout())
          .thenAnswer((_) async => successResponse);

      final result = await useCase();

      expect(result.success, true);
      verify(mockRepository.logout()).called(1);
    });

    test('propagates repository exceptions', () async {
      when(mockRepository.logout())
          .thenThrow(Exception('Logout error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });

  group('GetPilgrimProfileUseCase', () {
    late GetPilgrimProfileUseCase useCase;

    setUp(() {
      useCase = GetPilgrimProfileUseCase(mockRepository);
    });

    test('returns profile from repository', () async {
      when(mockRepository.getPilgrimProfile())
          .thenAnswer((_) async => testProfile);

      final result = await useCase();

      expect(result, isNotNull);
      expect(result!.fullName, 'Test User');
      verify(mockRepository.getPilgrimProfile()).called(1);
    });

    test('returns null when no profile', () async {
      when(mockRepository.getPilgrimProfile())
          .thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isNull);
    });
  });

  group('CheckAuthStatusUseCase', () {
    late CheckAuthStatusUseCase useCase;

    setUp(() {
      useCase = CheckAuthStatusUseCase(mockRepository);
    });

    test('returns true when logged in', () async {
      when(mockRepository.isLoggedIn())
          .thenAnswer((_) async => true);

      final result = await useCase();

      expect(result, true);
      verify(mockRepository.isLoggedIn()).called(1);
    });

    test('returns false when not logged in', () async {
      when(mockRepository.isLoggedIn())
          .thenAnswer((_) async => false);

      final result = await useCase();

      expect(result, false);
    });
  });
}
