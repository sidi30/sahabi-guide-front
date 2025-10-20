import '../../data/models/connectivity_subscription_model.dart';
import '../repositories/connectivity_repository.dart';

class SubscribeToPlanUseCase {
  final ConnectivityRepository repository;

  SubscribeToPlanUseCase(this.repository);

  Future<ConnectivitySubscriptionModel> call({
    required String userId,
    required String planId,
    String? esimEid,
  }) async {
    return await repository.subscribeTonesim(userId, planId, esimEid);
  }
}






