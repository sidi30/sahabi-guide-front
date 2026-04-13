import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import '../models/ritual_context_model.dart';

/// Service de contextualisation basé sur GPS et temps
/// Détecte le lieu actuel et suggère des actions contextuelles
class ContextService {
  final Logger logger;
  
  // Lieux saints avec coordonnées précises
  static final List<HolyPlace> _holyPlaces = [
    const HolyPlace(
      id: 'masjid_al_haram',
      name: 'Masjid al-Haram',
      nameAr: 'المسجد الحرام',
      latitude: 21.4225,
      longitude: 39.8262,
      radiusKm: 1.0,
      relatedRituals: ['ihram', 'tawaf', 'sai', 'tawaf_arrival', 'tawaf_ifadah', 'tawaf_wida'],
    ),
    const HolyPlace(
      id: 'mina',
      name: 'Mina',
      nameAr: 'منى',
      latitude: 21.4203,
      longitude: 39.8875,
      radiusKm: 3.0,
      relatedRituals: ['mina', 'mina_day8', 'mina_days_tashriq', 'ramy'],
    ),
    const HolyPlace(
      id: 'arafat',
      name: 'Arafat',
      nameAr: 'عرفة',
      latitude: 21.3551,
      longitude: 39.9843,
      radiusKm: 5.0,
      relatedRituals: ['arafat'],
    ),
    const HolyPlace(
      id: 'muzdalifah',
      name: 'Muzdalifah',
      nameAr: 'المزدلفة',
      latitude: 21.3892,
      longitude: 39.9198,
      radiusKm: 2.0,
      relatedRituals: ['muzdalifah'],
    ),
    const HolyPlace(
      id: 'makkah',
      name: 'La Mecque',
      nameAr: 'مكة المكرمة',
      latitude: 21.3891,
      longitude: 39.8579,
      radiusKm: 10.0,
      relatedRituals: ['all'],
    ),
  ];

  ContextService({required this.logger});

