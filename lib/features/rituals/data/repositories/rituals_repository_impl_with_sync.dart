import 'dart:async';
import 'dart:developer' as developer;
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../datasources/rituals_local_data_source.dart';
import '../datasources/rituals_remote_data_source.dart';

/// Implémentation du repository avec synchronisation automatique
/// Gère le cache local avec Hive et la synchronisation avec le backend
class RitualsRepositoryImplWithSync implements RitualsRepository {
  final RitualsLocalDataSource localDataSource;
  final RitualsRemoteDataSource? remoteDataSource;
  final ConnectivityService? connectivityService;

  // Contrôle de la synchronisation en cours
  bool _isSyncingRituals = false;
  bool _isSyncingDuas = false;

  // Stream controllers pour notifier les mises à jour
  final _ritualsUpdateController = StreamController<List<RitualModel>>.broadcast();
  final _duasUpdateController = StreamController<List<DuaModel>>.broadcast();

  // Subscription à la connectivité
  StreamSubscription<bool>? _connectivitySubscription;

  RitualsRepositoryImplWithSync({
    required this.localDataSource,
    this.remoteDataSource,
    this.connectivityService,
  }) {
    // Écouter les changements de connectivité pour synchroniser automatiquement
    _initConnectivityListener();
  }

  /// Initialise l'écoute de la connectivité pour la synchronisation automatique
  void _initConnectivityListener() {
    if (connectivityService != null) {
      _connectivitySubscription = connectivityService!.onConnectivityChanged.listen(
        (isConnected) {
          if (isConnected) {
            developer.log(
              'Connection restored, triggering auto-sync',
              name: 'RitualsRepository',
            );
            // Synchroniser automatiquement quand la connexion est rétablie
            _autoSyncRituals();
            _autoSyncDuas();
          }
        },
      );
    }
  }

  @override
  Future<List<RitualModel>> getRituals({bool forceRefresh = false, String? userId}) async {
    // Stratégie offline-first avec synchronisation intelligente:
    // 1. Charger depuis le cache immédiatement (UI rapide)
    // 2. Si connecté et forceRefresh ou cache obsolète, fetch depuis API
    // 3. Mettre à jour le cache si l'API réussit
    // 4. Fallback au cache si l'API échoue

    List<RitualModel> cachedRituals = [];

    try {
      // Étape 1: Charger depuis le cache local
      cachedRituals = await localDataSource.getRituals();
      developer.log(
        'Loaded ${cachedRituals.length} rituals from cache',
        name: 'RitualsRepository',
      );

      // Si pas de connexion, retourner le cache
      if (connectivityService != null && !connectivityService!.isConnected) {
        developer.log(
          'No connection, using cached rituals',
          name: 'RitualsRepository',
        );
        return cachedRituals;
      }

      // Étape 2: Synchroniser avec le backend si nécessaire
      if (remoteDataSource != null && (forceRefresh || cachedRituals.isEmpty)) {
        developer.log('Fetching rituals from API', name: 'RitualsRepository');
        final freshRituals = await _fetchAndCacheRituals(userId: userId);
        return freshRituals;
      }

      return cachedRituals;
    } catch (e) {
      developer.log(
        'Error in getRituals: $e',
        name: 'RitualsRepository',
      );
      // En cas d'erreur, retourner le cache s'il existe
      if (cachedRituals.isNotEmpty) {
        return cachedRituals;
      }
      rethrow;
    }
  }

  /// Récupère les rituels depuis l'API et les met en cache
  Future<List<RitualModel>> _fetchAndCacheRituals({String? userId}) async {
    if (remoteDataSource == null) {
      return await localDataSource.getRituals();
    }

    try {
      final remoteData = await remoteDataSource!.getRituals(userId: userId);
      final rituals = remoteData.map((data) => RitualModel.fromJson(data)).toList();

      // Déterminer la version de contenu maximale
      int? maxContentVersion;
      if (rituals.isNotEmpty && rituals.first.contentVersion != null) {
        maxContentVersion = rituals
            .map((r) => r.contentVersion ?? 0)
            .reduce((a, b) => a > b ? a : b);
      }

      // Sauvegarder dans le cache
      await localDataSource.saveRituals(rituals, contentVersion: maxContentVersion);
      developer.log(
        'Saved ${rituals.length} rituals to cache (version: $maxContentVersion)',
        name: 'RitualsRepository',
      );

      // Notifier les listeners
      _ritualsUpdateController.add(rituals);

      return rituals;
    } catch (e) {
      developer.log('Failed to fetch rituals from API: $e', name: 'RitualsRepository');
      rethrow;
    }
  }

