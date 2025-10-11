import '../../../../shared/models/alert_model.dart';
import '../repositories/geo_repository.dart';

class GetPoisUseCase {
  final GeoRepository repository;

  GetPoisUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({String? agencyId, String? type}) async {
    return await repository.getPois(agencyId: agencyId, type: type);
  }
}

class GetHotelsUseCase {
  final GeoRepository repository;

  GetHotelsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({String? agencyId}) async {
    return await repository.getHotels(agencyId: agencyId);
  }
}

class GetPilgrimHotelUseCase {
  final GeoRepository repository;

  GetPilgrimHotelUseCase(this.repository);

  Future<Map<String, dynamic>?> call(String pilgrimId) async {
    return await repository.getPilgrimHotel(pilgrimId);
  }
}

class GetPilgrimMapUseCase {
  final GeoRepository repository;

  GetPilgrimMapUseCase(this.repository);

  Future<Map<String, dynamic>> call(String pilgrimId, {String? from, String? to, String? type}) async {
    return await repository.getPilgrimMap(pilgrimId, from: from, to: to, type: type);
  }
}

class GetLatestPositionUseCase {
  final GeoRepository repository;

  GetLatestPositionUseCase(this.repository);

  Future<PositionModel> call(String pilgrimId) async {
    return await repository.getLatestPosition(pilgrimId);
  }
}

class GetPositionHistoryUseCase {
  final GeoRepository repository;

  GetPositionHistoryUseCase(this.repository);

  Future<List<PositionModel>> call(String pilgrimId) async {
    return await repository.getPositionHistory(pilgrimId);
  }
}
