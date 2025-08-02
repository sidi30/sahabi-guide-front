import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._sharedPreferences, this._secureStorage);

  // Secure Storage Methods (for sensitive data like tokens)
  Future<void> storeSecurely(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecurely(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecurely(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Regular Storage Methods (for non-sensitive data)
  Future<void> store(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  Future<void> storeBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  Future<void> storeInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }

  Future<void> storeDouble(String key, double value) async {
    await _sharedPreferences.setDouble(key, value);
  }

  Future<void> storeStringList(String key, List<String> value) async {
    await _sharedPreferences.setStringList(key, value);
  }

  String? get(String key) {
    return _sharedPreferences.getString(key);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  double? getDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }

  List<String>? getStringList(String key) {
    return _sharedPreferences.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }
}
