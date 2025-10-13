class UserSettingsModel {
  final String? id;
  final String? userId;
  
  // Notifications générales
  final bool allNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  // Types de notifications
  final bool emergencyAlerts;
  final bool prayerReminders;
  final bool ritualReminders;
  final bool groupMessages;
  final bool healthAlerts;
  final bool appUpdates;
  final bool doNotDisturb;
  
  // Préférences UI
  final String themeMode;  // SYSTEM, LIGHT, DARK
  final String appLocale;  // fr, ar, en
  final String audioLanguage;  // HAUSA, ZARMA
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserSettingsModel({
    this.id,
    this.userId,
    this.allNotificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.emergencyAlerts = true,
    this.prayerReminders = true,
    this.ritualReminders = true,
    this.groupMessages = true,
    this.healthAlerts = true,
    this.appUpdates = true,
    this.doNotDisturb = false,
    this.themeMode = 'SYSTEM',
    this.appLocale = 'fr',
    this.audioLanguage = 'HAUSA',
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      allNotificationsEnabled: json['allNotificationsEnabled'] ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      emergencyAlerts: json['emergencyAlerts'] ?? true,
      prayerReminders: json['prayerReminders'] ?? true,
      ritualReminders: json['ritualReminders'] ?? true,
      groupMessages: json['groupMessages'] ?? true,
      healthAlerts: json['healthAlerts'] ?? true,
      appUpdates: json['appUpdates'] ?? true,
      doNotDisturb: json['doNotDisturb'] ?? false,
      themeMode: json['themeMode']?.toString() ?? 'SYSTEM',
      appLocale: json['appLocale']?.toString() ?? 'fr',
      audioLanguage: json['audioLanguage']?.toString() ?? 'HAUSA',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'allNotificationsEnabled': allNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'emergencyAlerts': emergencyAlerts,
      'prayerReminders': prayerReminders,
      'ritualReminders': ritualReminders,
      'groupMessages': groupMessages,
      'healthAlerts': healthAlerts,
      'appUpdates': appUpdates,
      'doNotDisturb': doNotDisturb,
      'themeMode': themeMode,
      'appLocale': appLocale,
      'audioLanguage': audioLanguage,
    };
  }

  UserSettingsModel copyWith({
    String? id,
    String? userId,
    bool? allNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? emergencyAlerts,
    bool? prayerReminders,
    bool? ritualReminders,
    bool? groupMessages,
    bool? healthAlerts,
    bool? appUpdates,
    bool? doNotDisturb,
    String? themeMode,
    String? appLocale,
    String? audioLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      allNotificationsEnabled: allNotificationsEnabled ?? this.allNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      ritualReminders: ritualReminders ?? this.ritualReminders,
      groupMessages: groupMessages ?? this.groupMessages,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      appUpdates: appUpdates ?? this.appUpdates,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      themeMode: themeMode ?? this.themeMode,
      appLocale: appLocale ?? this.appLocale,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettingsModel(id: $id, allNotificationsEnabled: $allNotificationsEnabled, '
        'themeMode: $themeMode, appLocale: $appLocale)';
  }
}


