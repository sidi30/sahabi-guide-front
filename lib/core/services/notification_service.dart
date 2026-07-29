import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../main.dart' show AppRoutes, MyApp;
import '../../shared/models/ritual_model.dart';
import '../../shared/models/dua_model.dart';
import '../../l10n/app_localizations.dart';
import '../localization/notification_l10n.dart';
import '../utils/app_logger.dart';
import 'prayer_times_service.dart';

/// PLAGES D'IDS RÉSERVÉES — source de vérité unique pour TOUS les
/// planificateurs de l'app (ce service, `RitualService`, le service du bot,
/// `SmartReminderService`).
///
/// C'est le point de dérive à empêcher : un id posé hors de sa plage, ou un
/// `cancelAll()`, efface silencieusement les rappels d'un autre domaine (c'est
/// ainsi que planifier des rituels supprimait les notifications de prière).
/// Règle : on ne pose un id que via les helpers ci-dessous, et on n'annule
/// JAMAIS au-delà de sa propre plage.
///
///     0 –  999  rituels : notification principale
///  1000 – 1999  rituels : rappel avant
///  2000 – 2999  rituels : rappel de retard
///  3000 – 3099  prières quotidiennes (récurrentes)
///  3100 – 3199  duas (dua du jour récurrente + rappels immédiats)
///  5000 – 5999  assistant / bot : rappels contextuels
///  6000 – 6999  rappels intelligents (SmartReminderService)
class NotificationIds {
  const NotificationIds._();

  static const int ritualMainStart = 0;
  static const int ritualMainEnd = 1000;

  static const int ritualReminderStart = 1000;
  static const int ritualReminderEnd = 2000;

  static const int ritualOverdueStart = 2000;
  static const int ritualOverdueEnd = 3000;

  static const int prayerStart = 3000;
  static const int prayerEnd = 3100;

  static const int duaStart = 3100;
  static const int duaEnd = 3200;

  /// Dua du jour : ids FIXES. Re-planifier écrase l'ancienne au lieu
  /// d'empiler un doublon par dua et par session.
  static const int duaOfTheDayMorning = duaStart;
  static const int duaOfTheDayEvening = duaStart + 1;

  /// Rappels de dua affichés à la demande (hors dua du jour).
  static const int duaImmediateStart = duaStart + 10;
  static const int duaImmediateEnd = duaEnd;

  static const int botStart = 5000;
  static const int botEnd = 6000;

  static const int smartReminderStart = 6000;
  static const int smartReminderEnd = 7000;

  static int ritualMain(int order) =>
      ritualMainStart + order.abs() % (ritualMainEnd - ritualMainStart);

  static int ritualReminder(int order) =>
      ritualReminderStart + order.abs() % (ritualReminderEnd - ritualReminderStart);

  static int ritualOverdue(int order) =>
      ritualOverdueStart + order.abs() % (ritualOverdueEnd - ritualOverdueStart);

