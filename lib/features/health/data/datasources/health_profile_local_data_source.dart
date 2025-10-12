import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/health_profile_model.dart';

abstract class HealthProfileLocalDataSource {
  Future<HealthProfileModel?> getCachedHealthProfile();
  Future<void> cacheHealthProfile(HealthProfileModel profile);
  Future<void> clearCache();
}

class HealthProfileLocalDataSourceImpl implements HealthProfileLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _healthProfileKey = 'health_profile';

  HealthProfileLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<HealthProfileModel?> getCachedHealthProfile() async {
    try {
      final profileJson = await secureStorage.read(key: _healthProfileKey);
      if (profileJson != null) {
        final Map<String, dynamic> profileMap = json.decode(profileJson);
        return HealthProfileModel.fromJson(profileMap);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la lecture du profil santé en cache: $e');
      return null;
    }
  }

  @override
  Future<void> cacheHealthProfile(HealthProfileModel profile) async {
    try {
      final profileJson = json.encode(profile.toJson());
      await secureStorage.write(key: _healthProfileKey, value: profileJson);
    } catch (e) {
      print('Erreur lors de la mise en cache du profil santé: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: _healthProfileKey);
    } catch (e) {
      print('Erreur lors de la suppression du cache du profil santé: $e');
    }
  }
}

