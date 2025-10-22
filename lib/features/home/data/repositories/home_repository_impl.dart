import 'dart:developer' as developer;
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final HomeRemoteDataSource? remoteDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<Map<String, dynamic>>> getHomeMenuItems() async {
    return await localDataSource.getHomeMenuItems();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implement using PassportAuthLocalDataSource or AuthService
    return null;
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      if (remoteDataSource != null) {
        final data = await remoteDataSource!.getDashboardData();
        return data;
      }
    } catch (e, s) {
      developer.log('Failed to fetch dashboard data from remote: $e',
          name: 'HomeRepository', stackTrace: s);
    }
    return await localDataSource.getDashboardData();
  }

  @override
  Future<List<Map<String, dynamic>>> getPrayerTimes() async {
    try {
      if (remoteDataSource != null) {
        return await remoteDataSource!.getPrayerTimes();
      }
    } catch (e, s) {
      developer.log('Failed to fetch prayer times from remote: $e',
          name: 'HomeRepository', stackTrace: s);
    }
    // Fallback to local mock
    return await localDataSource.getPrayerTimes();
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      if (remoteDataSource != null) {
        return await remoteDataSource!.getUserStats();
      }
    } catch (e, s) {
      developer.log('Failed to fetch user stats from remote: $e',
          name: 'HomeRepository', stackTrace: s);
    }
    // Fallback to local mock
    return await localDataSource.getUserStats();
  }
}
