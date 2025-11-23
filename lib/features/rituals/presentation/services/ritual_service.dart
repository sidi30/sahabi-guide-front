import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/utils/language_utils.dart';

class RitualService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  RitualModel? _currentPlayingRitual;
  bool _isInitialized = false;

  RitualModel? get currentPlayingRitual => _currentPlayingRitual;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> playAudio(RitualModel ritual, String language) async {
    try {
      final normalizedLanguage = LanguageUtils.normalize(language);
      final audioPath = ritual.getAudioPath(normalizedLanguage);
      if (audioPath != null && audioPath.isNotEmpty) {
        _currentPlayingRitual = ritual;
        await _setSource(audioPath);
        await _audioPlayer.play();
        notifyListeners();
      } else {
        throw Exception('Aucun fichier audio disponible pour cette langue');
      }
    } catch (e) {
      throw Exception('Erreur lors de la lecture audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _currentPlayingRitual = null;
    notifyListeners();
  }

  Future<void> playVideo(RitualModel ritual) async {
    // TODO: Implémenter la lecture vidéo
    throw Exception('Fonctionnalité vidéo à venir');
  }

  Future<void> markAsCompleted(RitualModel ritual) async {
    try {
      // TODO: Mettre à jour via l'API
      // Pour l'instant, on simule la mise à jour locale

      // Planifier une notification pour le prochain rituel
      await _scheduleNextRitualNotification(ritual);

      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  Future<void> _scheduleNextRitualNotification(RitualModel ritual) async {
    try {
      // Planifier une notification 1h avant le prochain rituel
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(hours: 1));

      if (notificationTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          ritual.order,
          'Rappel Rituel',
          'Préparez-vous pour: ${ritual.name}',
          tz.TZDateTime.from(notificationTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'ritual_channel',
              'Rituels du Hadj',
              channelDescription: 'Notifications pour les rituels du Hadj',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'ritual_${ritual.id}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la planification de notification: $e');
    }
  }

  Future<void> scheduleRitualNotifications(List<RitualModel> rituals) async {
    await _notifications.cancelAll();

    for (final ritual in rituals) {
      if (ritual.scheduledTime != null &&
          ritual.status != RitualStatus.completed) {
        await _scheduleRitualNotification(ritual);
      }
    }
  }

  Future<void> _scheduleRitualNotification(RitualModel ritual) async {
    try {
      final scheduledTime =
          ritual.scheduledTime!.subtract(const Duration(hours: 1));
      if (scheduledTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          ritual.order,
          'Rappel Rituel: ${ritual.name}',
          'Préparez-vous pour ${ritual.name} dans 1 heure.',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'ritual_channel',
              'Rituels du Hadj',
              channelDescription: 'Notifications pour les rituels du Hadj',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'ritual_${ritual.id}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la planification de notification: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _setSource(String path) async {
    final source = path.trim();
    if (source.startsWith('http')) {
      await _audioPlayer.setUrl(source);
    } else if (source.startsWith('gs://')) {
      await _audioPlayer.setUrl(_convertGsToHttps(source));
    } else {
      await _audioPlayer.setAsset(source);
    }
  }

  String _convertGsToHttps(String gsPath) {
    final sanitized = gsPath.replaceFirst('gs://', '');
    final parts = sanitized.split('/');
    final bucket = parts.first;
    final objectPath = parts.skip(1).join('/');
    return 'https://storage.googleapis.com/$bucket/$objectPath';
  }
}
