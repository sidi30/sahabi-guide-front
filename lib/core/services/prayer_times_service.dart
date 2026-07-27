import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/services/user_location_service.dart';
import '../utils/app_logger.dart';

/// Computed Islamic prayer schedule for a given day & location.
class DailyPrayerSchedule {
  final DateTime date;
  final double latitude;
  final double longitude;
  final List<PrayerEntry> prayers;

  /// Position ayant servi au calcul (GPS, choix manuel, ou repli).
  final ResolvedLocation location;

  /// Fuseau horaire du LIEU (pas forcément celui du téléphone).
  final String timeZoneName;

  /// Décalage du lieu par rapport à UTC, au jour calculé.
  final Duration utcOffset;

  const DailyPrayerSchedule({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.prayers,
    required this.location,
    required this.timeZoneName,
    required this.utcOffset,
  });

  /// True when the schedule was computed from the Mecca fallback coordinates
  /// because no device location was available. The UI can surface this so the
  /// displayed times are not presented as authoritative for the user's place.
  bool get isFallbackLocation => location.source == LocationSource.fallback;

  /// Vrai quand le fuseau du lieu diffère de celui du téléphone : les heures
  /// affichées sont l'heure locale du lieu, pas celle de l'horloge du mobile.
  bool get timeZoneDiffersFromDevice =>
      utcOffset != DateTime.now().timeZoneOffset;

  /// Libellé lisible du fuseau, ex. « UTC+3 ».
  String get utcOffsetLabel {
    final sign = utcOffset.isNegative ? '-' : '+';
    final h = utcOffset.inHours.abs();
    final m = utcOffset.inMinutes.abs().remainder(60);
    return m == 0 ? 'UTC$sign$h' : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
  }

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

  /// Instant réel de la prière (comparable à [DateTime.now]).
  final DateTime time;

  /// Décalage UTC du lieu, utilisé pour l'affichage en heure locale du lieu.
  final Duration locationUtcOffset;

  const PrayerEntry({
    required this.name,
    required this.displayName,
    required this.time,
    required this.locationUtcOffset,
  });

