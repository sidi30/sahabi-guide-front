import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../shared/models/ritual_model.dart';
import '../../shared/models/dua_model.dart';
import '../../l10n/app_localizations.dart';
import '../localization/notification_l10n.dart';
import '../utils/app_logger.dart';
import 'prayer_times_service.dart';

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

    _isInitialized = true;
    notifyListeners();
  }

  /// Devine la tz IANA à partir de l'offset DateTime local. Pas de plugin natif
  /// requis (évite SSL block sur dl.google.com pour `flutter_timezone`).
  /// Précision suffisante pour notifications quotidiennes — l'utilisateur Hajj
  /// est généralement Asia/Riyadh (UTC+3) ou Europe/Paris (UTC+1).
  tz.Location _guessLocalLocation() {
    final offsetHours = DateTime.now().timeZoneOffset.inMinutes / 60.0;
    String name;
    if (offsetHours == 3) {
      name = 'Asia/Riyadh';
    } else if (offsetHours == 1 || offsetHours == 2) {
      name = 'Europe/Paris';
    } else if (offsetHours == 0) {
      name = 'UTC';
    } else if (offsetHours == -5 || offsetHours == -4) {
      name = 'America/New_York';
    } else if (offsetHours == 5.5) {
      name = 'Asia/Kolkata';
    } else if (offsetHours == 8) {
      name = 'Asia/Singapore';
    } else {
      name = 'UTC';
    }
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.UTC;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to specific ritual or dua
      AppLogger.debug('Notification tapped: $payload');
    }
  }

  // ====================== PRAYER NOTIFICATIONS ======================

  /// Schedule daily prayer reminders. Cancels previously scheduled
  /// prayer notifications (id range 3000-3099) before scheduling.
  /// Each prayer becomes a daily recurring notification at its time.
  Future<void> schedulePrayerNotifications(DailyPrayerSchedule schedule) async {
    // Localise dans la langue persistée (source : languageProvider).
    final l10n = await NotificationL10n.load();

    // Cancel existing prayer notifs first
    for (int id = 3000; id < 3100; id++) {
      await _notifications.cancel(id);
    }

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
    int id = 3000;
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

  // Schedule ritual notifications
  Future<void> scheduleRitualNotifications(List<RitualModel> rituals) async {
    final l10n = await NotificationL10n.load();
    await _clearAllNotifications();

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
      id: ritual.order,
      title: l10n.notif_ritual_title,
      body: l10n.notif_ritual_start_body(ritual.name),
      scheduledTime: scheduledTime,
      payload: 'ritual:${ritual.id}',
    );

    // Schedule reminder 30 minutes before
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: ritual.order + 1000, // Different ID for reminder
        title: l10n.notif_ritual_reminder_title,
        body: l10n.notif_ritual_reminder_body(ritual.name),
        scheduledTime: reminderTime,
        payload: 'ritual_reminder:${ritual.id}',
      );
    }

    // Schedule overdue notification 1 hour after scheduled time
    final overdueTime = scheduledTime.add(const Duration(hours: 1));
    await _scheduleNotification(
      id: ritual.order + 2000, // Different ID for overdue
      title: l10n.notif_ritual_overdue_title,
      body: l10n.notif_ritual_overdue_body(ritual.name),
      scheduledTime: overdueTime,
      payload: 'ritual_overdue:${ritual.id}',
    );
  }

  // Schedule dua notifications
  Future<void> scheduleDuaNotifications(List<DuaModel> duas) async {
    final l10n = await NotificationL10n.load();
    for (final dua in duas) {
      if (dua.type == DuaType.daily && dua.isActive) {
        await _scheduleDailyDuaNotification(dua, l10n);
      }
    }
  }

  Future<void> _scheduleDailyDuaNotification(
      DuaModel dua, AppLocalizations l10n) async {
    // Schedule for morning (6 AM) and evening (6 PM)
    final now = DateTime.now();

    // Morning notification
    final morningTime = DateTime(now.year, now.month, now.day, 6, 0);
    if (morningTime.isAfter(now)) {
      await _scheduleNotification(
        id: dua.hashCode,
        title: l10n.notif_dua_morning_title,
        body: l10n.notif_dua_body(dua.title),
        scheduledTime: morningTime,
        payload: 'dua:${dua.id}',
      );
    }

    // Evening notification
    final eveningTime = DateTime(now.year, now.month, now.day, 18, 0);
    if (eveningTime.isAfter(now)) {
      await _scheduleNotification(
        id: dua.hashCode + 1,
        title: l10n.notif_dua_evening_title,
        body: l10n.notif_dua_body(dua.title),
        scheduledTime: eveningTime,
        payload: 'dua:${dua.id}',
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
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
      matchDateTimeComponents: DateTimeComponents.time,
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
      id: ritual.order,
      title: l10n.notif_ritual_active_title,
      body: l10n.notif_ritual_active_body(ritual.name),
      payload: 'ritual_active:${ritual.id}',
    );
  }

  Future<void> showDuaReminder(DuaModel dua) async {
    final l10n = await NotificationL10n.load();
    await _showNotification(
      id: dua.hashCode,
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

  Future<void> _clearAllNotifications() async {
    await _notifications.cancelAll();
    _scheduledNotifications.clear();
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
