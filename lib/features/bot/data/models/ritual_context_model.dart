import 'package:geolocator/geolocator.dart';

/// Modèle du contexte rituel basé sur GPS + date/heure
class RitualContextModel {
  final String? currentLocation;
  final String? currentRitualId;
  final List<String> suggestedDuas;
  final List<String> urgentReminders;
  final Position? position;
  final DateTime timestamp;
  final bool isInHolyPlace;
  final String? hijriDate;

  const RitualContextModel({
    this.currentLocation,
    this.currentRitualId,
    required this.suggestedDuas,
    required this.urgentReminders,
    this.position,
    required this.timestamp,
    required this.isInHolyPlace,
    this.hijriDate,
  });

  factory RitualContextModel.empty() {
    return RitualContextModel(
      suggestedDuas: [],
      urgentReminders: [],
      timestamp: DateTime.now(),
      isInHolyPlace: false,
    );
  }

  RitualContextModel copyWith({
    String? currentLocation,
    String? currentRitualId,
    List<String>? suggestedDuas,
    List<String>? urgentReminders,
    Position? position,
    DateTime? timestamp,
    bool? isInHolyPlace,
    String? hijriDate,
  }) {
    return RitualContextModel(
      currentLocation: currentLocation ?? this.currentLocation,
      currentRitualId: currentRitualId ?? this.currentRitualId,
      suggestedDuas: suggestedDuas ?? this.suggestedDuas,
      urgentReminders: urgentReminders ?? this.urgentReminders,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      isInHolyPlace: isInHolyPlace ?? this.isInHolyPlace,
      hijriDate: hijriDate ?? this.hijriDate,
    );
  }

  @override
  String toString() {
    return 'RitualContext(location: $currentLocation, ritual: $currentRitualId, duas: ${suggestedDuas.length}, reminders: ${urgentReminders.length})';
  }
}

/// Lieu saint avec coordonnées
class HolyPlace {
  final String id;
  final String name;
  final String nameAr;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<String> relatedRituals;

  const HolyPlace({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.relatedRituals,
  });

  /// Vérifie si une position est dans ce lieu
  bool isInside(Position position) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
    
    // Convert km to meters
    return distance <= (radiusKm * 1000);
  }
}

