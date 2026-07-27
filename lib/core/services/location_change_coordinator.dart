import '../di/injection_container.dart';
import '../utils/app_logger.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';

/// Point d'application unique d'un changement de position.
///
/// Un changement de lieu doit TOUJOURS entraîner les deux effets : recalcul des
/// horaires et reprogrammation des notifications. Les écrans (accueil, carte)
/// passent par ici plutôt que d'enchaîner les deux appels chacun de leur côté —
/// c'est le duplicata qui finissait par diverger (notifications restées à
/// l'heure du pays de départ).
class LocationChangeCoordinator {
  const LocationChangeCoordinator._();

  /// Recalcule les horaires sur la position courante et reprogramme les
  /// notifications. [forceGps] force une nouvelle mesure GPS.
  static Future<DailyPrayerSchedule> apply({bool forceGps = false}) async {
    final schedule =
        await sl<PrayerTimesService>().refresh(forceGps: forceGps);
    try {
      await sl<NotificationService>().reschedulePrayerNotifications(schedule);
    } catch (e) {
      // Une notification non reprogrammée ne doit pas empêcher l'affichage
      // des nouveaux horaires.
      AppLogger.warning('Reprogrammation des notifications impossible',
          error: e);
    }
    return schedule;
  }
}
