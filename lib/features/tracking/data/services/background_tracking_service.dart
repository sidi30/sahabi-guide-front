import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'position_tracking_service.dart';

/// Service pour gérer le tracking en arrière-plan
/// Utilise les capacités natives de Geolocator pour le tracking continu
class BackgroundTrackingService {
  static final BackgroundTrackingService _instance = BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isBackgroundTrackingActive = false;

  bool get isBackgroundTrackingActive => _isBackgroundTrackingActive;

  /// Démarre le tracking en arrière-plan
  /// Nécessite les permissions de localisation "Always"
  Future<bool> startBackgroundTracking(PositionTrackingService trackingService) async {
    debugPrint('🔄 Tentative de démarrage du tracking en arrière-plan...');

    // Vérifier les permissions
    final permissionStatus = await _checkBackgroundPermissions();
    if (!permissionStatus) {
      debugPrint('❌ Permissions insuffisantes pour le tracking en arrière-plan');
      return false;
    }

    // Vérifier que le service de localisation est actif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Service de localisation désactivé');
      return false;
    }

    // Configuration pour le tracking en arrière-plan
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour si déplacement > 10m
      // Sur Android, permet le tracking en arrière-plan
      // Sur iOS, utilise le mode "always" si les permissions sont accordées
    );

    try {
      // S'abonner au stream de positions
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          debugPrint('📍 Position en arrière-plan: ${position.latitude}, ${position.longitude}');
          // Les positions seront traitées par le PositionTrackingService
        },
        onError: (error) {
          debugPrint('❌ Erreur tracking arrière-plan: $error');
        },
        cancelOnError: false,
      );

      _isBackgroundTrackingActive = true;
      debugPrint('✅ Tracking en arrière-plan démarré');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors du démarrage du tracking en arrière-plan: $e');
      return false;
    }
  }

  /// Arrête le tracking en arrière-plan
  void stopBackgroundTracking() {
    debugPrint('🛑 Arrêt du tracking en arrière-plan');
    
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isBackgroundTrackingActive = false;
  }

  /// Vérifie et demande les permissions nécessaires pour le tracking en arrière-plan
  Future<bool> _checkBackgroundPermissions() async {
    // Vérifier d'abord les permissions basiques
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Sur Android 10+, demander la permission "Always"
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        final result = await Permission.locationAlways.request();
        return result.isGranted;
      }
    }

    return true;
  }

  /// Demande les permissions de tracking en arrière-plan à l'utilisateur
  Future<bool> requestBackgroundPermissions() async {
    debugPrint('📲 Demande des permissions de tracking en arrière-plan');

    // Permission de localisation de base
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Permissions refusées définitivement');
      return false;
    }

    if (permission == LocationPermission.denied) {
      debugPrint('❌ Permissions refusées');
      return false;
    }

    // Pour Android, demander la permission "Always"
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        debugPrint('❌ Permission "Always" refusée');
        return false;
      }
    }

    debugPrint('✅ Permissions accordées');
    return true;
  }

  /// Ouvre les paramètres de l'application
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}


