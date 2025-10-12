import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../shared/models/ritual_model.dart';

/// 🔔 Service de rappels intelligents qui guide le pèlerin comme un vrai accompagnateur
class SmartReminderService {
  final FlutterLocalNotificationsPlugin _notifications;
  
  SmartReminderService(this._notifications);

  /// Configure les rappels intelligents pour un rituel
  Future<void> scheduleSmartReminders(RitualModel ritual) async {
    if (ritual.scheduledTime == null) return;

    await _schedulePreparationReminder(ritual);
    await _scheduleStartReminder(ritual);
    await _scheduleProgressReminder(ritual);
    await _scheduleMissedRitualCheck(ritual);
  }

  /// 📅 Rappel 2 heures avant - Préparation
  Future<void> _schedulePreparationReminder(RitualModel ritual) async {
    final reminderTime = ritual.scheduledTime!.subtract(const Duration(hours: 2));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _getNotificationId(ritual.id, 'prep'),
        title: '🕋 Préparez-vous pour ${ritual.name}',
        body: 'Salam ! Le rituel ${ritual.name} approche dans 2 heures. '
            'Prenez le temps de vous préparer : ablutions, vêtements appropriés, '
            'et revoyez les étapes si nécessaire. Je suis là si vous avez besoin d\'aide !',
        scheduledTime: reminderTime,
        payload: 'ritual:${ritual.id}:preparation',
        priority: Priority.high,
      );
    }
  }

  /// ⏰ Rappel 1 heure avant - Départ imminent
  Future<void> _scheduleStartReminder(RitualModel ritual) async {
    final reminderTime = ritual.scheduledTime!.subtract(const Duration(hours: 1));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _getNotificationId(ritual.id, 'start'),
        title: '⏰ ${ritual.name} dans 1 heure !',
        body: 'Assalamu alaykum ! C\'est bientôt l\'heure de ${ritual.name}. '
            '${_getPreRitualAdvice(ritual)}\n\n'
            'Qu\'Allah accepte vos efforts ! 🤲',
        scheduledTime: reminderTime,
        payload: 'ritual:${ritual.id}:start',
        priority: Priority.max,
        sound: 'gentle_reminder.mp3',
      );
    }
  }

  /// 🎯 Rappel pendant le rituel - Encouragement
  Future<void> _scheduleProgressReminder(RitualModel ritual) async {
    if (ritual.estimatedDuration == null) return;
    
    final midPoint = ritual.scheduledTime!.add(
      Duration(minutes: ritual.estimatedDuration!.inMinutes ~/ 2)
    );
    
    if (midPoint.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _getNotificationId(ritual.id, 'progress'),
        title: '💪 Vous progressez bien !',
        body: 'MashAllah ! Vous êtes à mi-parcours du ${ritual.name}. '
            'Continuez avec concentration et sincérité. '
            'N\'oubliez pas de réciter vos invocations ! 🌟',
        scheduledTime: midPoint,
        payload: 'ritual:${ritual.id}:progress',
        priority: Priority.low,
      );
    }
  }

  /// ⚠️ Vérification si le rituel a été manqué
  Future<void> _scheduleMissedRitualCheck(RitualModel ritual) async {
    if (ritual.estimatedDuration == null) return;
    
    final checkTime = ritual.scheduledTime!.add(
      ritual.estimatedDuration! + const Duration(minutes: 30)
    );
    
    if (checkTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _getNotificationId(ritual.id, 'check'),
        title: '🤔 Avez-vous terminé ${ritual.name} ?',
        body: 'Je voulais vérifier si vous avez pu accomplir le ${ritual.name}. '
            'Si vous l\'avez manqué, ne vous inquiétez pas, je peux vous aider '
            'à trouver des solutions. Appuyez pour plus d\'infos.',
        scheduledTime: checkTime,
        payload: 'ritual:${ritual.id}:missed_check',
        priority: Priority.high,
      );
    }
  }

  /// 🌟 Félicitations après accomplissement
  Future<void> showCompletionCelebration(RitualModel ritual) async {
    await _showImmediateNotification(
      id: _getNotificationId(ritual.id, 'complete'),
      title: '🎉 MashAllah ! Rituel accompli !',
      body: 'Félicitations pour avoir terminé ${ritual.name} ! '
          'Qu\'Allah accepte votre dévotion et facilite le reste de votre Hadj. '
          'Prenez un moment pour vous reposer. Le prochain rituel arrive bientôt ! 💚',
      payload: 'ritual:${ritual.id}:completed',
      priority: Priority.max,
    );
  }

  /// 📍 Rappel basé sur la localisation
  Future<void> showLocationBasedReminder(RitualModel ritual, String locationMessage) async {
    await _showImmediateNotification(
      id: _getNotificationId(ritual.id, 'location'),
      title: '📍 Vous êtes au bon endroit !',
      body: 'Je détecte que vous êtes près du lieu pour ${ritual.name}. '
          '$locationMessage '
          'Voulez-vous commencer maintenant ? 🕋',
      payload: 'ritual:${ritual.id}:location',
      priority: Priority.high,
    );
  }

  /// 🆘 Rappel d'aide
  Future<void> showHelpReminder(RitualModel ritual) async {
    await _showImmediateNotification(
      id: _getNotificationId(ritual.id, 'help'),
      title: '🆘 Besoin d\'aide avec ${ritual.name} ?',
      body: 'Je remarque que vous êtes sur cet écran depuis un moment. '
          'Si vous avez des questions sur ${ritual.name}, je suis là pour vous aider ! '
          'Appuyez pour discuter avec votre guide. 💬',
      payload: 'ritual:${ritual.id}:help_needed',
      priority: Priority.high,
    );
  }

  /// 🌙 Rappel du soir - Bilan de la journée
  Future<void> scheduleDailySummary(DateTime bedtime) async {
    await _scheduleNotification(
      id: 999999,
      title: '🌙 Bilan de votre journée spirituelle',
      body: 'Assalamu alaykum ! Comment s\'est passée votre journée ? '
          'Revoyons ensemble les rituels accomplis et préparons demain. '
          'Bonne nuit et que vos rêves soient bénis ! ✨',
      scheduledTime: bedtime,
      payload: 'daily:summary',
      priority: Priority.low,
    );
  }

  /// 🌅 Rappel du matin - Motivation
  Future<void> scheduleMorningMotivation(DateTime wakeupTime) async {
    await _scheduleNotification(
      id: 999998,
      title: '🌅 Bon matin ! Nouvelle journée bénie',
      body: 'Assalamu alaykum ! Qu\'Allah vous accorde une journée pleine de bénédictions. '
          'Voici le programme des rituels d\'aujourd\'hui. '
          'Je serai avec vous à chaque étape ! 💪',
      scheduledTime: wakeupTime,
      payload: 'daily:morning',
      priority: Priority.high,
    );
  }

  // Helpers privés

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    Priority priority = Priority.defaultPriority,
    String? sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'smart_reminder_channel',
      'Rappels Intelligents',
      channelDescription: 'Notifications intelligentes pour guider votre parcours spirituel',
      importance: _mapPriority(priority),
      priority: _mapAndroidPriority(priority),
      styleInformation: BigTextStyleInformation(body),
      icon: 'ic_notification',
      sound: sound != null ? RawResourceAndroidNotificationSound(sound.split('.').first) : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Priority priority = Priority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'smart_reminder_channel',
      'Rappels Intelligents',
      channelDescription: 'Notifications intelligentes pour guider votre parcours spirituel',
      importance: _mapPriority(priority),
      priority: _mapAndroidPriority(priority),
      styleInformation: BigTextStyleInformation(body),
      icon: 'ic_notification',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  String _getPreRitualAdvice(RitualModel ritual) {
    switch (ritual.name.toLowerCase()) {
      case 'tawaf':
        return 'Assurez-vous d\'avoir vos ablutions, portez des vêtements confortables '
            'et hydratez-vous bien. La foule peut être dense, restez calme.';
      case 'sa\'i':
        return 'Mettez des chaussures confortables, apportez de l\'eau et '
            'préparez vos invocations. Le parcours fait environ 3,5 km.';
      case 'wuquf à arafat':
        return 'C\'est LE jour le plus important du Hadj ! Emportez de l\'eau, '
            'un parasol, et concentrez-vous sur vos invocations toute la journée.';
      default:
        return 'Vérifiez que vous êtes en état de pureté rituelle et '
            'préparez-vous mentalement pour ce moment sacré.';
    }
  }

  int _getNotificationId(String ritualId, String type) {
    // Génère un ID unique basé sur l'ID du rituel et le type
    return '${ritualId}_$type'.hashCode.abs() % 1000000;
  }

  Importance _mapPriority(Priority priority) {
    switch (priority) {
      case Priority.max:
        return Importance.max;
      case Priority.high:
        return Importance.high;
      case Priority.low:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  AndroidNotificationPriority _mapAndroidPriority(Priority priority) {
    switch (priority) {
      case Priority.max:
        return AndroidNotificationPriority.max;
      case Priority.high:
        return AndroidNotificationPriority.high;
      case Priority.low:
        return AndroidNotificationPriority.low;
      default:
        return AndroidNotificationPriority.defaultPriority;
    }
  }

  /// Annuler tous les rappels d'un rituel
  Future<void> cancelRitualReminders(String ritualId) async {
    await _notifications.cancel(_getNotificationId(ritualId, 'prep'));
    await _notifications.cancel(_getNotificationId(ritualId, 'start'));
    await _notifications.cancel(_getNotificationId(ritualId, 'progress'));
    await _notifications.cancel(_getNotificationId(ritualId, 'check'));
  }
}

enum Priority {
  low,
  defaultPriority,
  high,
  max,
}

