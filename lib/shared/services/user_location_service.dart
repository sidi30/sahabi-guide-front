import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_logger.dart';
import 'location_service.dart';

/// D'où provient la position utilisée par l'app (prières, carte, distances).
enum LocationSource {
  /// Lieu choisi explicitement par le pèlerin (ville ou site).
  manual,

  /// Fix GPS obtenu à l'instant.
  gps,

  /// Dernier fix GPS connu, encore considéré comme valide.
  cachedGps,

  /// Aucune position disponible : repli sur Masjid al-Haram.
  fallback,
}

/// Un lieu proposé dans le sélecteur manuel.
class HolyPlace {
  final String id;
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const HolyPlace({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}

/// Position effective résolue par [UserLocationService].
class ResolvedLocation {
  final double latitude;
  final double longitude;
  final LocationSource source;

  /// Nom du lieu quand il est connu (choix manuel ou ville reconnue).
  final String? placeName;

  /// Date du fix GPS, ou date du choix manuel.
  final DateTime timestamp;

  const ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.timestamp,
    this.placeName,
  });

  /// Vrai quand la position n'a pas été mesurée : les horaires calculés
  /// dessus ne doivent pas être présentés comme ceux du pèlerin.
  bool get isApproximate => source == LocationSource.fallback;

  /// Âge de l'information de position.
  Duration get age => DateTime.now().difference(timestamp);

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'source': source.name,
        'placeName': placeName,
        'timestamp': timestamp.toIso8601String(),
      };

  static ResolvedLocation? tryParse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final lat = (json['lat'] as num?)?.toDouble();
      final lng = (json['lng'] as num?)?.toDouble();
      final ts = DateTime.tryParse(json['timestamp'] as String? ?? '');
      if (lat == null || lng == null || ts == null) return null;
      return ResolvedLocation(
        latitude: lat,
        longitude: lng,
        source: LocationSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => LocationSource.manual,
        ),
        placeName: json['placeName'] as String?,
        timestamp: ts,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Source unique de vérité de « où se trouve le pèlerin ».
///
/// Ordre de résolution :
/// 1. lieu choisi manuellement (il gagne toujours — c'est une décision du pèlerin) ;
/// 2. fix GPS frais ;
/// 3. dernier fix GPS connu s'il est encore récent ([_staleFixThreshold]) ;
/// 4. dernier fix persisté par l'app (survit à un redémarrage hors-ligne) ;
/// 5. repli Masjid al-Haram, signalé comme approximatif.
///
/// Le point 3 est délibérément borné dans le temps : `getLastKnownPosition()`
/// peut renvoyer la position du pays de départ plusieurs jours après le vol,
/// ce qui donnait des horaires de prière du pays d'origine à La Mecque.
class UserLocationService {
  UserLocationService(this._locationService, this._prefs);

  final LocationService _locationService;
  final SharedPreferences _prefs;

  static const String _manualKey = 'user_location_manual';
  static const String _lastFixKey = 'user_location_last_fix';

  /// Au-delà, un « dernier fix connu » n'est plus digne de confiance.
  static const Duration _staleFixThreshold = Duration(hours: 4);

  /// Au-delà, même le fix persisté est abandonné au profit du repli.
  static const Duration _persistedFixMaxAge = Duration(days: 2);

  /// Masjid al-Haram — repli quand rien d'autre n'est disponible.
  static const double fallbackLat = 21.4225;
  static const double fallbackLng = 39.8262;

  /// Lieux proposés dans le sélecteur manuel (pèlerinage + villes d'arrivée).
  static const List<HolyPlace> presets = [
    HolyPlace(
      id: 'makkah',
      name: 'La Mecque (Masjid al-Haram)',
      region: 'Makkah',
      latitude: 21.4225,
      longitude: 39.8262,
    ),
    HolyPlace(
      id: 'madinah',
      name: 'Médine (Masjid an-Nabawi)',
      region: 'Madinah',
      latitude: 24.4672,
      longitude: 39.6112,
    ),
    HolyPlace(
      id: 'mina',
      name: 'Mina',
      region: 'Makkah',
      latitude: 21.4133,
      longitude: 39.8933,
    ),
    HolyPlace(
      id: 'arafat',
      name: 'Arafat (Jabal ar-Rahmah)',
      region: 'Makkah',
      latitude: 21.3549,
      longitude: 39.9841,
    ),
    HolyPlace(
      id: 'muzdalifah',
      name: 'Muzdalifah',
      region: 'Makkah',
      latitude: 21.3833,
      longitude: 39.9367,
    ),
    HolyPlace(
      id: 'jeddah',
      name: 'Djeddah',
      region: 'Makkah',
      latitude: 21.5433,
      longitude: 39.1728,
    ),
  ];

