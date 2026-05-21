import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/router/auth_guard.dart';

void main() {
  group('AuthGuard.isProtectedRoute', () {
    test('returns true for /profile', () {
      expect(AuthGuard.isProtectedRoute('/profile'), isTrue);
    });

    test('returns true for /pilgrim-profile', () {
      expect(AuthGuard.isProtectedRoute('/pilgrim-profile'), isTrue);
    });

    test('returns false for /home', () {
      expect(AuthGuard.isProtectedRoute('/home'), isFalse);
    });

    test('returns false for /rituals', () {
      expect(AuthGuard.isProtectedRoute('/rituals'), isFalse);
    });

    test('returns false for /map', () {
      expect(AuthGuard.isProtectedRoute('/map'), isFalse);
    });

    test('returns false for /health', () {
      expect(AuthGuard.isProtectedRoute('/health'), isFalse);
    });

    test('returns false for /connectivity', () {
      expect(AuthGuard.isProtectedRoute('/connectivity'), isFalse);
    });

    test('returns false for /settings', () {
      expect(AuthGuard.isProtectedRoute('/settings'), isFalse);
    });

    test('returns false for /alerts (now public in visitor mode)', () {
      expect(AuthGuard.isProtectedRoute('/alerts'), isFalse);
    });

    test('returns false for /emergency-contacts (now public in visitor mode)', () {
      expect(AuthGuard.isProtectedRoute('/emergency-contacts'), isFalse);
    });

    test('returns false for /bot-debug (now public in visitor mode)', () {
      expect(AuthGuard.isProtectedRoute('/bot-debug'), isFalse);
    });

    test('returns false for /passport-login', () {
      expect(AuthGuard.isProtectedRoute('/passport-login'), isFalse);
    });

    test('returns false for / (splash)', () {
      expect(AuthGuard.isProtectedRoute('/'), isFalse);
    });

    test('returns false for /auth-choice', () {
      expect(AuthGuard.isProtectedRoute('/auth-choice'), isFalse);
    });

    test('matches routes starting with protected prefix', () {
      expect(AuthGuard.isProtectedRoute('/profile/edit'), isTrue);
      expect(AuthGuard.isProtectedRoute('/pilgrim-profile/123'), isTrue);
    });

    test('returns false for /bot (not protected in visitor mode)', () {
      expect(AuthGuard.isProtectedRoute('/bot'), isFalse);
    });
  });

  group('AuthGuard.protectedRoutes', () {
    test('contains expected protected routes', () {
      expect(AuthGuard.protectedRoutes, contains('/profile'));
      expect(AuthGuard.protectedRoutes, contains('/pilgrim-profile'));
    });

    test('has exactly 2 protected routes (visitor mode pre-Hajj)', () {
      expect(AuthGuard.protectedRoutes.length, 2);
    });
  });
}
