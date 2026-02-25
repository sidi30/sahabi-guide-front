import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/error/api_exceptions.dart';

void main() {
  group('ApiException hierarchy', () {
    test('TimeoutException has correct default message and statusCode', () {
      final exception = TimeoutException();
      expect(exception.message, 'Timeout de connexion');
      expect(exception.statusCode, 408);
      expect(exception.toString(), 'Timeout de connexion');
    });

    test('TimeoutException accepts custom message', () {
      final exception = TimeoutException('Custom timeout');
      expect(exception.message, 'Custom timeout');
      expect(exception.statusCode, 408);
    });

    test('UnauthorizedException has correct default values', () {
      final exception = UnauthorizedException();
      expect(exception.message, 'Non autorisé');
      expect(exception.statusCode, 401);
    });

    test('UnauthorizedException accepts custom message', () {
      final exception = UnauthorizedException('Token expired');
      expect(exception.message, 'Token expired');
      expect(exception.statusCode, 401);
    });

    test('ForbiddenException has correct default values', () {
      final exception = ForbiddenException();
      expect(exception.message, 'Accès interdit');
      expect(exception.statusCode, 403);
    });

    test('NotFoundException has correct default values', () {
      final exception = NotFoundException();
      expect(exception.message, 'Ressource non trouvée');
      expect(exception.statusCode, 404);
    });

    test('NotFoundException accepts custom message', () {
      final exception = NotFoundException('User not found');
      expect(exception.message, 'User not found');
      expect(exception.statusCode, 404);
    });

    test('ValidationException has correct default values', () {
      final exception = ValidationException('Champ invalide');
      expect(exception.message, 'Champ invalide');
      expect(exception.statusCode, 422);
      expect(exception.errors, isNull);
    });

    test('ValidationException accepts errors map', () {
      final errors = {'email': 'invalid format'};
      final exception = ValidationException('Validation failed', errors: errors);
      expect(exception.errors, errors);
      expect(exception.statusCode, 422);
    });

    test('ServerException has correct default values', () {
      final exception = ServerException();
      expect(exception.message, 'Erreur serveur');
      expect(exception.statusCode, 500);
    });

    test('NetworkException has correct default values', () {
      final exception = NetworkException();
      expect(exception.message, 'Erreur de connexion réseau');
      expect(exception.statusCode, isNull);
    });

    test('CancelException has correct default values', () {
      final exception = CancelException();
      expect(exception.message, 'Requête annulée');
      expect(exception.statusCode, isNull);
    });

    test('CertificateException has correct default values', () {
      final exception = CertificateException();
      expect(exception.message, 'Certificat SSL invalide');
      expect(exception.statusCode, isNull);
    });

    test('UnknownException has correct default values', () {
      final exception = UnknownException();
      expect(exception.message, 'Erreur inconnue');
      expect(exception.originalError, isNull);
    });

    test('UnknownException accepts original error', () {
      final original = Exception('original');
      final exception = UnknownException('Something went wrong', original);
      expect(exception.message, 'Something went wrong');
      expect(exception.originalError, original);
    });

    test('All exceptions implement Exception', () {
      expect(TimeoutException(), isA<Exception>());
      expect(UnauthorizedException(), isA<Exception>());
      expect(ForbiddenException(), isA<Exception>());
      expect(NotFoundException(), isA<Exception>());
      expect(ValidationException('test'), isA<Exception>());
      expect(ServerException(), isA<Exception>());
      expect(NetworkException(), isA<Exception>());
      expect(CancelException(), isA<Exception>());
      expect(CertificateException(), isA<Exception>());
      expect(UnknownException(), isA<Exception>());
    });

    test('All exceptions extend ApiException', () {
      expect(TimeoutException(), isA<ApiException>());
      expect(UnauthorizedException(), isA<ApiException>());
      expect(ForbiddenException(), isA<ApiException>());
      expect(NotFoundException(), isA<ApiException>());
      expect(ValidationException('test'), isA<ApiException>());
      expect(ServerException(), isA<ApiException>());
      expect(NetworkException(), isA<ApiException>());
      expect(CancelException(), isA<ApiException>());
      expect(CertificateException(), isA<ApiException>());
      expect(UnknownException(), isA<ApiException>());
    });

    test('toString returns the message', () {
      final exception = ServerException('Custom server error');
      expect(exception.toString(), 'Custom server error');
    });
  });
}
