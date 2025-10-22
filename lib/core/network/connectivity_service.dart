import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;

/// Service de gestion de la connectivité réseau
/// Surveille l'état de la connexion internet et notifie les changements
class ConnectivityService {
  final Connectivity _connectivity;
  
  // Stream controller pour notifier les changements de connectivité
  final _connectivityStreamController = StreamController<bool>.broadcast();
  
  // État de la connectivité
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  // Subscription à la connectivité
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  ConnectivityService(this._connectivity);

  /// Initialise le service de connectivité
  Future<void> initialize() async {
    try {
      // Vérifier l'état initial de la connectivité
      await checkConnectivity();
      
      // Écouter les changements de connectivité
      _subscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          developer.log('Connectivity error: $error', name: 'ConnectivityService');
        },
      );
      
      developer.log('ConnectivityService initialized. Initial status: $_isConnected', 
          name: 'ConnectivityService');
    } catch (e) {
      developer.log('Error initializing ConnectivityService: $e', 
          name: 'ConnectivityService');
    }
  }

  /// Vérifie l'état actuel de la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
      return _isConnected;
    } catch (e) {
      developer.log('Error checking connectivity: $e', name: 'ConnectivityService');
      _isConnected = false;
      return false;
    }
  }

  /// Gère les changements de connectivité
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _updateConnectivityStatus(results);
    
    // Notifier seulement si l'état a changé
    if (wasConnected != _isConnected) {
      developer.log(
        'Connectivity changed: ${wasConnected ? "online" : "offline"} -> ${_isConnected ? "online" : "offline"}',
        name: 'ConnectivityService',
      );
      _connectivityStreamController.add(_isConnected);
    }
  }

  /// Met à jour l'état de la connectivité
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    // Considérer comme connecté si au moins une connexion est disponible
    // et que ce n'est pas "none"
    _isConnected = results.isNotEmpty && 
        !results.every((result) => result == ConnectivityResult.none);
  }

  /// Stream des changements de connectivité
  /// Émet `true` quand connecté, `false` quand déconnecté
  Stream<bool> get onConnectivityChanged => _connectivityStreamController.stream;

  /// Attend que la connexion soit rétablie
  /// Timeout après la durée spécifiée (par défaut 30 secondes)
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;
    
    try {
      developer.log('Waiting for connection...', name: 'ConnectivityService');
      
      // Attendre le prochain événement de connectivité ou timeout
      final isConnected = await onConnectivityChanged
          .firstWhere((connected) => connected)
          .timeout(timeout, onTimeout: () => false);
      
      if (isConnected) {
        developer.log('Connection restored', name: 'ConnectivityService');
      } else {
        developer.log('Connection wait timed out', name: 'ConnectivityService');
      }
      
      return isConnected;
    } catch (e) {
      developer.log('Error waiting for connection: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Vérifie si une connexion WiFi est disponible
  Future<bool> isWifiConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      developer.log('Error checking WiFi: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Vérifie si une connexion mobile est disponible
  Future<bool> isMobileConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      developer.log('Error checking mobile: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Obtient le type de connexion actuel
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        return 'none';
      }
      
      if (results.contains(ConnectivityResult.wifi)) {
        return 'wifi';
      }
      
      if (results.contains(ConnectivityResult.mobile)) {
        return 'mobile';
      }
      
      if (results.contains(ConnectivityResult.ethernet)) {
        return 'ethernet';
      }
      
      return 'unknown';
    } catch (e) {
      developer.log('Error getting connection type: $e', name: 'ConnectivityService');
      return 'unknown';
    }
  }

  /// Libère les ressources
  void dispose() {
    _subscription?.cancel();
    _connectivityStreamController.close();
    developer.log('ConnectivityService disposed', name: 'ConnectivityService');
  }
}

