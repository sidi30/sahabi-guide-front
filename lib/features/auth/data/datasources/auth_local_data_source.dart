import '../../../../shared/models/pilgrim_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/utils/constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
  Future<void> savePilgrim(PilgrimModel pilgrim);
  Future<PilgrimModel?> getPilgrim();
  Future<void> clearPilgrim();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl(this.storageService);

  @override
  Future<void> saveAuthToken(String token) async {
    await storageService.storeSecurely(AppConstants.authTokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await storageService.getSecurely(AppConstants.authTokenKey);
  }

  @override
  Future<void> clearAuthToken() async {
    await storageService.deleteSecurely(AppConstants.authTokenKey);
  }

  @override
  Future<void> savePilgrim(PilgrimModel pilgrim) async {
    await storageService.storeSecurely(AppConstants.userProfileKey, pilgrim.toJson());
  }

  @override
  Future<PilgrimModel?> getPilgrim() async {
    final pilgrimJson = await storageService.getSecurely(AppConstants.userProfileKey);
    if (pilgrimJson != null) {
      return PilgrimModel.fromJson(pilgrimJson);
    }
    return null;
  }

  @override
  Future<void> clearPilgrim() async {
    await storageService.deleteSecurely(AppConstants.userProfileKey);
  }
}
