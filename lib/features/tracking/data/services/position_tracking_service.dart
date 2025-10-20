import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import '../repositories/position_repository.dart';
import '../../../../shared/services/location_service.dart';

/// Service pour gérer le tracking automatique de la position GPS
class PositionTrackingService extends ChangeNotifier {
  final PositionRepository _positionRepository;
  final LocationService _locationService;
  final Battery _battery = Battery();

  Timer? _trackingTimer;
  bool _isTracking = false;
  DateTime? _lastSentTime;
  String? _userId;
  String? _lastError;
  int _successCount = 0;
  int _errorCount = 0;

  // Configuration
  static const Duration _defaultInterval = Duration(minutes: 1);
  Duration _interval = _defaultInterval;

  PositionTrackingService({
    required PositionRepository positionRepository,
    required LocationService locationService,
  })  : _positionRepository = positionRepository,
        _locationService = locationService;

  // Getters
  bool get isTracking => _isTracking;
  DateTime? get lastSentTime => _lastSentTime;
  String? get lastError => _lastError;
  int get successCount => _successCount;
  int get errorCount => _errorCount;
  Duration get interval => _interval;

  /// Démarre le tracking automatique de position
  Future<void> startTracking(String userId, {Duration? interval}) async {
    if (_isTracking) {
      debugPrint('⚠️ Le tracking est déjà actif');
      return;
    }

    _userId = userId;
    _interval = interval ?? _defaultInterval;
    _isTracking = true;
    _lastError = null;
    _successCount = 0;
    _errorCount = 0;

    debugPrint('🚀 Démarrage du tracking GPS pour utilisateur $userId');
    debugPrint('📍 Intervalle: ${_interval.inMinutes} minute(s)');

    // Envoyer immédiatement la première position
    await _sendCurrentPosition();

    // Démarrer le timer pour les envois périodiques
    _trackingTimer = Timer.periodic(_interval, (timer) {
      _sendCurrentPosition();
    });

    notifyListeners();
  }

  /// Arrête le tracking automatique
  void stopTracking() {
    if (!_isTracking) {
      debugPrint('⚠️ Le tracking n\'est pas actif');
      return;
    }

    debugPrint('🛑 Arrêt du tracking GPS');
    
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _userId = null;

    notifyListeners();
  }

  /// Change l'intervalle de tracking
  void setInterval(Duration newInterval) {
    _interval = newInterval;
    
    if (_isTracking) {
      // Redémarrer avec le nouvel intervalle
      final userId = _userId;
      stopTracking();
      if (userId != null) {
        startTracking(userId, interval: newInterval);
      }
    }
  }

  /// Envoie la position actuelle au serveur
  Future<void> _sendCurrentPosition() async {
    if (_userId == null) {
      debugPrint('❌ Pas d\'userId configuré');
      return;
    }

    try {
      debugPrint('📡 Envoi de la position...');

      // Récupérer la position GPS
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        throw Exception('Impossible d\'obtenir la position GPS');
      }

      // Récupérer le niveau de batterie
      final batteryLevel = await _battery.batteryLevel;

      // Envoyer au serveur
      await _positionRepository.sendPosition(
        userId: _userId!,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        battery: batteryLevel,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
      );

      _lastSentTime = DateTime.now();
      _successCount++;
      _lastError = null;

      debugPrint('✅ Position envoyée avec succès');
      debugPrint('   📍 Lat: ${position.latitude}, Lng: ${position.longitude}');
      debugPrint('   🔋 Batterie: $batteryLevel%');
      debugPrint('   📊 Succès: $_successCount, Erreurs: $_errorCount');

      notifyListeners();
    } catch (e, stackTrace) {
      _errorCount++;
      _lastError = e.toString();
      
      debugPrint('❌ Erreur lors de l\'envoi de position: $e');
      debugPrint('Stack: $stackTrace');
      
      notifyListeners();
      
      // Ne pas arrêter le tracking en cas d'erreur (réessayer au prochain cycle)
    }
  }

  /// Envoie manuellement la position (hors du cycle automatique)
  Future<void> sendPositionNow() async {
    if (_userId == null) {
      throw Exception('Le tracking n\'est pas démarré');
    }

    await _sendCurrentPosition();
  }

  /// Réinitialise les compteurs
  void resetCounters() {
    _successCount = 0;
    _errorCount = 0;
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}


