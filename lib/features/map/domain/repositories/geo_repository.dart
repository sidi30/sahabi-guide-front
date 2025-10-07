import '../../../../shared/models/alert_model.dart';

abstract class GeoRepository {
  Future<List<Map<String, dynamic>>> getPois({String? agencyId, String? type});
  Future<List<Map<String, dynamic>>> getHotels({String? agencyId});
  Future<Map<String, dynamic>?> getPilgrimHotel(String pilgrimId);
  Future<Map<String, dynamic>> getPilgrimMap(String pilgrimId, {String? from, String? to, String? type});
  Future<PositionModel> getLatestPosition(String pilgrimId);
  Future<List<PositionModel>> getPositionHistory(String pilgrimId);
}
