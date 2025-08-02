import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Map<String, dynamic>>> getHomeMenuItems() async {
    return await localDataSource.getHomeMenuItems();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final authRepository = sl<AuthRepository>();
    return await authRepository.getCurrentUser();
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    return await localDataSource.getDashboardData();
  }
}