  /// Récupère le contexte actuel (GPS + temps)
  Future<RitualContextModel> getCurrentContext() async {
    try {
      // Vérifie les permissions GPS
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        logger.w('Location permission not granted');
        return RitualContextModel.empty();
      }

      // Récupère la position actuelle
      final position = await _getCurrentPosition();
      if (position == null) {
        logger.w('Could not get current position');
        return RitualContextModel.empty();
      }

      // Détecte le lieu actuel
      final currentPlace = _detectCurrentPlace(position);
      
      // Détermine le rituel actuel basé sur lieu + date
      final currentRitual = _determineCurrentRitual(currentPlace, DateTime.now());
      
      // Récupère les duas suggérées
      final suggestedDuas = _getSuggestedDuas(currentPlace, currentRitual);
      
      // Récupère les rappels urgents
      final urgentReminders = _getUrgentReminders(currentPlace, currentRitual, DateTime.now());

      // Calcule la date Hijri approximative
      final hijriDate = _approximateHijriDate(DateTime.now());

      return RitualContextModel(
        currentLocation: currentPlace?.name,
        currentRitualId: currentRitual,
        suggestedDuas: suggestedDuas,
        urgentReminders: urgentReminders,
        position: position,
        timestamp: DateTime.now(),
        isInHolyPlace: currentPlace != null,
        hijriDate: hijriDate,
      );
    } catch (e, stackTrace) {
      logger.e('Error getting context: $e', stackTrace: stackTrace);
      return RitualContextModel.empty();
    }
  }

  /// Vérifie les permissions de localisation
  Future<bool> _checkLocationPermission() async {
    try {
      // Vérifie si le service est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Location services are disabled');
        return false;
      }

      // Vérifie la permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.e('Location permission denied forever');
        return false;
      }

      return true;
    } catch (e) {
      logger.e('Error checking location permission: $e');
      return false;
    }
  }

  /// Récupère la position GPS actuelle
  Future<Position?> _getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      logger.d('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      logger.e('Error getting position: $e');
      return null;
    }
  }

  /// Détecte le lieu saint actuel
  HolyPlace? _detectCurrentPlace(Position position) {
    // Cherche le lieu le plus spécifique (plus petit rayon) en premier
    final sortedPlaces = List<HolyPlace>.from(_holyPlaces)
      ..sort((a, b) => a.radiusKm.compareTo(b.radiusKm));

    for (final place in sortedPlaces) {
      if (place.isInside(position)) {
        logger.d('Detected location: ${place.name}');
        return place;
      }
    }

    logger.d('Not in any holy place');
    return null;
  }

  /// Détermine le rituel actuel basé sur lieu + date
  String? _determineCurrentRitual(HolyPlace? place, DateTime now) {
    if (place == null) return null;

    // Logique simplifiée basée sur le lieu
    switch (place.id) {
      case 'arafat':
        // Si à Arafat, c'est forcément le jour d'Arafat
        return 'arafat';
      
      case 'muzdalifah':
        return 'muzdalifah';
      
      case 'mina':
        // Détermine si c'est jour 8, 10, ou jours de tashriq
        // Pour l'instant, retourne mina par défaut
        return 'mina_days_tashriq';
      
      case 'masjid_al_haram':
        // À la mosquée, peut être tawaf ou sai
        return 'tawaf_arrival';
      
      default:
        return null;
    }
  }

  /// Récupère les duas suggérées pour le contexte
  List<String> _getSuggestedDuas(HolyPlace? place, String? ritual) {
    if (place == null) return [];

    final duas = <String>[];

    switch (place.id) {
      case 'arafat':
        duas.addAll([
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          'La ilaha illa Allah wahdahu la sharika lah',
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
        ]);
        break;
      
      case 'muzdalifah':
        duas.addAll([
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
          'Allahumma inni as\'aluka min fadlik',
        ]);
        break;
      
      case 'mina':
        duas.addAll([
          'بِسْمِ اللَّهِ اللَّهُ أَكْبَرُ',
          'Bismillah, Allahu Akbar (au Ramy)',
        ]);
        break;
      
      case 'masjid_al_haram':
        duas.addAll([
          'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
          'Subhan Allah, Alhamdulillah, La ilaha illa Allah, Allahu Akbar',
        ]);
        break;
    }

    return duas;
  }

  /// Récupère les rappels urgents pour le contexte
  List<String> _getUrgentReminders(HolyPlace? place, String? ritual, DateTime now) {
    if (place == null) return [];

    final reminders = <String>[];

    switch (place.id) {
      case 'arafat':
        reminders.addAll([
          '⚠️ CRUCIAL : Restez à Arafat jusqu\'au coucher du soleil !',
          '🕌 Multipliez les invocations : c\'est le meilleur jour de l\'année.',
          '💧 Hydratez-vous régulièrement.',
        ]);
        
        // Vérifier l'heure (si proche du coucher du soleil)
        final hour = now.hour;
        if (hour >= 16 && hour < 18) {
          reminders.add('⏰ Le coucher du soleil approche. Restez à Arafat !');
        }
        break;
      
      case 'muzdalifah':
        reminders.addAll([
          '🪨 N\'oubliez pas de collecter 49 cailloux (taille pois chiche).',
          '🌙 Passez la nuit ici jusqu\'au Fajr au minimum.',
        ]);
        break;
      
      case 'mina':
        reminders.addAll([
          '🎯 Lapidez les Jamarat après le Dhuhr.',
          '⛺ Restez à Mina pour les nuits des jours de Tashriq.',
        ]);
        break;
      
      case 'masjid_al_haram':
        reminders.addAll([
          '🕋 Profitez de votre présence dans le lieu le plus sacré.',
          '📿 Priez 2 raka\'at derrière Maqam Ibrahim après le Tawaf.',
        ]);
        break;
    }

    return reminders;
  }

  /// Approximation simple de la date Hijri
  /// Note: Pour une précision exacte, utiliser une librairie dédiée
  String _approximateHijriDate(DateTime gregorian) {
    // Formule approximative : date Hijri ≈ date Grégorienne - 579 ans
    // C'est une approximation très simple, pas précise à 100%
    
    final hijriYear = gregorian.year - 579;
    
    // Jours approximatifs de Dhul Hijjah (autour de juin-juillet selon l'année)
    // Cette logique est très simplifiée et devrait être remplacée par une vraie librairie
    if (gregorian.month >= 6 && gregorian.month <= 7) {
      return '$hijriYear Dhul Hijjah (approximatif)';
    }
    
    return '$hijriYear (approximatif)';
  }

  /// Vérifie si c'est un jour spécifique du Hajj
  bool isSpecificHajjDay(DateTime date, int dhulHijjahDay) {
    // TODO: Implémenter avec une vraie librairie de calendrier Hijri
    // Pour l'instant, retourne false
    return false;
  }

  /// Distance jusqu'à un lieu saint
  double? distanceToPlace(String placeId, Position currentPosition) {
    final place = _holyPlaces.firstWhere(
      (p) => p.id == placeId,
      orElse: () => _holyPlaces.first,
    );

    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      place.latitude,
      place.longitude,
    );

    return distance / 1000; // Convert to km
  }

  /// Liste tous les lieux saints
  List<HolyPlace> getAllHolyPlaces() {
    return List.unmodifiable(_holyPlaces);
  }
}

