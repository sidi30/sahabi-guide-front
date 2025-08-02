import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/utils/constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
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
  Future<void> saveUser(UserModel user) async {
    await storageService.storeSecurely(AppConstants.userProfileKey, user.toJson());
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await storageService.getSecurely(AppConstants.userProfileKey);
    if (userJson != null) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await storageService.deleteSecurely(AppConstants.userProfileKey);
  }
}
