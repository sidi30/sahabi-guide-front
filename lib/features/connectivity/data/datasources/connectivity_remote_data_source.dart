import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/constants.dart';
import '../models/connectivity_plan_model.dart';
import '../models/connectivity_subscription_model.dart';
import '../models/connectivity_topup_model.dart';

abstract class ConnectivityRemoteDataSource {
  Future<List<ConnectivityPlanModel>> getConnectivityPlans();
  Future<List<ConnectivitySubscriptionModel>> getUserSubscriptions(String userId);
  Future<ConnectivitySubscriptionModel> createSubscription(ConnectivitySubscriptionModel subscription);
  Future<ConnectivityTopupModel> createTopup(String subscriptionId, double amount, int dataMb);
}

class ConnectivityRemoteDataSourceImpl implements ConnectivityRemoteDataSource {
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  ConnectivityRemoteDataSourceImpl({
    required this.dioClient,
    required this.secureStorage,
  });

  static const String _tokenKey = AppConstants.authTokenKey;

  Future<Options?> _getAuthOptions() async {
    try {
      final token = await secureStorage.read(key: _tokenKey);
      if (token != null) {
        return Options(headers: {'Authorization': 'Bearer $token'});
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération du token', error: e);
    }
    return null;
  }

  @override
  Future<List<ConnectivityPlanModel>> getConnectivityPlans() async {
    try {
      final options = await _getAuthOptions();
      final response = await dioClient.get(
        '/api/v1/connectivity/plans',
        options: options,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ConnectivityPlanModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des forfaits: $e');
    }
  }

  @override
  Future<List<ConnectivitySubscriptionModel>> getUserSubscriptions(String userId) async {
    try {
      final options = await _getAuthOptions();
      final response = await dioClient.get(
        '/api/v1/connectivity/subscriptions',
        queryParameters: {'userId': userId},
        options: options,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ConnectivitySubscriptionModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des abonnements: $e');
    }
  }

  @override
  Future<ConnectivitySubscriptionModel> createSubscription(ConnectivitySubscriptionModel subscription) async {
    try {
      final options = await _getAuthOptions();
      final response = await dioClient.post(
        '/api/v1/connectivity/subscriptions',
        data: subscription.toJson(),
        options: options,
      );

      return ConnectivitySubscriptionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'abonnement: $e');
    }
  }

  @override
  Future<ConnectivityTopupModel> createTopup(String subscriptionId, double amount, int dataMb) async {
    try {
      final options = await _getAuthOptions();
      final response = await dioClient.post(
        '/api/v1/connectivity/subscriptions/$subscriptionId/topups',
        data: {
          'amountPaid': amount,
          'dataMb': dataMb,
        },
        options: options,
      );

      return ConnectivityTopupModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors du rechargement: $e');
    }
  }
}

