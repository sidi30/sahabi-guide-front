import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import '../repositories/position_repository.dart';
import '../../../../shared/services/location_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/tracking_config_model.dart';

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
  Position? _lastPosition;
  bool _isPausedLowBattery = false;
  bool _sending = false;

  // Configuration
  TrackingConfig _config = const TrackingConfig();
  
  // Getters pour la config
  TrackingConfig get config => _config;

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
  Duration get interval => _config.mode.interval;
  bool get isPausedLowBattery => _isPausedLowBattery;

  /// Démarre le tracking automatique de position
  Future<void> startTracking(String userId, {TrackingConfig? config}) async {
    if (_isTracking) {
      AppLogger.debug('⚠️ Le tracking est déjà actif');
      return;
    }

    _userId = userId;
    _config = config ?? const TrackingConfig();
    _isTracking = true;
    _lastError = null;
    _successCount = 0;
    _errorCount = 0;
    _isPausedLowBattery = false;

    AppLogger.debug('🚀 Démarrage du tracking GPS pour utilisateur $userId');
    AppLogger.debug('📍 Mode: ${_config.mode.label}');
    AppLogger.debug('⏱️ Intervalle: ${_config.mode.interval.inMinutes} minute(s)');
    AppLogger.debug('🔋 Pause batterie faible: ${_config.pauseOnLowBattery ? "Oui (<${_config.lowBatteryThreshold}%)" : "Non"}');

    // Envoyer immédiatement la première position
    await _sendCurrentPosition();

    // Démarrer le timer pour les envois périodiques
    _trackingTimer = Timer.periodic(_config.mode.interval, (timer) {
      _sendCurrentPosition();
    });

    notifyListeners();
  }

  /// Arrête le tracking automatique
  void stopTracking() {
    if (!_isTracking) {
      AppLogger.debug('⚠️ Le tracking n\'est pas actif');
      return;
    }

    AppLogger.debug('🛑 Arrêt du tracking GPS');
    
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _userId = null;

    notifyListeners();
  }

  /// Change la configuration du tracking
  Future<void> updateConfig(TrackingConfig newConfig) async {
    _config = newConfig;

    if (_isTracking) {
      // Redémarrer avec la nouvelle config. On attend startTracking pour
      // éviter une course avec stopTracking (timer relancé avant arrêt).
      final userId = _userId;
      stopTracking();
      if (userId != null) {
        await startTracking(userId, config: newConfig);
      }
    }

    notifyListeners();
  }

  /// Envoie la position actuelle au serveur
  Future<void> _sendCurrentPosition() async {
    if (_userId == null) {
      AppLogger.debug('❌ Pas d\'userId configuré');
      return;
    }

    // Garde de ré-entrance : si un fix GPS précédent est encore en cours
    // (réseau lent / GPS bloqué), on saute ce cycle pour éviter des lectures
    // GPS qui se chevauchent et gardent la puce GPS allumée.
    if (_sending) {
      AppLogger.debug('⏭️ Envoi déjà en cours - cycle ignoré');
      return;
    }
    _sending = true;

    try {
      // Récupérer le niveau de batterie
      final batteryLevel = await _battery.batteryLevel;

      // Vérifier batterie faible
      if (_config.pauseOnLowBattery && batteryLevel <= _config.lowBatteryThreshold) {
        if (!_isPausedLowBattery) {
          _isPausedLowBattery = true;
          AppLogger.debug('⚠️ Batterie faible ($batteryLevel%) - Tracking en pause');
          notifyListeners();
        }
        return;
      } else if (_isPausedLowBattery) {
        _isPausedLowBattery = false;
        AppLogger.debug('✅ Batterie suffisante ($batteryLevel%) - Reprise du tracking');
        notifyListeners();
      }

      AppLogger.debug('📡 Envoi de la position...');

      // Récupérer la position GPS
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        throw Exception('Impossible d\'obtenir la position GPS');
      }

      // Vérifier si la position a changé (si mode "trackOnlyWhenMoving")
      if (_config.trackOnlyWhenMoving && _lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance < _config.mode.distanceFilter) {
          AppLogger.debug('⏭️ Position inchangée - Pas d\'envoi');
          return;
        }
      }

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

      _lastPosition = position;
      _lastSentTime = DateTime.now();
      _successCount++;
      _lastError = null;

      AppLogger.debug('✅ Position envoyée avec succès');
      AppLogger.debug('   🔋 Batterie: $batteryLevel%');
      AppLogger.debug('   🎯 Mode: ${_config.mode.label}');
      AppLogger.debug('   📊 Succès: $_successCount, Erreurs: $_errorCount');

      notifyListeners();
    } catch (e, stackTrace) {
      _errorCount++;
      _lastError = e.toString();
      
      AppLogger.error('❌ Erreur lors de l\'envoi de position', error: e, stackTrace: stackTrace);
      
      notifyListeners();

      // Ne pas arrêter le tracking en cas d'erreur (réessayer au prochain cycle)
    } finally {
      _sending = false;
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


