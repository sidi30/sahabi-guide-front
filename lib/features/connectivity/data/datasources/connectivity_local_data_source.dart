import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/connectivity_plan_model.dart';
import '../models/connectivity_subscription_model.dart';

abstract class ConnectivityLocalDataSource {
  Future<void> cachePlans(List<ConnectivityPlanModel> plans);
  Future<List<ConnectivityPlanModel>> getCachedPlans();
  Future<void> cacheSubscriptions(List<ConnectivitySubscriptionModel> subscriptions);
  Future<List<ConnectivitySubscriptionModel>> getCachedSubscriptions();
  Future<void> clearCache();
}

class ConnectivityLocalDataSourceImpl implements ConnectivityLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _plansKey = 'connectivity_plans_cache';
  static const String _subscriptionsKey = 'connectivity_subscriptions_cache';

  ConnectivityLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cachePlans(List<ConnectivityPlanModel> plans) async {
    try {
      final jsonList = plans.map((plan) => plan.toJson()).toList();
      await secureStorage.write(key: _plansKey, value: jsonEncode(jsonList));
    } catch (e) {
      AppLogger.error('Erreur lors de la mise en cache des forfaits', error: e);
    }
  }

  @override
  Future<List<ConnectivityPlanModel>> getCachedPlans() async {
    try {
      final jsonString = await secureStorage.read(key: _plansKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ConnectivityPlanModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la lecture du cache des forfaits', error: e);
      return [];
    }
  }

  @override
  Future<void> cacheSubscriptions(List<ConnectivitySubscriptionModel> subscriptions) async {
    try {
      final jsonList = subscriptions.map((sub) => sub.toJson()).toList();
      await secureStorage.write(key: _subscriptionsKey, value: jsonEncode(jsonList));
    } catch (e) {
      AppLogger.error('Erreur lors de la mise en cache des abonnements', error: e);
    }
  }

  @override
  Future<List<ConnectivitySubscriptionModel>> getCachedSubscriptions() async {
    try {
      final jsonString = await secureStorage.read(key: _subscriptionsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ConnectivitySubscriptionModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la lecture du cache des abonnements', error: e);
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: _plansKey);
      await secureStorage.delete(key: _subscriptionsKey);
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du cache', error: e);
    }
  }
}