  static HolyPlace? presetById(String id) {
    for (final p in presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Lieu choisi manuellement, ou null si l'app suit le GPS.
  ResolvedLocation? get manualLocation {
    final raw = _prefs.getString(_manualKey);
    if (raw == null) return null;
    return ResolvedLocation.tryParse(raw);
  }

  bool get hasManualLocation => _prefs.getString(_manualKey) != null;

  Future<void> setManualPlace(HolyPlace place) async {
    final loc = ResolvedLocation(
      latitude: place.latitude,
      longitude: place.longitude,
      source: LocationSource.manual,
      placeName: place.name,
      timestamp: DateTime.now(),
    );
    await _prefs.setString(_manualKey, jsonEncode(loc.toJson()));
  }

  Future<void> setManualCoordinates(
    double lat,
    double lng, {
    String? name,
  }) async {
    final loc = ResolvedLocation(
      latitude: lat,
      longitude: lng,
      source: LocationSource.manual,
      placeName: name ?? describeCoordinates(lat, lng),
      timestamp: DateTime.now(),
    );
    await _prefs.setString(_manualKey, jsonEncode(loc.toJson()));
  }

  /// Repasse en suivi GPS automatique.
  Future<void> clearManualLocation() async {
    await _prefs.remove(_manualKey);
  }

  /// Résout la position courante.
  ///
  /// [forceGps] force une nouvelle mesure (bouton « mettre à jour ma position »)
  /// et ignore le cache mémoire du fix, mais respecte toujours un choix manuel.
  Future<ResolvedLocation> resolve({bool forceGps = false}) async {
    final manual = manualLocation;
    if (manual != null) return manual;

    final fix = await _readGpsPosition(forceFresh: forceGps);
    if (fix != null) {
      await _persistFix(fix);
      return fix;
    }

    final persisted = _readPersistedFix();
    if (persisted != null) return persisted;

    return ResolvedLocation(
      latitude: fallbackLat,
      longitude: fallbackLng,
      source: LocationSource.fallback,
      placeName: 'La Mecque',
      timestamp: DateTime.now(),
    );
  }

  /// Force une nouvelle mesure GPS et l'installe comme position courante,
  /// en supprimant un éventuel choix manuel. Renvoie null si la mesure échoue.
  Future<ResolvedLocation?> refreshFromGps() async {
    await clearManualLocation();
    final fix = await _readGpsPosition(forceFresh: true);
    if (fix != null) await _persistFix(fix);
    return fix;
  }

  Future<ResolvedLocation?> _readGpsPosition({required bool forceFresh}) async {
    try {
      final permission = await _locationService.checkLocationPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) {
        AppLogger.debug('[UserLocationService] permission=$permission');
        return null;
      }

      if (!await _locationService.isLocationServiceEnabled()) {
        AppLogger.debug('[UserLocationService] service de localisation coupé');
        return null;
      }

      // Un dernier fix récent évite d'allumer le GPS pour rien.
      if (!forceFresh) {
        final last = await _locationService.getLastKnownPosition();
        final fresh = _asFixIfFresh(last, _staleFixThreshold);
        if (fresh != null) return fresh;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return ResolvedLocation(
        latitude: current.latitude,
        longitude: current.longitude,
        source: LocationSource.gps,
        placeName: describeCoordinates(current.latitude, current.longitude),
        timestamp: current.timestamp,
      );
    } catch (e) {
      AppLogger.warning('[UserLocationService] fix GPS indisponible', error: e);
      // Le fix figé peut encore servir s'il est récent.
      try {
        final last = await _locationService.getLastKnownPosition();
        return _asFixIfFresh(last, _staleFixThreshold);
      } catch (_) {
        return null;
      }
    }
  }

  ResolvedLocation? _asFixIfFresh(Position? position, Duration maxAge) {
    if (position == null) return null;
    final ts = position.timestamp;
    if (DateTime.now().difference(ts) > maxAge) return null;
    return ResolvedLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      source: LocationSource.cachedGps,
      placeName: describeCoordinates(position.latitude, position.longitude),
      timestamp: ts,
    );
  }

  Future<void> _persistFix(ResolvedLocation fix) async {
    await _prefs.setString(_lastFixKey, jsonEncode(fix.toJson()));
  }

  ResolvedLocation? _readPersistedFix() {
    final raw = _prefs.getString(_lastFixKey);
    if (raw == null) return null;
    final fix = ResolvedLocation.tryParse(raw);
    if (fix == null) return null;
    if (fix.age > _persistedFixMaxAge) return null;
    return ResolvedLocation(
      latitude: fix.latitude,
      longitude: fix.longitude,
      source: LocationSource.cachedGps,
      placeName: fix.placeName,
      timestamp: fix.timestamp,
    );
  }

  /// Nomme grossièrement une coordonnée à partir des zones connues du
  /// pèlerinage. Purement local : aucun appel réseau de géocodage.
  static String? describeCoordinates(double lat, double lng) {
    HolyPlace? best;
    double bestDistance = double.infinity;
    for (final place in presets) {
      final d = Geolocator.distanceBetween(
        lat,
        lng,
        place.latitude,
        place.longitude,
      );
      if (d < bestDistance) {
        bestDistance = d;
        best = place;
      }
    }
    // 25 km : assez large pour couvrir l'agglomération, assez serré pour ne
    // pas étiqueter « La Mecque » une position à Riyad.
    if (best != null && bestDistance <= 25000) return best.region;
    return null;
  }
}
