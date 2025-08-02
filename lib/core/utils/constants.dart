class AppConstants {
  // App Info
  static const String appName = 'Hajj Companion';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your guide for a blessed and seamless pilgrimage';
  
  // API Constants
  static const String apiBaseUrl = 'https://api.hajjcompanion.com';
  static const int apiTimeout = 30000;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userProfileKey = 'user_profile';
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