  /// Heure murale AU LIEU du pèlerin. Si le téléphone est resté au fuseau du
  /// pays de départ, l'heure affichée reste celle du lieu de prière.
  String get formattedTime {
    final atPlace = time.toUtc().add(locationUtcOffset);
    final h = atPlace.hour.toString().padLeft(2, '0');
    final m = atPlace.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Service that computes Islamic prayer times from the pilgrim's location.
///
/// La position vient de [UserLocationService] : GPS frais, dernier fix récent,
/// lieu choisi manuellement, ou repli La Mecque — jamais un fix périmé du pays
/// de départ.
class PrayerTimesService {
  PrayerTimesService(this._userLocationService);

  final UserLocationService _userLocationService;

  /// Au-delà de ce déplacement, le calcul est refait même si le cache du jour
  /// existe (changement de ville dans la journée : Djeddah → La Mecque, etc.).
  static const double _recomputeDistanceMeters = 15000;

  DailyPrayerSchedule? _cached;
  DateTime? _cacheDay;
  static bool _tzInitialized = false;

  /// Compute today's prayer schedule. Uses cached value if computed
  /// for the current calendar day at (roughly) the same place.
  Future<DailyPrayerSchedule> getTodaySchedule({
    bool forceRefresh = false,
    bool forceGps = false,
  }) async {
    final today = _truncateToDay(DateTime.now());
    final location = await _userLocationService.resolve(forceGps: forceGps);

    final cached = _cached;
    if (!forceRefresh &&
        cached != null &&
        _cacheDay != null &&
        _cacheDay!.isAtSameMomentAs(today) &&
        !_hasMovedSignificantly(cached, location)) {
      return cached;
    }

    final schedule = _computeSchedule(today, location);
    _cached = schedule;
    _cacheDay = today;
    return schedule;
  }

  /// Recalcule après un changement explicite de position (bouton « mettre à
  /// jour ma position », choix d'une ville dans le sélecteur).
  Future<DailyPrayerSchedule> refresh({bool forceGps = false}) =>
      getTodaySchedule(forceRefresh: true, forceGps: forceGps);

  bool _hasMovedSignificantly(
    DailyPrayerSchedule cached,
    ResolvedLocation location,
  ) {
    // Un changement de source (repli → GPS, GPS → choix manuel) doit toujours
    // recalculer, même si les coordonnées sont proches.
    if (cached.location.source != location.source) return true;
    final d = Geolocator.distanceBetween(
      cached.latitude,
      cached.longitude,
      location.latitude,
      location.longitude,
    );
    return d > _recomputeDistanceMeters;
  }

  DailyPrayerSchedule _computeSchedule(
    DateTime day,
    ResolvedLocation location,
  ) {
    final coords = Coordinates(location.latitude, location.longitude);
    // Umm al-Qura est la méthode officielle en Arabie saoudite (celle des
    // adhans entendus sur place) ; ailleurs, Muslim World League.
    final inSaudi = _isInSaudiArabia(location.latitude, location.longitude);
    final params = (inSaudi
            ? CalculationMethod.umm_al_qura
            : CalculationMethod.muslim_world_league)
        .getParameters();
    params.madhab = Madhab.shafi;

    final dateComponents = DateComponents(day.year, day.month, day.day);
    // Constructeur par défaut : les DateTime renvoyés sont des instants réels
    // (fuseau du téléphone). L'affichage est reprojeté sur le fuseau du LIEU.
    final times = PrayerTimes(coords, dateComponents, params);

    final zone = _zoneForCoordinates(location.latitude, location.longitude);
    final offset = _offsetFor(zone, times.fajr);

    final entries = <PrayerEntry>[
      _entry('fajr', 'Fajr', times.fajr, offset),
      _entry('dhuhr', 'Dhuhr', times.dhuhr, offset),
      _entry('asr', 'Asr', times.asr, offset),
      _entry('maghrib', 'Maghrib', times.maghrib, offset),
      _entry('isha', 'Isha', times.isha, offset),
    ];

    return DailyPrayerSchedule(
      date: day,
      latitude: location.latitude,
      longitude: location.longitude,
      prayers: entries,
      location: location,
      timeZoneName: zone?.name ?? DateTime.now().timeZoneName,
      utcOffset: offset,
    );
  }

  PrayerEntry _entry(
    String name,
    String displayName,
    DateTime time,
    Duration offset,
  ) =>
      PrayerEntry(
        name: name,
        displayName: displayName,
        time: time,
        locationUtcOffset: offset,
      );

  /// Fuseau du lieu. Le seul cas qui compte réellement pour un pèlerin est
  /// l'Arabie saoudite (Asia/Riyadh, UTC+3, sans heure d'été) : c'est là que
  /// l'horloge du téléphone reste souvent bloquée sur le pays de départ.
  /// Hors de cette zone, on garde le fuseau de l'appareil.
  tz.Location? _zoneForCoordinates(double lat, double lng) {
    if (!_isInSaudiArabia(lat, lng)) return null;
    try {
      if (!_tzInitialized) {
        tz_data.initializeTimeZones();
        _tzInitialized = true;
      }
      return tz.getLocation('Asia/Riyadh');
    } catch (e) {
      AppLogger.warning('[PrayerTimesService] fuseau Asia/Riyadh indisponible',
          error: e);
      return null;
    }
  }

  bool _isInSaudiArabia(double lat, double lng) =>
      lat >= 16.0 && lat <= 32.5 && lng >= 34.5 && lng <= 56.0;

  Duration _offsetFor(tz.Location? zone, DateTime instant) {
    if (zone == null) return instant.timeZoneOffset;
    final at = tz.TZDateTime.from(instant, zone);
    return at.timeZoneOffset;
  }

  DateTime _truncateToDay(DateTime d) => DateTime(d.year, d.month, d.day);
}
