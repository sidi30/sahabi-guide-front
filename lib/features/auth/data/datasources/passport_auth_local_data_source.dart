import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/utils/constants.dart';
import '../models/passport_auth_models.dart';

abstract class PassportAuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> savePilgrimProfile(PilgrimProfile profile);
  Future<PilgrimProfile?> getPilgrimProfile();
  Future<void> deletePilgrimProfile();
  Future<void> savePassportNo(String passportNo);
  Future<String?> getPassportNo();
  Future<void> deletePassportNo();
}

class PassportAuthLocalDataSourceImpl implements PassportAuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  PassportAuthLocalDataSourceImpl(this.secureStorage);

  static const String _tokenKey = AppConstants.authTokenKey;
  static const String _profileKey = 'pilgrim_profile';
  static const String _passportKey = 'passport_no';

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<void> savePilgrimProfile(PilgrimProfile profile) async {
    final profileJson = jsonEncode(profile.toJson());
    await secureStorage.write(key: _profileKey, value: profileJson);
  }

  @override
  Future<PilgrimProfile?> getPilgrimProfile() async {
    final profileString = await secureStorage.read(key: _profileKey);
    if (profileString != null) {
      try {
        final profileJson = jsonDecode(profileString) as Map<String, dynamic>;
        return PilgrimProfile.fromJson(profileJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> deletePilgrimProfile() async {
    await secureStorage.delete(key: _profileKey);
  }

  @override
  Future<void> savePassportNo(String passportNo) async {
    await secureStorage.write(key: _passportKey, value: passportNo);
  }

  @override
  Future<String?> getPassportNo() async {
    return await secureStorage.read(key: _passportKey);
  }

  @override
  Future<void> deletePassportNo() async {
    await secureStorage.delete(key: _passportKey);
  }
}
