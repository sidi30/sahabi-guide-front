import '../../data/models/makkah_location_model.dart';

abstract class MakkahLocationsRepository {
  List<MakkahLocationModel> getMakkahLocations();
  List<MakkahLocationModel> getLocationsByType(String type);
  MakkahLocationModel? getLocationById(String id);
  List<MakkahLocationModel> getImportantLocations();
}