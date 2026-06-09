import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../../core/di/injection_container.dart';
import '../../data/models/user_settings_model.dart';
import '../../domain/usecases/update_notification_settings_usecase.dart';

// Modèle de données
class NotificationSettings {
  final bool allEnabled;
  final bool pushEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool emergencyAlerts;
  final bool prayerReminders;
  final bool ritualReminders;
  final bool groupMessages;
  final bool healthAlerts;
  final bool appUpdates;
  final bool doNotDisturb;

  const NotificationSettings({
    this.allEnabled = true,
    this.pushEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.emergencyAlerts = true,
    this.prayerReminders = true,
    this.ritualReminders = true,
    this.groupMessages = true,
    this.healthAlerts = true,
    this.appUpdates = true,
    this.doNotDisturb = false,
  });

  NotificationSettings copyWith({
    bool? allEnabled,
    bool? pushEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? emergencyAlerts,
    bool? prayerReminders,
    bool? ritualReminders,
    bool? groupMessages,
    bool? healthAlerts,
    bool? appUpdates,
    bool? doNotDisturb,
  }) {
    return NotificationSettings(
      allEnabled: allEnabled ?? this.allEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      ritualReminders: ritualReminders ?? this.ritualReminders,
      groupMessages: groupMessages ?? this.groupMessages,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      appUpdates: appUpdates ?? this.appUpdates,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allEnabled': allEnabled,
      'pushEnabled': pushEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'emergencyAlerts': emergencyAlerts,
      'prayerReminders': prayerReminders,
      'ritualReminders': ritualReminders,
      'groupMessages': groupMessages,
      'healthAlerts': healthAlerts,
      'appUpdates': appUpdates,
      'doNotDisturb': doNotDisturb,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      allEnabled: json['allEnabled'] ?? true,
      pushEnabled: json['pushEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      emergencyAlerts: json['emergencyAlerts'] ?? true,
      prayerReminders: json['prayerReminders'] ?? true,
      ritualReminders: json['ritualReminders'] ?? true,
      groupMessages: json['groupMessages'] ?? true,
      healthAlerts: json['healthAlerts'] ?? true,
      appUpdates: json['appUpdates'] ?? true,
      doNotDisturb: json['doNotDisturb'] ?? false,
    );
  }
}

// Notifier
class NotificationsSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  static const String _storageKey = 'notification_settings';
  Timer? _debounceTimer;

  NotificationsSettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = sl<SharedPreferences>();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final json = Map<String, dynamic>.from(
          const NotificationSettings().toJson()
        );
        // Charger depuis les préférences
        json.forEach((key, value) {
          final prefValue = prefs.getBool('notif_$key');
          if (prefValue != null) {
            json[key] = prefValue;
          }
        });
        state = AsyncValue.data(NotificationSettings.fromJson(json));
      } else {
        state = const AsyncValue.data(NotificationSettings());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _saveSettings(NotificationSettings settings) async {
    try {
      final prefs = sl<SharedPreferences>();
      final json = settings.toJson();
      
      // Sauvegarder chaque paramètre individuellement
      for (var entry in json.entries) {
        await prefs.setBool('notif_${entry.key}', entry.value as bool);
      }
      // Marquer la présence de réglages sauvegardés pour que _loadSettings
      // les recharge au lieu de retomber sur les valeurs par défaut.
      await prefs.setString(_storageKey, '1');

      state = AsyncValue.data(settings);

      // Déclencher la synchronisation backend avec un léger debounce
      _scheduleBackendSync(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _scheduleBackendSync(NotificationSettings settings) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final usecase = sl<UpdateNotificationSettingsUseCase>();
        final payload = _mapToUserSettingsModel(settings);
        await usecase(payload);
      } catch (e) {
        // On reste silencieux côté UI; l'état local est conservé et on réessaiera
      }
    });
  }

  UserSettingsModel _mapToUserSettingsModel(NotificationSettings s) {
    return UserSettingsModel(
      allNotificationsEnabled: s.allEnabled,
      pushNotificationsEnabled: s.pushEnabled,
      soundEnabled: s.soundEnabled,
      vibrationEnabled: s.vibrationEnabled,
      emergencyAlerts: s.emergencyAlerts,
      prayerReminders: s.prayerReminders,
      ritualReminders: s.ritualReminders,
      groupMessages: s.groupMessages,
      healthAlerts: s.healthAlerts,
      appUpdates: s.appUpdates,
      doNotDisturb: s.doNotDisturb,
    );
  }

  Future<void> toggleAllNotifications(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = NotificationSettings(
      allEnabled: value,
      pushEnabled: value,
      soundEnabled: value,
      vibrationEnabled: value,
      emergencyAlerts: value,
      prayerReminders: value,
      ritualReminders: value,
      groupMessages: value,
      healthAlerts: value,
      appUpdates: value,
      doNotDisturb: currentSettings.doNotDisturb,
    );

    await _saveSettings(newSettings);
  }

  Future<void> togglePushNotifications(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(pushEnabled: value));
  }

  Future<void> toggleSound(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(soundEnabled: value));
  }

  Future<void> toggleVibration(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(vibrationEnabled: value));
  }

  Future<void> toggleEmergencyAlerts(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(emergencyAlerts: value));
  }

  Future<void> togglePrayerReminders(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(prayerReminders: value));
  }

  Future<void> toggleRitualReminders(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(ritualReminders: value));
  }

  Future<void> toggleGroupMessages(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(groupMessages: value));
  }

  Future<void> toggleHealthAlerts(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(healthAlerts: value));
  }

  Future<void> toggleAppUpdates(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(appUpdates: value));
  }

  Future<void> toggleDoNotDisturb(bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    await _saveSettings(currentSettings.copyWith(doNotDisturb: value));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Provider
final notificationsSettingsProvider =
    StateNotifierProvider<NotificationsSettingsNotifier, AsyncValue<NotificationSettings>>(
  (ref) => NotificationsSettingsNotifier(),
);




