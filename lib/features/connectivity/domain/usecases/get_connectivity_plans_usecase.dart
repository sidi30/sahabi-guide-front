import '../../data/models/connectivity_plan_model.dart';
import '../repositories/connectivity_repository.dart';

class GetConnectivityPlansUseCase {
  final ConnectivityRepository repository;

  GetConnectivityPlansUseCase(this.repository);

  Future<List<ConnectivityPlanModel>> call() async {
    return await repository.getConnectivityPlans();
  }
}




