import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sahabi_guide/core/di/injection_container.dart';
import 'package:sahabi_guide/shared/services/location_service.dart';

/// Modèle pour une zone de geofencing
class GeoFenceZone {
  final String id;
  final String name;
  final double centerLat;
  final double centerLng;
  final double radiusMeters;
  final bool notifyOnEntry;
  final bool notifyOnExit;
  
  GeoFenceZone({
    required this.id,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.radiusMeters,
    this.notifyOnEntry = true,
    this.notifyOnExit = true,
  });

  bool containsPoint(double lat, double lng) {
    final distance = Geolocator.distanceBetween(
      centerLat,
      centerLng,
      lat,
      lng,
    );
    return distance <= radiusMeters;
  }
}

/// Service pour gérer le geofencing local et les notifications
class LocalGeofencingService {
  final LocationService _locationService = sl<LocationService>();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<GeoFenceZone> _zones = [];
  final Map<String, bool> _userInsideZone = {}; // Zone ID -> inside status
  
  StreamSubscription<Position>? _positionSubscription;
  bool _isMonitoring = false;

  bool get isMonitoring => _isMonitoring;
  List<GeoFenceZone> get zones => List.unmodifiable(_zones);

  /// Initialise le service de notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Demander la permission de notification sur Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer l'action lorsque l'utilisateur tape sur la notification
    print('Notification tapped: ${response.payload}');
  }

  /// Ajoute une zone de geofencing
  void addZone(GeoFenceZone zone) {
    if (!_zones.any((z) => z.id == zone.id)) {
      _zones.add(zone);
      _userInsideZone[zone.id] = false;
      print('🌍 Zone ajoutée: ${zone.name} (rayon: ${zone.radiusMeters}m)');
    }
  }

  /// Supprime une zone
  void removeZone(String zoneId) {
    _zones.removeWhere((z) => z.id == zoneId);
    _userInsideZone.remove(zoneId);
    print('🌍 Zone supprimée: $zoneId');
  }

  /// Supprime toutes les zones
  void clearZones() {
    _zones.clear();
    _userInsideZone.clear();
    print('🌍 Toutes les zones supprimées');
  }

  /// Démarre la surveillance des zones
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      print('⚠️ Le monitoring est déjà actif');
      return;
    }

    if (_zones.isEmpty) {
      print('⚠️ Aucune zone à surveiller');
      return;
    }

    print('🚀 Démarrage du monitoring de ${_zones.length} zone(s)');
    _isMonitoring = true;

    // Écouter les changements de position
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour tous les 10 mètres
      ),
    ).listen(
      (Position position) {
        _checkGeofences(position);
      },
      onError: (error) {
        print('❌ Erreur de geofencing: $error');
      },
    );
  }

  /// Arrête la surveillance
  void stopMonitoring() {
    if (!_isMonitoring) {
      print('⚠️ Le monitoring n\'est pas actif');
      return;
    }

    print('🛑 Arrêt du monitoring des zones');
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isMonitoring = false;
  }

  /// Vérifie si l'utilisateur entre/sort d'une zone
  void _checkGeofences(Position position) {
    for (var zone in _zones) {
      final isInside = zone.containsPoint(position.latitude, position.longitude);
      final wasInside = _userInsideZone[zone.id] ?? false;

      // L'utilisateur vient d'entrer dans la zone
      if (isInside && !wasInside && zone.notifyOnEntry) {
        _sendNotification(
          'Entrée dans la zone',
          'Vous venez d\'entrer dans ${zone.name}',
          zone.id,
        );
        print('✅ Entrée dans la zone: ${zone.name}');
      }
      // L'utilisateur vient de sortir de la zone
      else if (!isInside && wasInside && zone.notifyOnExit) {
        _sendNotification(
          'Sortie de la zone',
          'Vous avez quitté ${zone.name}',
          zone.id,
        );
        print('⚠️ Sortie de la zone: ${zone.name}');
      }

      _userInsideZone[zone.id] = isInside;
    }
  }

  /// Envoie une notification locale
  Future<void> _sendNotification(String title, String body, String payload) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Alertes de Zone',
      channelDescription: 'Notifications lorsque vous entrez/sortez d\'une zone de sécurité',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // ID unique
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Ajoute des zones prédéfinies (exemples pour La Mecque)
  void addDefaultMeccaZones() {
    // Grande Mosquée de La Mecque (Masjid al-Haram)
    addZone(GeoFenceZone(
      id: 'masjid_haram',
      name: 'Masjid al-Haram',
      centerLat: 21.4225,
      centerLng: 39.8262,
      radiusMeters: 500,
      notifyOnEntry: true,
      notifyOnExit: true,
    ));

    // Mina (zone de tentes)
    addZone(GeoFenceZone(
      id: 'mina',
      name: 'Mina',
      centerLat: 21.4114,
      centerLng: 39.8889,
      radiusMeters: 1000,
      notifyOnEntry: true,
      notifyOnExit: true,
    ));

    // Arafat
    addZone(GeoFenceZone(
      id: 'arafat',
      name: 'Mont Arafat',
      centerLat: 21.3546,
      centerLng: 39.9832,
      radiusMeters: 1000,
      notifyOnEntry: true,
      notifyOnExit: true,
    ));

    // Muzdalifah
    addZone(GeoFenceZone(
      id: 'muzdalifah',
      name: 'Muzdalifah',
      centerLat: 21.3924,
      centerLng: 39.9384,
      radiusMeters: 800,
      notifyOnEntry: true,
      notifyOnExit: true,
    ));

    print('✅ Zones par défaut de La Mecque ajoutées');
  }

  /// Libère les ressources
  void dispose() {
    stopMonitoring();
    clearZones();
  }
}


