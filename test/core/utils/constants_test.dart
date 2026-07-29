import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/utils/constants.dart';

void main() {
  group('AppConstants App Info', () {
    test('appName is Sahabi Guide', () {
      expect(AppConstants.appName, 'Sahabi Guide');
    });

    test('appVersion is 1.0.0', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('appDescription is not empty', () {
      expect(AppConstants.appDescription, isNotEmpty);
    });
  });

  group('AppConstants API', () {
    test('apiTimeout is 30000ms', () {
      expect(AppConstants.apiTimeout, 30000);
    });

    test('apiHealthPath is /health', () {
      expect(AppConstants.apiHealthPath, '/health');
    });

    test('apiBaseUrl is not empty', () {
      expect(AppConstants.apiBaseUrl, isNotEmpty);
    });
  });

  group('AppConstants Route Names', () {
    test('splash route is /', () {
      expect(AppConstants.splashRoute, '/');
    });

    test('home route is /home', () {
      expect(AppConstants.homeRoute, '/home');
    });

    test('login route is /login', () {
      expect(AppConstants.loginRoute, '/login');
    });

    test('rituals route is /rituals', () {
      expect(AppConstants.ritualsRoute, '/rituals');
    });

    test('map route is /map', () {
      expect(AppConstants.mapRoute, '/map');
    });

    test('health route is /health', () {
      expect(AppConstants.healthRoute, '/health');
    });

    test('profile route is /profile', () {
      expect(AppConstants.profileRoute, '/profile');
    });

    test('connectivity route is /connectivity', () {
      expect(AppConstants.connectivityRoute, '/connectivity');
    });

    test('all routes start with /', () {
      final routes = [
        AppConstants.splashRoute,
        AppConstants.onboardingRoute,
        AppConstants.loginRoute,
        AppConstants.registerRoute,
        AppConstants.homeRoute,
        AppConstants.ritualsRoute,
        AppConstants.duasRoute,
        AppConstants.mapRoute,
        AppConstants.healthRoute,
        AppConstants.profileRoute,
        AppConstants.connectivityRoute,
      ];
      for (final route in routes) {
        expect(route.startsWith('/'), isTrue, reason: '$route should start with /');
      }
    });
  });

  group('AppConstants Supported Languages', () {
    test('includes French', () {
      expect(AppConstants.supportedLanguages.containsKey('fr'), isTrue);
      expect(AppConstants.supportedLanguages['fr'], 'Français');
    });

    test('includes English', () {
      expect(AppConstants.supportedLanguages.containsKey('en'), isTrue);
      expect(AppConstants.supportedLanguages['en'], 'English');
    });

    test('includes Hausa', () {
      expect(AppConstants.supportedLanguages.containsKey('ha'), isTrue);
      expect(AppConstants.supportedLanguages['ha'], 'Hausa');
    });

    test('includes Arabic', () {
      expect(AppConstants.supportedLanguages.containsKey('ar'), isTrue);
      expect(AppConstants.supportedLanguages['ar'], 'العربية');
    });

    test('has exactly 4 supported languages', () {
      expect(AppConstants.supportedLanguages.length, 4);
    });
  });

  group('AppConstants Default Values', () {
    test('defaultPadding is 16.0', () {
      expect(AppConstants.defaultPadding, 16.0);
    });

    test('defaultBorderRadius is 12.0', () {
      expect(AppConstants.defaultBorderRadius, 12.0);
    });

    test('cardElevation is 2.0', () {
      expect(AppConstants.cardElevation, 2.0);
    });
  });

  group('AppConstants Animation Durations', () {
    test('shortAnimation is 200ms', () {
      expect(AppConstants.shortAnimation, const Duration(milliseconds: 200));
    });

    test('mediumAnimation is 400ms', () {
      expect(AppConstants.mediumAnimation, const Duration(milliseconds: 400));
    });

    test('longAnimation is 600ms', () {
      expect(AppConstants.longAnimation, const Duration(milliseconds: 600));
    });
  });

  group('AppConstants Storage Keys', () {
    test('authTokenKey is not empty', () {
      expect(AppConstants.authTokenKey, isNotEmpty);
    });

    test('userIdKey is not empty', () {
      expect(AppConstants.userIdKey, isNotEmpty);
    });

    test('languageKey is not empty', () {
      expect(AppConstants.languageKey, isNotEmpty);
    });
  });

  group('AppConstants Prayer Names', () {
    test('has 5 prayer names', () {
      expect(AppConstants.prayerNames.length, 5);
    });

    test('includes all 5 daily prayers', () {
      expect(AppConstants.prayerNames, contains('Fajr'));
      expect(AppConstants.prayerNames, contains('Dhuhr'));
      expect(AppConstants.prayerNames, contains('Asr'));
      expect(AppConstants.prayerNames, contains('Maghrib'));
      expect(AppConstants.prayerNames, contains('Isha'));
    });
  });

  group('AppConstants Map', () {
    test('default latitude is for Niamey', () {
      expect(AppConstants.defaultLatitude, closeTo(13.5, 0.1));
    });

    test('default longitude is for Niamey', () {
      expect(AppConstants.defaultLongitude, closeTo(2.1, 0.1));
    });

    test('default zoom is 12.0', () {
      expect(AppConstants.defaultZoom, 12.0);
    });
  });
}