  /// Synchronisation automatique des rituels (en arrière-plan)
  Future<void> _autoSyncRituals() async {
    if (_isSyncingRituals || remoteDataSource == null) return;

    _isSyncingRituals = true;
    try {
      developer.log('Auto-syncing rituals...', name: 'RitualsRepository');
      await _fetchAndCacheRituals();
      developer.log('Auto-sync rituals completed', name: 'RitualsRepository');
    } catch (e) {
      developer.log('Auto-sync rituals failed: $e', name: 'RitualsRepository');
    } finally {
      _isSyncingRituals = false;
    }
  }

  @override
  Future<List<DuaModel>> getDuas({bool forceRefresh = false}) async {
    // Stratégie similaire aux rituels
    List<DuaModel> cachedDuas = [];

    try {
      // Charger depuis le cache
      cachedDuas = await localDataSource.getDuas();
      developer.log(
        'Loaded ${cachedDuas.length} duas from cache',
        name: 'RitualsRepository',
      );

      // Si pas de connexion, retourner le cache
      if (connectivityService != null && !connectivityService!.isConnected) {
        developer.log('No connection, using cached duas', name: 'RitualsRepository');
        return cachedDuas;
      }

      // Synchroniser avec le backend si nécessaire
      if (remoteDataSource != null && (forceRefresh || cachedDuas.isEmpty)) {
        developer.log('Fetching duas from API', name: 'RitualsRepository');
        final freshDuas = await _fetchAndCacheDuas();
        return freshDuas;
      }

      return cachedDuas;
    } catch (e) {
      developer.log('Error in getDuas: $e', name: 'RitualsRepository');
      if (cachedDuas.isNotEmpty) {
        return cachedDuas;
      }
      rethrow;
    }
  }

  /// Récupère les duas depuis l'API et les met en cache
  Future<List<DuaModel>> _fetchAndCacheDuas() async {
    if (remoteDataSource == null) {
      return await localDataSource.getDuas();
    }

    try {
      final remoteData = await remoteDataSource!.getDuas();
      final duas = remoteData.map((data) => DuaModel.fromJson(data)).toList();

      // Sauvegarder dans le cache
      await localDataSource.saveDuas(duas);
      developer.log('Saved ${duas.length} duas to cache', name: 'RitualsRepository');

      // Notifier les listeners
      _duasUpdateController.add(duas);

      return duas;
    } catch (e) {
      developer.log('Failed to fetch duas from API: $e', name: 'RitualsRepository');
      rethrow;
    }
  }

  /// Synchronisation automatique des duas (en arrière-plan)
  Future<void> _autoSyncDuas() async {
    if (_isSyncingDuas || remoteDataSource == null) return;

    _isSyncingDuas = true;
    try {
      developer.log('Auto-syncing duas...', name: 'RitualsRepository');
      await _fetchAndCacheDuas();
      developer.log('Auto-sync duas completed', name: 'RitualsRepository');
    } catch (e) {
      developer.log('Auto-sync duas failed: $e', name: 'RitualsRepository');
    } finally {
      _isSyncingDuas = false;
    }
  }

  /// Force la synchronisation de toutes les données
  Future<void> syncAll() async {
    developer.log('Forcing full sync...', name: 'RitualsRepository');
    try {
      await Future.wait([
        _fetchAndCacheRituals(),
        _fetchAndCacheDuas(),
      ]);
      developer.log('Full sync completed', name: 'RitualsRepository');
    } catch (e) {
      developer.log('Full sync failed: $e', name: 'RitualsRepository');
      rethrow;
    }
  }

  @override
  Future<void> markAsCompleted(String ritualId) async {
    await localDataSource.markAsCompleted(ritualId);
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    return await localDataSource.getRitualById(id);
  }

  /// Stream des mises à jour des rituels
  Stream<List<RitualModel>> get ritualsUpdates => _ritualsUpdateController.stream;

  /// Stream des mises à jour des duas
  Stream<List<DuaModel>> get duasUpdates => _duasUpdateController.stream;

  /// Libère les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _ritualsUpdateController.close();
    _duasUpdateController.close();
  }
}

