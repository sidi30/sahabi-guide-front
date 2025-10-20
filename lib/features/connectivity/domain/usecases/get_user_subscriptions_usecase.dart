import '../../data/models/connectivity_subscription_model.dart';
import '../repositories/connectivity_repository.dart';

class GetUserSubscriptionsUseCase {
  final ConnectivityRepository repository;

  GetUserSubscriptionsUseCase(this.repository);

  Future<List<ConnectivitySubscriptionModel>> call(String userId) async {
    return await repository.getUserSubscriptions(userId);
  }
}






