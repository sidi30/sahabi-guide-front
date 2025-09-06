import '../repository/makkah_locations_repository.dart';
import '../../data/models/makkah_location_model.dart';

class GetMakkahLocationsUseCase {
  final MakkahLocationsRepository repository;

  const GetMakkahLocationsUseCase({required this.repository});

  List<MakkahLocationModel> call() {
    return repository.getMakkahLocations();
  }

  List<MakkahLocationModel> getByType(String type) {
    return repository.getLocationsByType(type);
  }

  List<MakkahLocationModel> getImportantLocations() {
    return repository.getImportantLocations();
  }

  MakkahLocationModel? getById(String id) {
    return repository.getLocationById(id);
  }
}