import '../../data/models/connectivity_plan_model.dart';
import '../../data/models/connectivity_subscription_model.dart';
import '../../data/models/connectivity_topup_model.dart';

abstract class ConnectivityRepository {
  Future<List<ConnectivityPlanModel>> getConnectivityPlans();
  Future<List<ConnectivitySubscriptionModel>> getUserSubscriptions(String userId);
  Future<ConnectivitySubscriptionModel> subscribeTonesim(String userId, String planId, String? esimEid);
  Future<ConnectivityTopupModel> topupSubscription(String subscriptionId, double amount, int dataMb);
}











