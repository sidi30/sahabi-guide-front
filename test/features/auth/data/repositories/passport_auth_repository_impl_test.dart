import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sahabi_guide/features/auth/data/datasources/passport_auth_local_data_source.dart';
import 'package:sahabi_guide/features/auth/data/datasources/passport_auth_remote_data_source.dart';
import 'package:sahabi_guide/features/auth/data/models/passport_auth_models.dart';
import 'package:sahabi_guide/features/auth/data/repositories/passport_auth_repository_impl.dart';

@GenerateMocks([PassportAuthRemoteDataSource, PassportAuthLocalDataSource])
import 'passport_auth_repository_impl_test.mocks.dart';

void main() {
  late PassportAuthRepositoryImpl repository;
  late MockPassportAuthRemoteDataSource mockRemoteDataSource;
  late MockPassportAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockPassportAuthRemoteDataSource();
    mockLocalDataSource = MockPassportAuthLocalDataSource();
    repository = PassportAuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
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

  final failureResponse = PassportAuthResponse(
    success: false,
    message: 'Erreur',
    timestamp: 1234567890,
  );

  final testProfile = PilgrimProfile(
    id: '1',
    passportNo: 'AB123456',
    fullName: 'Test User',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
  );

  group('login', () {
    test('calls remote login and saves passport on success', () async {
      when(mockRemoteDataSource.login('AB123456'))
          .thenAnswer((_) async => successResponse);
      when(mockLocalDataSource.savePassportNo('AB123456'))
          .thenAnswer((_) async {});

      final result = await repository.login('AB123456');

      expect(result.success, true);
      verify(mockRemoteDataSource.login('AB123456')).called(1);
      verify(mockLocalDataSource.savePassportNo('AB123456')).called(1);
    });

    test('does not save passport on failure', () async {
      when(mockRemoteDataSource.login('AB123456'))
          .thenAnswer((_) async => failureResponse);

      final result = await repository.login('AB123456');

      expect(result.success, false);
      verifyNever(mockLocalDataSource.savePassportNo(any));
    });

    test('throws exception on remote error', () async {
      when(mockRemoteDataSource.login('AB123456'))
          .thenThrow(Exception('Network error'));

      expect(() => repository.login('AB123456'), throwsA(isA<Exception>()));
    });
  });

  group('verifyOtp', () {
    test('saves token on successful verification', () async {
      when(mockRemoteDataSource.verifyOtp('AB123456', '123456'))
          .thenAnswer((_) async => successResponseWithToken);
      when(mockLocalDataSource.saveToken('jwt-token-here'))
          .thenAnswer((_) async {});

      final result = await repository.verifyOtp('AB123456', '123456');

      expect(result.success, true);
      expect(result.token, 'jwt-token-here');
      verify(mockLocalDataSource.saveToken('jwt-token-here')).called(1);
    });

    test('does not save token when response has no token', () async {
      when(mockRemoteDataSource.verifyOtp('AB123456', '123456'))
          .thenAnswer((_) async => failureResponse);

      final result = await repository.verifyOtp('AB123456', '123456');

      expect(result.success, false);
      verifyNever(mockLocalDataSource.saveToken(any));
    });

    test('throws exception on remote error', () async {
      when(mockRemoteDataSource.verifyOtp('AB123456', '123456'))
          .thenThrow(Exception('OTP error'));

      expect(
        () => repository.verifyOtp('AB123456', '123456'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('validateToken', () {
    test('delegates to remote data source', () async {
      when(mockRemoteDataSource.validateToken('token'))
          .thenAnswer((_) async => successResponse);

      final result = await repository.validateToken('token');

      expect(result.success, true);
      verify(mockRemoteDataSource.validateToken('token')).called(1);
    });

    test('throws exception on remote error', () async {
      when(mockRemoteDataSource.validateToken('token'))
          .thenThrow(Exception('Validation error'));

      expect(
        () => repository.validateToken('token'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('resendOtp', () {
    test('delegates to remote data source', () async {
      when(mockRemoteDataSource.resendOtp('AB123456'))
          .thenAnswer((_) async => successResponse);

      final result = await repository.resendOtp('AB123456');

      expect(result.success, true);
      verify(mockRemoteDataSource.resendOtp('AB123456')).called(1);
    });
  });

  group('logout', () {
    test('calls remote logout and clears session when token exists', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => 'valid-token');
      when(mockRemoteDataSource.logout('valid-token'))
          .thenAnswer((_) async => successResponse);
      when(mockLocalDataSource.deleteToken())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePilgrimProfile())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePassportNo())
          .thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.success, true);
      verify(mockRemoteDataSource.logout('valid-token')).called(1);
      verify(mockLocalDataSource.deleteToken()).called(1);
      verify(mockLocalDataSource.deletePilgrimProfile()).called(1);
      verify(mockLocalDataSource.deletePassportNo()).called(1);
    });

    test('clears session even when no token', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => null);
      when(mockLocalDataSource.deleteToken())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePilgrimProfile())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePassportNo())
          .thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.success, true);
      expect(result.message, 'Déconnexion réussie');
      verifyNever(mockRemoteDataSource.logout(any));
    });

    test('clears session even on remote error', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => 'valid-token');
      when(mockRemoteDataSource.logout('valid-token'))
          .thenThrow(Exception('Server error'));
      when(mockLocalDataSource.deleteToken())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePilgrimProfile())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePassportNo())
          .thenAnswer((_) async {});

      expect(() => repository.logout(), throwsA(isA<Exception>()));
    });
  });

  group('getPilgrimProfile', () {
    test('returns local profile when available', () async {
      when(mockLocalDataSource.getPilgrimProfile())
          .thenAnswer((_) async => testProfile);

      final result = await repository.getPilgrimProfile();

      expect(result, isNotNull);
      expect(result!.fullName, 'Test User');
      verifyNever(mockRemoteDataSource.getPilgrimProfile(any));
    });

    test('fetches from remote when no local profile', () async {
      when(mockLocalDataSource.getPilgrimProfile())
          .thenAnswer((_) async => null);
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => 'valid-token');
      when(mockRemoteDataSource.getPilgrimProfile('valid-token'))
          .thenAnswer((_) async => testProfile);
      when(mockLocalDataSource.savePilgrimProfile(testProfile))
          .thenAnswer((_) async {});

      final result = await repository.getPilgrimProfile();

      expect(result, isNotNull);
      expect(result!.fullName, 'Test User');
      verify(mockRemoteDataSource.getPilgrimProfile('valid-token')).called(1);
      verify(mockLocalDataSource.savePilgrimProfile(testProfile)).called(1);
    });

    test('returns null when no local profile and no token', () async {
      when(mockLocalDataSource.getPilgrimProfile())
          .thenAnswer((_) async => null);
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => null);

      final result = await repository.getPilgrimProfile();

      expect(result, isNull);
    });
  });

  group('isLoggedIn', () {
    test('returns true when token is valid', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => 'valid-token');
      when(mockRemoteDataSource.validateToken('valid-token'))
          .thenAnswer((_) async => successResponse);

      final result = await repository.isLoggedIn();

      expect(result, true);
    });

    test('returns false when no token', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => null);

      final result = await repository.isLoggedIn();

      expect(result, false);
    });

    test('returns false and clears session when token validation fails', () async {
      when(mockLocalDataSource.getToken())
          .thenAnswer((_) async => 'invalid-token');
      when(mockRemoteDataSource.validateToken('invalid-token'))
          .thenThrow(Exception('Invalid'));
      when(mockLocalDataSource.deleteToken())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePilgrimProfile())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePassportNo())
          .thenAnswer((_) async {});

      final result = await repository.isLoggedIn();

      expect(result, false);
      verify(mockLocalDataSource.deleteToken()).called(1);
    });
  });

  group('clearSession', () {
    test('deletes all local data', () async {
      when(mockLocalDataSource.deleteToken())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePilgrimProfile())
          .thenAnswer((_) async {});
      when(mockLocalDataSource.deletePassportNo())
          .thenAnswer((_) async {});

      await repository.clearSession();

      verify(mockLocalDataSource.deleteToken()).called(1);
      verify(mockLocalDataSource.deletePilgrimProfile()).called(1);
      verify(mockLocalDataSource.deletePassportNo()).called(1);
    });
  });
}
