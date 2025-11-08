import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_local_data_source.dart';
import '../datasources/connectivity_remote_data_source.dart';
import '../models/connectivity_plan_model.dart';
import '../models/connectivity_subscription_model.dart';
import '../models/connectivity_topup_model.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityRemoteDataSource remoteDataSource;
  final ConnectivityLocalDataSource localDataSource;

  ConnectivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ConnectivityPlanModel>> getConnectivityPlans() async {
    try {
      // Try fetching from remote
      final plans = await remoteDataSource.getConnectivityPlans();
      // Cache the result
      await localDataSource.cachePlans(plans);
      return plans;
    } catch (e) {
      // If remote fails, fallback to cache
      print('Erreur remote, utilisation du cache: $e');
      return await localDataSource.getCachedPlans();
    }
  }

  @override
  Future<List<ConnectivitySubscriptionModel>> getUserSubscriptions(String userId) async {
    try {
      // Try fetching from remote
      final subscriptions = await remoteDataSource.getUserSubscriptions(userId);
      // Cache the result
      await localDataSource.cacheSubscriptions(subscriptions);
      return subscriptions;
    } catch (e) {
      // If remote fails, fallback to cache
      print('Erreur remote, utilisation du cache: $e');
      return await localDataSource.getCachedSubscriptions();
    }
  }

  @override
  Future<ConnectivitySubscriptionModel> subscribeTonesim(
    String userId,
    String planId,
    String? esimEid,
  ) async {
    final subscription = ConnectivitySubscriptionModel(
      userId: userId,
      planId: planId,
      esimEid: esimEid,
      balanceMb: 0,
      status: ConnectivityStatus.active,
    );

    return await remoteDataSource.createSubscription(subscription);
  }

  @override
  Future<ConnectivityTopupModel> topupSubscription(
    String subscriptionId,
    double amount,
    int dataMb,
  ) async {
    return await remoteDataSource.createTopup(subscriptionId, amount, dataMb);
  }
}















