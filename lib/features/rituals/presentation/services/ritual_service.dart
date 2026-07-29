import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/localization/notification_l10n.dart';
import '../../../../core/services/notification_service.dart' show NotificationIds;
import '../../../../core/utils/app_logger.dart';

String _normalizeLanguage(String? code) {
  if (code == null || code.isEmpty) return 'en';
  final lower = code.toLowerCase();
  if (lower.startsWith('en') || lower.contains('english')) return 'en';
  if (lower.startsWith('fr') || lower.contains('franc')) return 'fr';
  if (lower.startsWith('ar') || lower.contains('arab')) return 'ar';
  if (lower.startsWith('ha') || lower.contains('hausa')) return 'ha';
  if (lower == 'za' ||
      lower == 'zr' ||
      lower == 'dje' ||
      lower.contains('zarma') ||
      lower.contains('djerma')) {
    return 'dje';
  }
  return lower;
}

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
      final normalizedLanguage = _normalizeLanguage(language);
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

  Future<void> playVideo(String videoUrl) async {
    final uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  // TODO(consolidation) : ce planificateur double celui de
  // `core/services/notification_service.dart` (canaux et textes distincts pour
  // le même besoin). Tant que la fusion n'est pas faite, il DOIT rester dans la
  // plage d'ids « rituels » de [NotificationIds] et ne jamais annuler au-delà.
  Future<void> _scheduleNextRitualNotification(RitualModel ritual) async {
    try {
      // Planifier une notification 1h après pour enchaîner sur le rituel suivant
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(hours: 1));

      if (notificationTime.isAfter(now)) {
        final l10n = await NotificationL10n.load();
        await _notifications.zonedSchedule(
          NotificationIds.ritualReminder(ritual.order),
          l10n.notif_ritual_reminder_title,
          l10n.notif_ritual_start_body(ritual.name),
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
      AppLogger.error('Erreur lors de la planification de notification', error: e);
    }
  }

  Future<void> scheduleRitualNotifications(List<RitualModel> rituals) async {
    // N'annule QUE les rappels de rituels : un `cancelAll()` effaçait aussi les
    // prières quotidiennes et la dua du jour, jamais re-planifiées ici.
    await _cancelRitualRange();

    final l10n = await NotificationL10n.load();
    for (final ritual in rituals) {
      if (ritual.scheduledTime != null &&
          ritual.status != RitualStatus.completed) {
        await _scheduleRitualNotification(ritual, l10n);
      }
    }
  }

  Future<void> _cancelRitualRange() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= NotificationIds.ritualMainStart &&
            request.id < NotificationIds.ritualOverdueEnd) {
          await _notifications.cancel(request.id);
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'annulation des rappels de rituels',
          error: e);
    }
  }

  Future<void> _scheduleRitualNotification(
      RitualModel ritual, AppLocalizations l10n) async {
    try {
      final scheduledTime =
          ritual.scheduledTime!.subtract(const Duration(hours: 1));
      if (scheduledTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          NotificationIds.ritualMain(ritual.order),
          l10n.notif_ritual_reminder_title,
          l10n.notif_ritual_start_body(ritual.name),
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
      AppLogger.error('Erreur lors de la planification de notification', error: e);
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
