import '../../../core/utils/app_logger.dart';
import '../../../shared/services/user_location_service.dart';
import '../domain/sos_request.dart';

/// Position jointe à un SOS, avec sa provenance.
class SosFix {
  const SosFix({
    required this.latitude,
    required this.longitude,
    required this.origin,
    required this.capturedAt,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final SosLocationOrigin origin;
  final DateTime capturedAt;
  final double? accuracyMeters;
}

/// Obtient une position pour un SOS — sans jamais bloquer l'envoi.
///
/// Le déclenchement d'un SOS ne doit pas dépendre du GPS : au-delà de
/// [timeout], on part sans coordonnées. Un SOS sans position vaut infiniment
/// mieux qu'un SOS non envoyé.
///
/// On s'appuie sur [UserLocationService], source unique de « où est le
/// pèlerin », et on ne modifie rien au passage (pas de `refreshFromGps`, qui
/// effacerait le lieu choisi manuellement pour toute l'app).
class SosLocationResolver {
  SosLocationResolver(this._userLocation);

  static const Duration defaultTimeout = Duration(seconds: 5);

  final UserLocationService _userLocation;

  Future<SosFix?> resolve({Duration timeout = defaultTimeout}) async {
    try {
      final location =
          await _userLocation.resolve(forceGps: true).timeout(timeout);

      final origin = _originOf(location.source);
      if (origin == SosLocationOrigin.none) {
        // Repli Masjid al-Haram : ce n'est PAS la position du pèlerin. L'envoyer
        // enverrait les secours au mauvais endroit.
        AppLogger.warning('[SOS] position de repli ignorée, envoi sans position');
        return null;
      }

      return SosFix(
        latitude: location.latitude,
        longitude: location.longitude,
        origin: origin,
        capturedAt: location.timestamp,
      );
    } catch (e) {
      // Timeout, permission refusée, GPS coupé : on continue sans position.
      AppLogger.warning('[SOS] position indisponible, envoi sans position',
          error: e);
      return null;
    }
  }

  SosLocationOrigin _originOf(LocationSource source) {
    switch (source) {
      case LocationSource.gps:
        return SosLocationOrigin.freshGps;
      case LocationSource.cachedGps:
        return SosLocationOrigin.lastKnownGps;
      case LocationSource.manual:
        return SosLocationOrigin.declaredPlace;
      case LocationSource.fallback:
        return SosLocationOrigin.none;
    }
  }
}
