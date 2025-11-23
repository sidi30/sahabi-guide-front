import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // App Info
  static const String appName = 'Sahabi Guide';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Votre compagnon spirituel pour le Hajj et la Omra';
  
  // API Constants
  // Production URL
  static const String _apiBaseUrlProduction = 'https://sahabi-backend-gcobrlag7q-ew.a.run.app';
  // Pour émulateur Android: utiliser 10.0.2.2 au lieu de localhost
  // Pour téléphone physique: utiliser l'IP locale de votre PC (ex: http://192.168.1.X:8084)
  // Pour Web: utiliser localhost
  static const String _apiBaseUrlAndroid = 'http://10.0.2.2:8084';
  static const String _apiBaseUrlWeb = 'http://localhost:8084';
  
  /// Retourne l'URL de l'API selon la plateforme
  /// En production, utilise l'URL de production
  static String get apiBaseUrl {
    // Vérifier si on est en mode production via variable d'environnement
    const isProd = bool.fromEnvironment('PRODUCTION', defaultValue: false);
    if (isProd) {
      return _apiBaseUrlProduction;
    }
    // Sinon, utiliser l'URL selon la plateforme
    return kIsWeb ? _apiBaseUrlWeb : _apiBaseUrlAndroid;
  }
  
  static const int apiTimeout = 30000;
  static const String apiHealthPath = '/health';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String passportNoKey = 'passport_no';
  static const String userProfileKey = 'user_profile';
  static const String medicalProfileKey = 'medical_profile';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  
  // Route Names
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String ritualsRoute = '/rituals';
  static const String duasRoute = '/duas';
  static const String mapRoute = '/map';
  static const String healthRoute = '/health';
  static const String profileRoute = '/profile';
  static const String connectivityRoute = '/connectivity';
  
  // Audio Constants
  static const String audioBasePath = 'assets/audio/';
  static const String duasAudioPath = '${audioBasePath}duas/';
  static const String ritualsAudioPath = '${audioBasePath}rituals/';
  
  // Image Constants
  static const String imageBasePath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  
  // Prayer Times
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha'
  ];
  
  // Languages
  static const Map<String, String> supportedLanguages = {
    'fr': 'Français',
    'en': 'English',
    'ha': 'Hausa',
    'dje': 'Djerma',
  };
  
  // Default Values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Notification Channels
  static const String prayerNotificationChannel = 'prayer_notifications';
  static const String generalNotificationChannel = 'general_notifications';
  
  // QR Code
  static const String qrCodePrefix = 'sahabi://profile/';
  
  // Map Constants
  static const double defaultLatitude = 13.5116; // Niamey, Niger
  static const double defaultLongitude = 2.1254;
  static const double defaultZoom = 12.0;
}
