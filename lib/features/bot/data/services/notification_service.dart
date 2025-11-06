import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';
import 'context_service.dart';

/// Service de notifications locales pour le bot Hajj
/// Gère les rappels basés sur GPS, heure, et contexte rituel
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

  /// Notifications pour Arafat
  Future<void> _scheduleArafatNotifications(DateTime now) async {
    // Rappel 1 heure avant le coucher du soleil (approximatif: 18h)
    final sunsetReminder = DateTime(now.year, now.month, now.day, 17, 0);
    if (sunsetReminder.isAfter(now)) {
      await scheduleNotification(
        id: 1001,
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
        id: 1000 + i,
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
      id: 2001,
      title: '🪨 Muzdalifah : Collecte de cailloux',
      body: 'N\'oubliez pas de collecter 49 cailloux (taille pois chiche) pour le Ramy.',
      scheduledTime: stonesReminder,
      payload: 'muzdalifah_stones',
    );

    // Rappel Fajr (approximatif: 5h30)
    final fajrTime = DateTime(now.year, now.month, now.day + 1, 5, 30);
    if (fajrTime.isAfter(now)) {
      await scheduleNotification(
        id: 2002,
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
        id: 3001,
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
        id: 3002,
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
      id: 4001,
      title: '🕋 Masjid al-Haram',
      body: 'Profitez de votre présence dans le lieu le plus sacré pour accomplir le Tawaf.',
      scheduledTime: tawafReminder,
      payload: 'masjid_tawaf',
    );
  }

  /// Envoie un rappel urgent immédiat
  Future<void> sendUrgentReminder({
    required String title,
    required String message,
    String? stepId,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: message,
      payload: stepId,
    );
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      logger.d('All notifications cancelled');
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

