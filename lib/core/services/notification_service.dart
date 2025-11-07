import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../shared/models/ritual_model.dart';
import '../../shared/models/dua_model.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final List<ScheduledNotification> _scheduledNotifications = [];

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

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

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to specific ritual or dua
      debugPrint('Notification tapped: $payload');
    }
  }

  // Schedule ritual notifications
  Future<void> scheduleRitualNotifications(List<RitualModel> rituals) async {
    await _clearAllNotifications();

    for (final ritual in rituals) {
      if (ritual.scheduledTime != null && ritual.status != RitualStatus.completed) {
        await _scheduleRitualNotification(ritual);
      }
    }
  }

  Future<void> _scheduleRitualNotification(RitualModel ritual) async {
    final scheduledTime = ritual.scheduledTime!;
    
    // Schedule main notification
    await _scheduleNotification(
      id: ritual.order,
      title: 'Rituel du Hadj',
      body: 'Il est temps de commencer: ${ritual.name}',
      scheduledTime: scheduledTime,
      payload: 'ritual:${ritual.id}',
    );

    // Schedule reminder 30 minutes before
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: ritual.order + 1000, // Different ID for reminder
        title: 'Rappel - Rituel du Hadj',
        body: 'Préparez-vous pour: ${ritual.name} dans 30 minutes',
        scheduledTime: reminderTime,
        payload: 'ritual_reminder:${ritual.id}',
      );
    }

    // Schedule overdue notification 1 hour after scheduled time
    final overdueTime = scheduledTime.add(const Duration(hours: 1));
    await _scheduleNotification(
      id: ritual.order + 2000, // Different ID for overdue
      title: 'Rituel en retard',
      body: 'Vous avez manqué: ${ritual.name}. Marquez-le comme terminé si effectué.',
      scheduledTime: overdueTime,
      payload: 'ritual_overdue:${ritual.id}',
    );
  }

  // Schedule dua notifications
  Future<void> scheduleDuaNotifications(List<DuaModel> duas) async {
    for (final dua in duas) {
      if (dua.type == DuaType.daily && dua.isActive) {
        await _scheduleDailyDuaNotification(dua);
      }
    }
  }

  Future<void> _scheduleDailyDuaNotification(DuaModel dua) async {
    // Schedule for morning (6 AM) and evening (6 PM)
    final now = DateTime.now();
    
    // Morning notification
    final morningTime = DateTime(now.year, now.month, now.day, 6, 0);
    if (morningTime.isAfter(now)) {
      await _scheduleNotification(
        id: dua.hashCode,
        title: 'Doua du matin',
        body: 'N\'oubliez pas de réciter: ${dua.title}',
        scheduledTime: morningTime,
        payload: 'dua:${dua.id}',
      );
    }

    // Evening notification
    final eveningTime = DateTime(now.year, now.month, now.day, 18, 0);
    if (eveningTime.isAfter(now)) {
      await _scheduleNotification(
        id: dua.hashCode + 1,
        title: 'Doua du soir',
        body: 'N\'oubliez pas de réciter: ${dua.title}',
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
    await _showNotification(
      id: ritual.order,
      title: 'Rituel actif',
      body: 'Vous êtes en train d\'effectuer: ${ritual.name}',
      payload: 'ritual_active:${ritual.id}',
    );
  }

  Future<void> showDuaReminder(DuaModel dua) async {
    await _showNotification(
      id: dua.hashCode,
      title: 'Doua recommandée',
      body: 'Récitez maintenant: ${dua.title}',
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
