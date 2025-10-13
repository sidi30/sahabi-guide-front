import '../../data/models/connectivity_topup_model.dart';
import '../repositories/connectivity_repository.dart';

class TopupSubscriptionUseCase {
  final ConnectivityRepository repository;

  TopupSubscriptionUseCase(this.repository);

  Future<ConnectivityTopupModel> call({
    required String subscriptionId,
    required double amount,
    required int dataMb,
  }) async {
    return await repository.topupSubscription(subscriptionId, amount, dataMb);
  }
}