  /// Id déterministe borné à `[start, end[`, dérivé d'une clé métier stable.
  ///
  /// Remplace `Object.hashCode`, qui change d'une session à l'autre (donc
  /// impossible d'annuler ou de remplacer une notification déjà posée) et peut
  /// dépasser l'int32 accepté par Android/iOS. Hash DJB2 borné à 24 bits pour
  /// rester exact sur toutes les plateformes.
  static int stableId(String key, {required int start, required int end}) {
    var hash = 5381;
    for (final unit in key.codeUnits) {
      hash = ((hash * 33) ^ unit) & 0xffffff;
    }
    return start + hash % (end - start);
  }
}

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final List<ScheduledNotification> _scheduledNotifications = [];

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialise la base IANA des fuseaux horaires AVANT toute utilisation de
    // tz.local — sinon LateInitializationError sur _local lors du schedule
    // des prières (cron Fajr/Dhuhr/Asr/Maghrib/Isha).
    tz_data.initializeTimeZones();
    tz.setLocalLocation(_guessLocalLocation());

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 13+ (API 33) exige POST_NOTIFICATIONS à l'exécution : sans cet
    // appel, le système ignore SILENCIEUSEMENT tout ce qu'on planifie — prières
    // comprises. iOS demande déjà via requestAlertPermission ci-dessus ; ceci
    // met Android au même niveau. Une seule boîte de dialogue, au premier
    // lancement, dans le même geste que l'app pose ses rappels.
    await requestPermissions();

    _isInitialized = true;
    notifyListeners();
  }

  /// Devine la tz IANA de l'appareil. Pas de plugin natif requis (évite le
  /// blocage SSL sur dl.google.com pour `flutter_timezone`).
  ///
  /// L'offset instantané ne suffit PAS : UTC+1 en hiver, c'est aussi bien
  /// Africa/Niamey (WAT toute l'année) que Europe/Paris (CET, qui passe à +2
  /// en été). Choisir Paris pour un pèlerin nigérien faisait glisser tous les
  /// rappels quotidiens d'une heure au changement d'heure européen. On mesure
  /// donc le décalage en janvier ET en juillet : leur différence dit si
  /// l'appareil observe l'heure d'été, et le plus petit des deux est le
  /// décalage standard.
  tz.Location _guessLocalLocation() {
    final year = DateTime.now().year;
    final winter = DateTime(year, 1, 15).timeZoneOffset;
    final summer = DateTime(year, 7, 15).timeZoneOffset;
    return resolveLocalLocation(
      standardOffset: winter <= summer ? winter : summer,
      observesDst: winter != summer,
    );
  }

  /// Zones connues, Afrique de l'Ouest en priorité (public cible : Niger,
  /// Nigeria, Mali/Sénégal) puis Arabie saoudite (sur place pendant le Hajj).
  /// Clé : décalage standard en minutes + observation de l'heure d'été.
  static const Map<String, String> _knownZones = {
    '0:false': 'Africa/Abidjan', // Sénégal, Mali, Côte d'Ivoire — pas de DST
    '0:true': 'Europe/London',
    '60:false': 'Africa/Niamey', // WAT : Niger, Nigeria, Tchad — pas de DST
    '60:true': 'Europe/Paris',
    '120:false': 'Africa/Johannesburg',
    '120:true': 'Europe/Helsinki',
    '180:false': 'Asia/Riyadh', // pèlerinage sur place
    '180:true': 'Europe/Moscow',
    '-300:true': 'America/New_York',
    '330:false': 'Asia/Kolkata',
    '480:false': 'Asia/Singapore',
  };

  @visibleForTesting
  static tz.Location resolveLocalLocation({
    required Duration standardOffset,
    required bool observesDst,
  }) {
    final name =
        _knownZones['${standardOffset.inMinutes}:$observesDst'];
    if (name != null) {
      try {
        return tz.getLocation(name);
      } catch (e) {
        AppLogger.warning('[NotificationService] fuseau $name indisponible',
            error: e);
      }
    }
    return _searchZone(standardOffset, observesDst) ?? tz.UTC;
  }

  /// Repli générique : première zone de la base IANA dont le décalage standard
  /// et le comportement d'heure d'été correspondent à l'appareil. Vaut mieux
  /// qu'un repli sur UTC, qui décalait les rappels de tout l'offset local.
  static tz.Location? _searchZone(Duration standardOffset, bool observesDst) {
    final year = DateTime.now().year;
    final winterMs = DateTime.utc(year, 1, 15).millisecondsSinceEpoch;
    final summerMs = DateTime.utc(year, 7, 15).millisecondsSinceEpoch;
    try {
      for (final location in tz.timeZoneDatabase.locations.values) {
        final winter = location.timeZone(winterMs).offset;
        final summer = location.timeZone(summerMs).offset;
        if ((winter != summer) != observesDst) continue;
        final standard = winter <= summer ? winter : summer;
        if (standard == standardOffset.inMilliseconds) return location;
      }
    } catch (e) {
      AppLogger.warning('[NotificationService] recherche de fuseau échouée',
          error: e);
    }
    return null;
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    AppLogger.debug('Notification tapped: $payload');
    _openPayload(payload);
  }

  /// Ouvre la destination d'un payload. Seul `dua:{id}` est câblé : c'est le
  /// seul deep-link posé par une notification planifiée (dua du jour).
  /// [DuaDetailPage] exige l'objet `DuaModel` et non un id, donc on ouvre la
  /// liste des duas, qui les charge et permet d'aller au détail.
  void _openPayload(String payload) {
    if (!payload.startsWith('dua:')) return;
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) {
      AppLogger.warning(
          '[NotificationService] pas de contexte pour ouvrir $payload');
      return;
    }
    GoRouter.of(context).push(AppRoutes.duas);
  }

  // ====================== PRAYER NOTIFICATIONS ======================

  /// Schedule daily prayer reminders. Cancels previously scheduled
  /// prayer notifications (id range 3000-3099) before scheduling.
  /// Each prayer becomes a daily recurring notification at its time.
  Future<void> schedulePrayerNotifications(DailyPrayerSchedule schedule) async {
    // Localise dans la langue persistée (source : languageProvider).
    final l10n = await NotificationL10n.load();

    // Cancel existing prayer notifs first
    await _cancelRange(NotificationIds.prayerStart, NotificationIds.prayerEnd);

    const androidDetails = AndroidNotificationDetails(
      'prayers_channel',
      'Heures de prière',
      channelDescription: 'Rappels des 5 prières quotidiennes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = DateTime.now();
    int id = NotificationIds.prayerStart;
    for (final p in schedule.prayers) {
      // Skip prayers already passed today — they would not fire until tomorrow
      // anyway with matchDateTimeComponents.time. Still schedule them so they
      // recur daily starting tomorrow.
      final scheduled = p.time;
      try {
        await _notifications.zonedSchedule(
          id,
          l10n.notif_prayer_title,
          l10n.notif_prayer_body(p.displayName, p.formattedTime),
          tz.TZDateTime.from(scheduled, tz.local),
          details,
          payload: 'prayer:${p.name}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // Récurrent : la prière revient chaque jour à la même heure.
          matchDateTimeComponents: DateTimeComponents.time,
        );
        AppLogger.debug(
            '[NotificationService] scheduled ${p.displayName} at ${p.formattedTime} (id=$id, future=${scheduled.isAfter(now)})');
      } catch (e) {
        AppLogger.error('[NotificationService] failed to schedule ${p.displayName}', error: e);
      }
      id++;
    }
  }

  // ====================== RITUAL NOTIFICATIONS ======================

  // Schedule ritual notifications
  Future<void> scheduleRitualNotifications(List<RitualModel> rituals) async {
    final l10n = await NotificationL10n.load();
    await _clearRitualNotifications();

    for (final ritual in rituals) {
      if (ritual.scheduledTime != null && ritual.status != RitualStatus.completed) {
        await _scheduleRitualNotification(ritual, l10n);
      }
    }
  }

  Future<void> _scheduleRitualNotification(
      RitualModel ritual, AppLocalizations l10n) async {
    final scheduledTime = ritual.scheduledTime!;

    // Schedule main notification
    await _scheduleNotification(
      id: NotificationIds.ritualMain(ritual.order),
      title: l10n.notif_ritual_title,
      body: l10n.notif_ritual_start_body(ritual.name),
      scheduledTime: scheduledTime,
      payload: 'ritual:${ritual.id}',
    );

    // Schedule reminder 30 minutes before
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: NotificationIds.ritualReminder(ritual.order),
        title: l10n.notif_ritual_reminder_title,
        body: l10n.notif_ritual_reminder_body(ritual.name),
        scheduledTime: reminderTime,
        payload: 'ritual_reminder:${ritual.id}',
      );
    }

    // Schedule overdue notification 1 hour after scheduled time
    final overdueTime = scheduledTime.add(const Duration(hours: 1));
    await _scheduleNotification(
      id: NotificationIds.ritualOverdue(ritual.order),
      title: l10n.notif_ritual_overdue_title,
      body: l10n.notif_ritual_overdue_body(ritual.name),
      scheduledTime: overdueTime,
      payload: 'ritual_overdue:${ritual.id}',
    );
  }

  // ====================== DUA OF THE DAY ======================

  /// Horaires de la dua du jour. Regroupés ici pour pouvoir les caler plus
  /// tard sur Fajr / Maghrib (cf. [DailyPrayerSchedule]) sans chercher dans
  /// le corps du service.
  static const int duaMorningHour = 6;
  static const int duaMorningMinute = 0;
  static const int duaEveningHour = 18;
  static const int duaEveningMinute = 0;

  /// Origine de la rotation. Fixe et arbitraire : ce qui compte est que le
  /// même jour donne la même dua, sur tous les appareils, sans réseau.
  static final DateTime _duaRotationEpoch = DateTime.utc(2026, 1, 1);

  /// Dua du jour : rotation déterministe sur le corpus disponible.
  ///
  /// `index = (jours écoulés depuis l'époque) % nombre de duas`. Pas d'aléa,
  /// pas d'appel réseau : deux lancements le même jour donnent la même dua,
  /// et le lendemain donne la suivante.
  @visibleForTesting
  static DuaModel? duaOfTheDay(List<DuaModel> duas, {DateTime? day}) {
    final active = duas.where((d) => d.isActive).toList();
    final daily = active.where((d) => d.type == DuaType.daily).toList();
    final pool = daily.isNotEmpty ? daily : active;
    if (pool.isEmpty) return null;

    // Ordre stable : l'API peut renvoyer les duas dans n'importe quel ordre,
    // la rotation ne doit pas en dépendre.
    pool.sort((a, b) => a.id.compareTo(b.id));

    final today = day ?? DateTime.now();
    final elapsed = DateTime.utc(today.year, today.month, today.day)
        .difference(_duaRotationEpoch)
        .inDays;
    return pool[elapsed % pool.length];
  }

  /// Planifie les deux rappels quotidiens (matin + soir) de la dua du jour,
  /// localisés et récurrents, avec un deep-link `dua:{id}`.
  ///
  /// Les ids sont fixes ([NotificationIds.duaOfTheDayMorning] / `...Evening`),
  /// donc re-planifier (changement de langue, nouveau corpus, nouveau jour)
  /// remplace au lieu d'empiler.
  Future<void> scheduleDailyDuaNotifications(List<DuaModel> duas) async {
    await _notifications.cancel(NotificationIds.duaOfTheDayMorning);
    await _notifications.cancel(NotificationIds.duaOfTheDayEvening);

    // Respecte le réglage existant « Toutes les notifications » — on n'ajoute
    // pas de préférence dédiée.
    if (!await _allNotificationsEnabled()) {
      AppLogger.debug('[NotificationService] dua du jour désactivée (réglages)');
      return;
    }

    final dua = duaOfTheDay(duas);
    if (dua == null) {
      AppLogger.debug('[NotificationService] aucune dua disponible');
      return;
    }

    final l10n = await NotificationL10n.load();
    await _scheduleNotification(
      id: NotificationIds.duaOfTheDayMorning,
      title: l10n.notif_dua_morning_title,
      body: l10n.notif_dua_body(dua.title),
      scheduledTime: _nextOccurrence(duaMorningHour, duaMorningMinute),
      payload: 'dua:${dua.id}',
      recurring: true,
    );
    await _scheduleNotification(
      id: NotificationIds.duaOfTheDayEvening,
      title: l10n.notif_dua_evening_title,
      body: l10n.notif_dua_body(dua.title),
      scheduledTime: _nextOccurrence(duaEveningHour, duaEveningMinute),
      payload: 'dua:${dua.id}',
      recurring: true,
    );
    AppLogger.debug(
        '[NotificationService] dua du jour: ${dua.id} (${dua.title})');
  }

  /// Prochaine occurrence de `hour:minute` : aujourd'hui si encore à venir,
  /// demain sinon. iOS refuse une date déjà passée.
  DateTime _nextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }

  /// Interrupteur global des notifications, écrit par
  /// `NotificationsSettingsNotifier` (clé `notif_allEnabled`). Lu directement
  /// dans les préférences car on planifie hors widget, sans `Ref`.
  static Future<bool> _allNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notif_allEnabled') ?? true;
    } catch (_) {
      // Best-effort : en cas d'échec on ne prive pas l'utilisateur du rappel.
      return true;
    }
  }

  /// [recurring] : `true` uniquement pour un rappel qui doit revenir chaque
  /// jour à la même heure. Appliqué à une notification PONCTUELLE (rituel à
  /// date fixe), `matchDateTimeComponents.time` la transformait en rappel
  /// quotidien qui ne s'arrêtait jamais.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool recurring = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rituals_channel',
      'Rituels du Hadj',
      channelDescription: 'Notifications pour les rituels du Hadj',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: recurring ? DateTimeComponents.time : null,
    );

    _scheduledNotifications.add(ScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
    ));
  }

  // Immediate notifications
  Future<void> showRitualReminder(RitualModel ritual) async {
    final l10n = await NotificationL10n.load();
    await _showNotification(
      id: NotificationIds.ritualMain(ritual.order),
      title: l10n.notif_ritual_active_title,
      body: l10n.notif_ritual_active_body(ritual.name),
      payload: 'ritual_active:${ritual.id}',
    );
  }

  Future<void> showDuaReminder(DuaModel dua) async {
    final l10n = await NotificationL10n.load();
    await _showNotification(
      id: NotificationIds.stableId(
        'dua:${dua.id}',
        start: NotificationIds.duaImmediateStart,
        end: NotificationIds.duaImmediateEnd,
      ),
      title: l10n.notif_dua_recommended_title,
      body: l10n.notif_dua_recommended_body(dua.title),
      payload: 'dua_recommended:${dua.id}',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate_channel',
      'Notifications immédiates',
      channelDescription: 'Notifications immédiates pour les rituels',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Annule les rappels de RITUELS uniquement. Un `cancelAll()` effaçait aussi
  /// les prières quotidiennes et la dua du jour, qui ne sont jamais
  /// re-planifiées dans la foulée : elles disparaissaient silencieusement.
  Future<void> _clearRitualNotifications() async {
    await _cancelRange(
        NotificationIds.ritualMainStart, NotificationIds.ritualOverdueEnd);
    _scheduledNotifications.clear();
  }

  /// Annule les notifications en attente dont l'id tombe dans `[start, end[`.
  /// On part des `pendingNotificationRequests` plutôt que de boucler sur toute
  /// la plage : un seul aller-retour plateforme, et on ne touche jamais aux
  /// ids d'un autre domaine.
  Future<void> _cancelRange(int start, int end) async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= start && request.id < end) {
          await _notifications.cancel(request.id);
        }
      }
    } catch (e) {
      AppLogger.error(
          '[NotificationService] annulation de la plage $start-$end échouée',
          error: e);
    }
  }

  Future<void> cancelRitualNotification(String ritualId) async {
    // Find and cancel notifications for this ritual
    final notificationsToCancel = _scheduledNotifications
        .where((n) => n.payload?.contains(ritualId) ?? false)
        .toList();

    for (final notification in notificationsToCancel) {
      await _notifications.cancel(notification.id);
      _scheduledNotifications.remove(notification);
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Re-planifie les notifications de prière (récurrentes quotidiennes) dans la
  /// langue ACTUELLEMENT persistée. À appeler après un changement de langue pour
  /// que les prochaines notifications de prière soient affichées dans la
  /// nouvelle langue. Les rappels de rituels/duas, eux, sont re-planifiés à leur
  /// prochaine programmation (et utilisent déjà la langue courante).
  ///
  /// `schedulePrayerNotifications` annule d'abord les anciennes (id 3000-3099),
  /// donc rappeler avec le même horaire ne crée pas de doublon.
  Future<void> reschedulePrayerNotifications(
      DailyPrayerSchedule schedule) async {
    await schedulePrayerNotifications(schedule);
  }

  /// Appelée par [initialize]. Sur une plateforme non-Android, le resolve rend
  /// null et l'appel est un no-op.
  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

}

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payload,
  });
}
