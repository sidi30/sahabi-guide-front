import '../datasources/makkah_locations_data_source.dart';
import '../models/makkah_location_model.dart';
import '../../domain/repository/makkah_locations_repository.dart';

class MakkahLocationsRepositoryImpl implements MakkahLocationsRepository {
  final MakkahLocationsDataSource dataSource;

  const MakkahLocationsRepositoryImpl({required this.dataSource});

  @override
  List<MakkahLocationModel> getMakkahLocations() {
    return dataSource.getMakkahLocations();
  }

  @override
  List<MakkahLocationModel> getLocationsByType(String type) {
    return dataSource.getLocationsByType(type);
  }

  @override
  MakkahLocationModel? getLocationById(String id) {
    return dataSource.getLocationById(id);
  }

  @override
  List<MakkahLocationModel> getImportantLocations() {
    return dataSource.getMakkahLocations()
        .where((location) => location.isImportant)
        .toList();
  }
}