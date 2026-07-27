import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/services/prayer_times_service.dart';
import 'package:sahabi_guide/shared/services/user_location_service.dart';

/// Source de position pilotée par le test.
class _StubUserLocationService implements UserLocationService {
  _StubUserLocationService(this.next);

  ResolvedLocation next;
  int resolveCalls = 0;

  @override
  Future<ResolvedLocation> resolve({bool forceGps = false}) async {
    resolveCalls++;
    return next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ResolvedLocation _at(
  double lat,
  double lng, {
  LocationSource source = LocationSource.gps,
  String? name,
}) =>
    ResolvedLocation(
      latitude: lat,
      longitude: lng,
      source: source,
      placeName: name,
      timestamp: DateTime.now(),
    );

void main() {
  group('PrayerTimesService — position', () {
    test('calcule sur les coordonnées résolues', () async {
      final stub = _StubUserLocationService(_at(24.4672, 39.6112));
      final service = PrayerTimesService(stub);

      final schedule = await service.getTodaySchedule();

      expect(schedule.latitude, closeTo(24.4672, 0.0001));
      expect(schedule.longitude, closeTo(39.6112, 0.0001));
      expect(schedule.prayers, hasLength(5));
      expect(schedule.isFallbackLocation, isFalse);
    });

    test('signale un repli comme approximatif', () async {
      final stub = _StubUserLocationService(
        _at(21.4225, 39.8262, source: LocationSource.fallback),
      );
      final service = PrayerTimesService(stub);

      final schedule = await service.getTodaySchedule();

      expect(schedule.isFallbackLocation, isTrue);
    });
  });

  group('PrayerTimesService — cache', () {
    test('réutilise le calcul quand la position n\'a pas bougé', () async {
      final stub = _StubUserLocationService(_at(21.4225, 39.8262));
      final service = PrayerTimesService(stub);

      final first = await service.getTodaySchedule();
      final second = await service.getTodaySchedule();

      expect(identical(first, second), isTrue);
    });

    test('recalcule après un déplacement significatif (Djeddah → La Mecque)',
        () async {
      final stub = _StubUserLocationService(_at(21.5433, 39.1728));
      final service = PrayerTimesService(stub);

      final jeddah = await service.getTodaySchedule();
      stub.next = _at(21.4225, 39.8262);
      final makkah = await service.getTodaySchedule();

      expect(identical(jeddah, makkah), isFalse);
      expect(makkah.longitude, closeTo(39.8262, 0.0001));
    });

    test('recalcule quand la source change (repli → GPS)', () async {
      final stub = _StubUserLocationService(
        _at(21.4225, 39.8262, source: LocationSource.fallback),
      );
      final service = PrayerTimesService(stub);

      final fallback = await service.getTodaySchedule();
      stub.next = _at(21.4225, 39.8262, source: LocationSource.gps);
      final gps = await service.getTodaySchedule();

      expect(identical(fallback, gps), isFalse);
      expect(gps.isFallbackLocation, isFalse);
    });
  });

  group('PrayerTimesService — fuseau du lieu', () {
    test('les heures en Arabie saoudite sont exprimées en UTC+3', () async {
      final stub = _StubUserLocationService(_at(21.4225, 39.8262));
      final service = PrayerTimesService(stub);

      final schedule = await service.getTodaySchedule();

      expect(schedule.utcOffset, const Duration(hours: 3));
      expect(schedule.utcOffsetLabel, 'UTC+3');

      // L'heure affichée est l'heure murale à La Mecque, quel que soit le
      // fuseau du téléphone (cas du mobile resté sur le pays de départ).
      for (final prayer in schedule.prayers) {
        final expected = prayer.time.toUtc().add(const Duration(hours: 3));
        expect(
          prayer.formattedTime,
          '${expected.hour.toString().padLeft(2, '0')}:'
          '${expected.minute.toString().padLeft(2, '0')}',
        );
      }
    });

    test('les instants restent comparables à maintenant', () async {
      final stub = _StubUserLocationService(_at(21.4225, 39.8262));
      final service = PrayerTimesService(stub);

      final schedule = await service.getTodaySchedule();
      final next = schedule.next;

      // `next` ne doit jamais être dans le passé : c'est ce qui casse quand on
      // stocke une heure murale à la place d'un instant réel.
      if (next != null) {
        expect(next.time.isAfter(DateTime.now()), isTrue);
      }
      // Prières triées chronologiquement.
      for (var i = 1; i < schedule.prayers.length; i++) {
        expect(
          schedule.prayers[i].time.isAfter(schedule.prayers[i - 1].time),
          isTrue,
        );
      }
    });

    test('hors Arabie saoudite, on garde le fuseau de l\'appareil', () async {
      // Paris.
      final stub = _StubUserLocationService(_at(48.8566, 2.3522));
      final service = PrayerTimesService(stub);

      final schedule = await service.getTodaySchedule();

      expect(schedule.utcOffset, DateTime.now().timeZoneOffset);
    });
  });
}
