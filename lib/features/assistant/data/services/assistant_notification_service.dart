import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/conversation_step_model.dart';

class AssistantNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final Logger logger;

  AssistantNotificationService({
    required FlutterLocalNotificationsPlugin notifications,
    required this.logger,
  }) : _notifications = notifications;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    try {
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

      logger.d('Assistant notification service initialized');
    } catch (e) {
      logger.e('Error initializing notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    logger.d('Notification tapped: ${response.payload}');
    // TODO: Navigation vers l'assistant
  }

  /// Demande les permissions de notification
  Future<bool> requestPermissions() async {
    try {
      final androidImpl = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final iosImpl = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }

      if (iosImpl != null) {
        await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return true;
    } catch (e) {
      logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  /// Envoie une notification immédiate
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'assistant_channel',
        'Assistant',
        channelDescription: 'Notifications de l\'assistant conversationnel',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      logger.d('Notification shown: $title');
    } catch (e) {
      logger.e('Error showing notification: $e');
    }
  }

  /// Programme une notification pour plus tard
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'assistant_channel',
        'Assistant',
        channelDescription: 'Rappels de l\'assistant',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      logger.d('Notification scheduled for: $scheduledDate');
    } catch (e) {
      logger.e('Error scheduling notification: $e');
    }
  }

  /// Programme un rappel pour une étape
  Future<void> scheduleStepReminder({
    required ConversationStepModel step,
    required DateTime lastAnswered,
  }) async {
    if (step.reminderAfterHours == null) return;

    final reminderTime = lastAnswered.add(
      Duration(hours: step.reminderAfterHours!),
    );

    // Ne programme pas si la date est dans le passé
    if (reminderTime.isBefore(DateTime.now())) return;

    await scheduleNotification(
      id: step.stepCode.hashCode,
      title: '📝 Rappel de l\'assistant',
      body: 'N\'oubliez pas de répondre : ${step.question}',
      scheduledDate: reminderTime,
      payload: 'step:${step.stepCode}',
    );
  }

  /// Envoie une notification pour une étape en attente
  Future<void> notifyPendingStep(ConversationStepModel step) async {
    await showNotification(
      id: step.stepCode.hashCode,
      title: '✨ Question de l\'assistant',
      body: step.question,
      payload: 'step:${step.stepCode}',
    );
  }

  /// Envoie une notification de bienvenue
  Future<void> showWelcomeNotification() async {
    await showNotification(
      id: 1000,
      title: '👋 Bienvenue !',
      body: 'Votre assistant personnel est prêt à vous guider.',
      payload: 'welcome',
    );
  }

  /// Envoie une notification de félicitations
  Future<void> showCompletionNotification() async {
    await showNotification(
      id: 1001,
      title: '🎉 Félicitations !',
      body: 'Vous avez terminé toutes les étapes !',
      payload: 'completed',
    );
  }

  /// Annule une notification programmée
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      logger.d('Notification cancelled: $id');
    } catch (e) {
      logger.e('Error cancelling notification: $e');
    }
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      logger.d('All notifications cancelled');
    } catch (e) {
      logger.e('Error cancelling all notifications: $e');
    }
  }
}

