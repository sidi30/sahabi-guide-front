import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const prayerChannel = AndroidNotificationChannel(
      AppConstants.prayerNotificationChannel,
      'Prayer Notifications',
      description: 'Notifications for prayer times',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    const generalChannel = AndroidNotificationChannel(
      AppConstants.generalNotificationChannel,
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(prayerChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Handle notification tap
  }

  Future<void> showPrayerNotification({
    required String prayerName,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.prayerNotificationChannel,
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'adhan.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      prayerName.hashCode,
      'Temps de prière - $prayerName',
      message,
      notificationDetails,
      payload: 'prayer_$prayerName',
    );
  }

  Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.generalNotificationChannel,
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required String message,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.prayerNotificationChannel,
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'adhan.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: schedule method is deprecated in newer versions
    // For production, use zonedSchedule with timezone package
    try {
      await _notifications.show(
        id,
        'Temps de prière - $prayerName',
        message,
        notificationDetails,
        payload: 'prayer_$prayerName',
      );
    } catch (e) {
      // Fallback for older versions or handle scheduling differently
      print('Notification scheduling error: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Use areNotificationsEnabled instead of requestPermission
      try {
        final bool? enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      } catch (e) {
        print('Android permission check error: $e');
        return false;
      }
    }

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      try {
        return await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      } catch (e) {
        print('iOS permission request error: $e');
        return false;
      }
    }

    return false;
  }
}
