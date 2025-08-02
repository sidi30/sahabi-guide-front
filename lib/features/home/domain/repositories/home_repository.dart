import '../../../../shared/models/user_model.dart';

abstract class HomeRepository {
  Future<List<Map<String, dynamic>>> getHomeMenuItems();
  Future<UserModel?> getCurrentUser();
  Future<Map<String, dynamic>> getDashboardData();
}
