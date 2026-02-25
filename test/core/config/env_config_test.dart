import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/config/env_config.dart';

void main() {
  group('Environment enum', () {
    test('has all expected values', () {
      expect(Environment.values.length, 3);
      expect(Environment.values, contains(Environment.development));
      expect(Environment.values, contains(Environment.staging));
      expect(Environment.values, contains(Environment.production));
    });
  });

  group('EnvConfig URLs per environment', () {
    test('development URL points to localhost emulator', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.apiBaseUrl, contains('10.0.2.2'));
      expect(EnvConfig.apiBaseUrl, contains('8084'));
    });

    test('staging URL points to Hetzner', () {
      EnvConfig.init(Environment.staging);
      expect(EnvConfig.apiBaseUrl, 'https://46.224.193.109');
    });

    test('production URL points to Hetzner', () {
      EnvConfig.init(Environment.production);
      expect(EnvConfig.apiBaseUrl, 'https://46.224.193.109');
    });
  });

  group('EnvConfig.init', () {
    test('sets environment to development', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.environment, Environment.development);
    });

    test('sets environment to staging', () {
      EnvConfig.init(Environment.staging);
      expect(EnvConfig.environment, Environment.staging);
    });

    test('sets environment to production', () {
      EnvConfig.init(Environment.production);
      expect(EnvConfig.environment, Environment.production);
    });
  });

  group('EnvConfig boolean flags', () {
    test('isDevelopment is true only for development', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isStaging, isFalse);
      expect(EnvConfig.isProduction, isFalse);
    });

    test('isStaging is true only for staging', () {
      EnvConfig.init(Environment.staging);
      expect(EnvConfig.isDevelopment, isFalse);
      expect(EnvConfig.isStaging, isTrue);
      expect(EnvConfig.isProduction, isFalse);
    });

    test('isProduction is true only for production', () {
      EnvConfig.init(Environment.production);
      expect(EnvConfig.isDevelopment, isFalse);
      expect(EnvConfig.isStaging, isFalse);
      expect(EnvConfig.isProduction, isTrue);
    });

    test('enableDetailedLogs is true for dev and staging', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.enableDetailedLogs, isTrue);

      EnvConfig.init(Environment.staging);
      expect(EnvConfig.enableDetailedLogs, isTrue);
    });

    test('enableDetailedLogs is false for production', () {
      EnvConfig.init(Environment.production);
      expect(EnvConfig.enableDetailedLogs, isFalse);
    });

    test('enableDioDebugMode is true only for development', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.enableDioDebugMode, isTrue);

      EnvConfig.init(Environment.staging);
      expect(EnvConfig.enableDioDebugMode, isFalse);

      EnvConfig.init(Environment.production);
      expect(EnvConfig.enableDioDebugMode, isFalse);
    });
  });

  group('EnvConfig constants', () {
    test('apiBasePath is /api/v1', () {
      expect(EnvConfig.apiBasePath, '/api/v1');
    });

    test('apiVersion is v1', () {
      expect(EnvConfig.apiVersion, 'v1');
    });

    test('httpTimeout is 30 seconds', () {
      expect(EnvConfig.httpTimeout, 30000);
    });

    test('connectionTimeout is 10 seconds', () {
      expect(EnvConfig.connectionTimeout, 10000);
    });

    test('cacheMaxAge is 24 hours', () {
      expect(EnvConfig.cacheMaxAge, const Duration(hours: 24));
    });

    test('cacheStaleAge is 48 hours', () {
      expect(EnvConfig.cacheStaleAge, const Duration(hours: 48));
    });
  });

  group('EnvConfig.apiFullUrl', () {
    test('combines base URL with api path for development', () {
      EnvConfig.init(Environment.development);
      expect(EnvConfig.apiFullUrl, 'http://10.0.2.2:8084/api/v1');
    });

    test('combines base URL with api path for production', () {
      EnvConfig.init(Environment.production);
      expect(EnvConfig.apiFullUrl, 'https://46.224.193.109/api/v1');
    });
  });
}
