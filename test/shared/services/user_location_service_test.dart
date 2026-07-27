import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sahabi_guide/shared/services/location_service.dart';
import 'package:sahabi_guide/shared/services/user_location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LocationService pilotable : le vrai appelle les plugins natifs, absents en
/// test. `noSuchMethod` couvre les membres non utilisés ici.
class _FakeLocationService implements LocationService {
  _FakeLocationService({
    this.permission = LocationPermission.whileInUse,
    this.serviceEnabled = true,
    this.lastKnown,
  });

  LocationPermission permission;
  bool serviceEnabled;
  Position? lastKnown;

  @override
  Future<LocationPermission> checkLocationPermission() async => permission;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<Position?> getLastKnownPosition() async => lastKnown;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Position _position({
  required double lat,
  required double lng,
  required DateTime timestamp,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: timestamp,
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('UserLocationService — fraîcheur du fix', () {
    test('un dernier fix récent est utilisé', () async {
      final fake = _FakeLocationService(
        lastKnown: _position(
          lat: 21.4225,
          lng: 39.8262,
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      );
      final service = UserLocationService(fake, prefs);

      final resolved = await service.resolve();

      expect(resolved.source, LocationSource.cachedGps);
      expect(resolved.latitude, closeTo(21.4225, 0.0001));
    });

    test(
        'un fix périmé (pays de départ) est ignoré au profit du repli, '
        'et non présenté comme la position du pèlerin', () async {
      // Niamey, il y a 3 jours : exactement le cas du pèlerin arrivé à
      // La Mecque dont le téléphone n'a pas encore de fix local.
      final fake = _FakeLocationService(
        lastKnown: _position(
          lat: 13.5116,
          lng: 2.1254,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
      );
      final service = UserLocationService(fake, prefs);

      final resolved = await service.resolve();

      expect(resolved.source, LocationSource.fallback);
      expect(resolved.isApproximate, isTrue);
      expect(resolved.latitude, closeTo(UserLocationService.fallbackLat, 0.001));
    });

    test('sans permission, aucun fix n\'est lu', () async {
      final fake = _FakeLocationService(
        permission: LocationPermission.denied,
        lastKnown: _position(
          lat: 13.5116,
          lng: 2.1254,
          timestamp: DateTime.now(),
        ),
      );
      final service = UserLocationService(fake, prefs);

      final resolved = await service.resolve();

      expect(resolved.source, LocationSource.fallback);
    });
  });

  group('UserLocationService — choix manuel', () {
    test('le lieu choisi gagne sur le GPS', () async {
      final fake = _FakeLocationService(
        lastKnown: _position(
          lat: 21.4225,
          lng: 39.8262,
          timestamp: DateTime.now(),
        ),
      );
      final service = UserLocationService(fake, prefs);

      final madinah = UserLocationService.presetById('madinah')!;
      await service.setManualPlace(madinah);

      final resolved = await service.resolve();

      expect(resolved.source, LocationSource.manual);
      expect(resolved.latitude, closeTo(madinah.latitude, 0.0001));
      expect(resolved.placeName, contains('Médine'));
    });

    test('le choix manuel survit à une nouvelle instance (persisté)', () async {
      final fake = _FakeLocationService();
      final service = UserLocationService(fake, prefs);
      await service.setManualPlace(UserLocationService.presetById('mina')!);

      final other = UserLocationService(_FakeLocationService(), prefs);
      final resolved = await other.resolve();

      expect(resolved.source, LocationSource.manual);
      expect(resolved.placeName, 'Mina');
    });

    test('effacer le choix manuel rend la main au GPS', () async {
      final fake = _FakeLocationService(
        lastKnown: _position(
          lat: 21.4225,
          lng: 39.8262,
          timestamp: DateTime.now(),
        ),
      );
      final service = UserLocationService(fake, prefs);
      await service.setManualPlace(UserLocationService.presetById('madinah')!);
      await service.clearManualLocation();

      final resolved = await service.resolve();

      expect(resolved.source, LocationSource.cachedGps);
    });
  });

  group('UserLocationService — nommage local des coordonnées', () {
    test('reconnaît la région de La Mecque', () {
      expect(
        UserLocationService.describeCoordinates(21.4225, 39.8262),
        'Makkah',
      );
    });

    test('reconnaît la région de Médine', () {
      expect(
        UserLocationService.describeCoordinates(24.4672, 39.6112),
        'Madinah',
      );
    });

    test('ne nomme pas une position lointaine', () {
      // Riyad : ne doit surtout pas être étiquetée « Makkah ».
      expect(UserLocationService.describeCoordinates(24.7136, 46.6753), isNull);
    });
  });
}
