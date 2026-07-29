import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';
import 'package:sahabi_guide/core/localization/notification_l10n.dart';
import 'package:sahabi_guide/core/services/notification_service.dart'
    show NotificationIds;
import 'context_service.dart';

/// Service de notifications locales pour le bot Hajj
/// Gère les rappels basés sur GPS, heure, et contexte rituel
///
/// Tous les ids viennent de la plage bot de [NotificationIds] (5000-5999) :
/// les ids fixes utilisés auparavant (1001-1003, 2001, 3001-3002, 4001)
/// tombaient dans les plages rituels et prières, et se marchaient dessus entre
/// eux (Arafat 1001 vs hydratation 1001).
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final ContextService contextService;
  final Logger logger;
  
  bool _initialized = false;

  NotificationService({
    required this.contextService,
    required this.logger,
  }) : _notifications = FlutterLocalNotificationsPlugin();

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      logger.d('Initializing NotificationService...');
      
      // Initialise les timezones
      tz.initializeTimeZones();
      
      // Configuration Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuration iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialise le plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Demande les permissions
      await _requestPermissions();
      
      _initialized = true;
      logger.i('✅ NotificationService initialized');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing notifications: $e', stackTrace: stackTrace);
    }
  }

  /// Demande les permissions de notifications
  Future<bool> _requestPermissions() async {
    try {
      // Android 13+ nécessite une permission explicite
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        logger.d('Android notification permission: $granted');
      }

      // iOS
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        logger.d('iOS notification permission: $granted');
        return granted ?? false;
      }

      return true;
    } catch (e) {
      logger.e('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Callback quand une notification est tapée
  void _onNotificationTapped(NotificationResponse response) {
    logger.d('Notification tapped: ${response.payload}');
    // TODO: Navigation vers le bot ou l'étape spécifique
  }

  /// Planifie une notification immédiate
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      logger.w('NotificationService not initialized');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'hajj_bot_channel',
        'Assistant Hajj',
        channelDescription: 'Notifications de l\'assistant Hajj',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      logger.d('Notification shown: $title');
    } catch (e) {
      logger.e('Error showing notification: $e');
    }
  }

  /// Planifie une notification à une heure précise
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) {
      logger.w('NotificationService not initialized');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'hajj_bot_scheduled',
        'Rappels Hajj',
        channelDescription: 'Rappels programmés pour le Hajj',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      logger.d('Notification scheduled for $scheduledTime: $title');
    } catch (e) {
      logger.e('Error scheduling notification: $e');
    }
  }

  /// Planifie les notifications contextuelles basées sur le lieu actuel
  Future<void> scheduleContextualNotifications() async {
    try {
      final context = await contextService.getCurrentContext();
      
      if (!context.isInHolyPlace) {
        logger.d('Not in holy place, skipping contextual notifications');
        return;
      }

      final place = context.currentLocation;
      final now = DateTime.now();

      // Notifications spécifiques selon le lieu
      switch (place) {
        case 'Arafat':
          await _scheduleArafatNotifications(now);
          break;
        
        case 'Muzdalifah':
          await _scheduleMuzdalifahNotifications(now);
          break;
        
        case 'Mina':
          await _scheduleMinaNotifications(now);
          break;
        
        case 'Masjid al-Haram':
          await _scheduleMasjidNotifications(now);
          break;
      }

      logger.i('✅ Contextual notifications scheduled for $place');
    } catch (e) {
      logger.e('Error scheduling contextual notifications: $e');
    }
  }

  /// Ids fixes des rappels contextuels, tous dans la plage bot.
  static const int _idArafatSunset = NotificationIds.botStart; // 5000
  static const int _idArafatHydration = NotificationIds.botStart + 1; // 5001..
  static const int _idMuzdalifahStones = NotificationIds.botStart + 10;
  static const int _idMuzdalifahFajr = NotificationIds.botStart + 11;
  static const int _idMinaRamy = NotificationIds.botStart + 20;
  static const int _idMinaNight = NotificationIds.botStart + 21;
  static const int _idMasjidTawaf = NotificationIds.botStart + 30;
  static const int _idRitualReminderStart = NotificationIds.botStart + 100;
  static const int _idRitualReminderEnd = NotificationIds.botStart + 600;
  static const int _idUrgentStart = NotificationIds.botStart + 600;
  static const int _idUrgentEnd = NotificationIds.botEnd;

  /// Notifications pour Arafat
  Future<void> _scheduleArafatNotifications(DateTime now) async {
    // Rappel 1 heure avant le coucher du soleil (approximatif: 18h)
    final sunsetReminder = DateTime(now.year, now.month, now.day, 17, 0);
    if (sunsetReminder.isAfter(now)) {
      await scheduleNotification(
        id: _idArafatSunset,
        title: '⚠️ IMPORTANT : Arafat',
        body: 'Le coucher du soleil approche dans 1h. Restez à Arafat et multipliez les invocations !',
        scheduledTime: sunsetReminder,
        payload: 'arafat_sunset_reminder',
      );
    }

    // Rappel hydratation toutes les 2 heures
    for (int i = 1; i <= 3; i++) {
      final hydrationTime = now.add(Duration(hours: i * 2));
      await scheduleNotification(
        id: _idArafatHydration + i - 1,
        title: '💧 Hydratation',
        body: 'N\'oubliez pas de boire de l\'eau régulièrement sous cette chaleur.',
        scheduledTime: hydrationTime,
        payload: 'hydration_reminder',
      );
    }
  }

  /// Notifications pour Muzdalifah
  Future<void> _scheduleMuzdalifahNotifications(DateTime now) async {
    // Rappel collecte de cailloux
    final stonesReminder = now.add(const Duration(minutes: 30));
    await scheduleNotification(
      id: _idMuzdalifahStones,
      title: '🪨 Muzdalifah : Collecte de cailloux',
      body: 'N\'oubliez pas de collecter 49 cailloux (taille pois chiche) pour le Ramy.',
      scheduledTime: stonesReminder,
      payload: 'muzdalifah_stones',
    );

    // Rappel Fajr (approximatif: 5h30)
    final fajrTime = DateTime(now.year, now.month, now.day + 1, 5, 30);
    if (fajrTime.isAfter(now)) {
      await scheduleNotification(
        id: _idMuzdalifahFajr,
        title: '🌅 Prière du Fajr',
        body: 'Il est l\'heure de la prière du Fajr. Après la prière, vous pourrez partir vers Mina.',
        scheduledTime: fajrTime,
        payload: 'muzdalifah_fajr',
      );
    }
  }

  /// Notifications pour Mina
  Future<void> _scheduleMinaNotifications(DateTime now) async {
    // Rappel Ramy après Dhuhr (approximatif: 13h)
    final dhuhrTime = DateTime(now.year, now.month, now.day, 13, 0);
    if (dhuhrTime.isAfter(now)) {
      await scheduleNotification(
        id: _idMinaRamy,
        title: '🎯 Mina : Lapidation',
        body: 'C\'est l\'heure de lapider les Jamarat. Commencez après la prière du Dhuhr.',
        scheduledTime: dhuhrTime,
        payload: 'mina_ramy',
      );
    }

    // Rappel rester la nuit
    final nightReminder = DateTime(now.year, now.month, now.day, 20, 0);
    if (nightReminder.isAfter(now)) {
      await scheduleNotification(
        id: _idMinaNight,
        title: '⛺ Mina : Nuit',
        body: 'N\'oubliez pas : vous devez passer la nuit à Mina pendant les jours de Tashriq.',
        scheduledTime: nightReminder,
        payload: 'mina_night',
      );
    }
  }

  /// Notifications pour Masjid al-Haram
  Future<void> _scheduleMasjidNotifications(DateTime now) async {
    // Rappel Tawaf
    final tawafReminder = now.add(const Duration(hours: 1));
    await scheduleNotification(
      id: _idMasjidTawaf,
      title: '🕋 Masjid al-Haram',
      body: 'Profitez de votre présence dans le lieu le plus sacré pour accomplir le Tawaf.',
      scheduledTime: tawafReminder,
      payload: 'masjid_tawaf',
    );
  }

  /// Planifie un rappel après la durée estimée d'un rituel
  Future<void> scheduleRitualReminder({
    required String stepName,
    required int delayMinutes,
    required String message,
  }) async {
    if (!_initialized) {
      logger.w('NotificationService not initialized, cannot schedule ritual reminder');
      return;
    }

    try {
      final l10n = await NotificationL10n.load();
      final scheduledTime = DateTime.now().add(Duration(minutes: delayMinutes));
      await scheduleNotification(
        // Id dérivé de l'étape : re-planifier le même rappel le remplace au
        // lieu d'en empiler un par appel (l'horodatage donnait un id neuf à
        // chaque fois, hors de toute plage).
        id: NotificationIds.stableId(
          'bot_ritual:$stepName',
          start: _idRitualReminderStart,
          end: _idRitualReminderEnd,
        ),
        title: '🕋 ${l10n.notif_ritual_step_reminder_title(stepName)}',
        body: message,
        scheduledTime: scheduledTime,
        payload: 'ritual_reminder:$stepName',
      );
      logger.d('Ritual reminder scheduled for $stepName in $delayMinutes minutes');
    } catch (e) {
      logger.e('Error scheduling ritual reminder: $e');
    }
  }

  /// Envoie un rappel urgent immédiat
  Future<void> sendUrgentReminder({
    required String title,
    required String message,
    String? stepId,
  }) async {
    await showNotification(
      id: NotificationIds.stableId(
        'bot_urgent:${stepId ?? title}',
        start: _idUrgentStart,
        end: _idUrgentEnd,
      ),
      title: title,
      body: message,
      payload: stepId,
    );
  }

  /// Annule les notifications DU BOT (plage 5000-5999). Un `cancelAll()`
  /// emportait aussi les prières, la dua du jour et les rappels de rituels,
  /// que ce service ne re-planifie jamais.
  Future<void> cancelAllNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= NotificationIds.botStart &&
            request.id < NotificationIds.botEnd) {
          await _notifications.cancel(request.id);
        }
      }
      logger.d('Bot notifications cancelled');
    } catch (e) {
      logger.e('Error cancelling notifications: $e');
    }
  }

  /// Annule une notification spécifique
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      logger.d('Notification $id cancelled');
    } catch (e) {
      logger.e('Error cancelling notification $id: $e');
    }
  }

  /// Récupère les notifications en attente
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      logger.e('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Dispose
  void dispose() {
    logger.d('NotificationService disposed');
  }
}

