import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../shared/services/location_service.dart';

/// Computed Islamic prayer schedule for a given day & location.
class DailyPrayerSchedule {
  final DateTime date;
  final double latitude;
  final double longitude;
  final List<PrayerEntry> prayers;

  /// True when the schedule was computed from the Mecca fallback coordinates
  /// because no device location was available. The UI can surface this so the
  /// displayed times are not presented as authoritative for the user's place.
  final bool isFallbackLocation;

  const DailyPrayerSchedule({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.prayers,
    this.isFallbackLocation = false,
  });

  /// Returns the prayer occurring right now (or last passed today).
  PrayerEntry? get current {
    final now = DateTime.now();
    PrayerEntry? last;
    for (final p in prayers) {
      if (!p.time.isAfter(now)) {
        last = p;
      } else {
        break;
      }
    }
    return last;
  }

  /// Returns the next prayer to come today.
  PrayerEntry? get next {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }
}

class PrayerEntry {
  final String name;
  final String displayName;
  final DateTime time;

  const PrayerEntry({
    required this.name,
    required this.displayName,
    required this.time,
  });

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Service that computes Islamic prayer times from device geolocation.
/// Falls back to Mecca coordinates when location is unavailable.
class PrayerTimesService {
  PrayerTimesService(this._locationService);

  final LocationService _locationService;

  // Mecca (Masjid al-Haram) fallback coordinates.
  static const double _fallbackLat = 21.4225;
  static const double _fallbackLng = 39.8262;

  DailyPrayerSchedule? _cached;
  DateTime? _cacheDay;

  /// Compute today's prayer schedule. Uses cached value if computed
  /// for the current calendar day already.
  Future<DailyPrayerSchedule> getTodaySchedule({bool forceRefresh = false}) async {
    final today = _truncateToDay(DateTime.now());
    if (!forceRefresh &&
        _cached != null &&
        _cacheDay != null &&
        _cacheDay!.isAtSameMomentAs(today)) {
      return _cached!;
    }

    final position = await _safeReadPosition();
    final usedFallback = position == null;
    final lat = position?.latitude ?? _fallbackLat;
    final lng = position?.longitude ?? _fallbackLng;

    final schedule = _computeSchedule(today, lat, lng, usedFallback);
    _cached = schedule;
    _cacheDay = today;
    return schedule;
  }

  DailyPrayerSchedule _computeSchedule(
      DateTime day, double lat, double lng, bool usedFallback) {
    final coords = Coordinates(lat, lng);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final dateComponents = DateComponents(day.year, day.month, day.day);
    final times = PrayerTimes(coords, dateComponents, params);

    final entries = <PrayerEntry>[
      PrayerEntry(name: 'fajr', displayName: 'Fajr', time: times.fajr),
      PrayerEntry(name: 'dhuhr', displayName: 'Dhuhr', time: times.dhuhr),
      PrayerEntry(name: 'asr', displayName: 'Asr', time: times.asr),
      PrayerEntry(name: 'maghrib', displayName: 'Maghrib', time: times.maghrib),
      PrayerEntry(name: 'isha', displayName: 'Isha', time: times.isha),
    ];

    return DailyPrayerSchedule(
      date: day,
      latitude: lat,
      longitude: lng,
      prayers: entries,
      isFallbackLocation: usedFallback,
    );
  }

  Future<Position?> _safeReadPosition() async {
    try {
      // Ne pas demander une position si la permission n'est pas accordée :
      // getCurrentPosition lèverait, et on retomberait silencieusement sur la
      // Mecque alors que la dernière position connue peut suffire.
      final permission = await _locationService.checkLocationPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      // Toujours préférer la dernière position connue (rapide, pas de fix GPS).
      final last = await _locationService.getLastKnownPosition();
      if (last != null) return last;

      if (!granted) {
        if (kDebugMode) {
          debugPrint(
              '[PrayerTimesService] permission $permission, fallback Mecca');
        }
        return null;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return current;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PrayerTimesService] geo unavailable, fallback Mecca: $e');
      }
      return null;
    }
  }

  DateTime _truncateToDay(DateTime d) => DateTime(d.year, d.month, d.day);
}
