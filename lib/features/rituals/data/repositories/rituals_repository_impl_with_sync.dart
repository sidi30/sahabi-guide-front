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

  /// Clé composite d'indexation du cache : UNIQUE prédicat "requête ciblée".
  /// null = requête neutre (clé legacy Hive, entrées non préfixées).
  /// Inclut la LANGUE : un cache fr ne doit jamais être servi pour du ha.
  static String? cacheKeyFor({
    String? gender,
    String? states,
    String? lang,
    String? type,
  }) {
    final g =
        (gender != null && gender.isNotEmpty && gender != 'UNSPECIFIED') ? gender : '';
    final s = (states != null && states.isNotEmpty) ? states : '';
    final l = (lang != null && lang.isNotEmpty) ? lang : '';
    final t = (type != null && type.isNotEmpty) ? type : '';
    if (g.isEmpty && s.isEmpty && l.isEmpty && t.isEmpty) return null;
    return 'g=$g|t=$t|l=$l|s=$s';
  }

  @override
  Future<List<RitualModel>> getRituals({
    bool forceRefresh = false,
    String? userId,
    String? gender,
    String? states,
    String? lang,
    String? type,
  }) async {
    // Requête "ciblée" (genre / type Hajj-Omra / langue / état menses) : le cache
    // Hive est indexé par cette clé composite — chaque combinaison a son propre
    // lot d'entrées. On force le fetch réseau pour rester frais, mais en cas
    // d'échec on sert le cache de CETTE clé (jamais celui d'une autre clé, ni le
    // seed neutre) ; on n'échoue que s'il n'existe aucun cache pour cette clé.
    final cacheKey =
        cacheKeyFor(gender: gender, states: states, lang: lang, type: type);
    final bool keyed = cacheKey != null;
    if (keyed) {
      forceRefresh = true;
    }

    final bool offline =
        connectivityService != null && !connectivityService!.isConnected;
    List<RitualModel> cachedRituals = [];

    try {
      // Mémoriser la requête ciblée : l'auto-sync (retour réseau) recharge CE
      // contenu, pas une requête neutre.
      if (keyed) {
        await localDataSource.saveLastRitualsQuery({
          'userId': userId,
          'gender': gender,
          'states': states,
          'lang': lang,
          'type': type,
        });
      }

      // Étape 1: cache local pour CETTE clé (stale accepté hors-ligne : mieux
      // vaut du contenu périmé que rien ; le TTL déclenchera un refresh en ligne).
      cachedRituals = await localDataSource.getRituals(
          cacheKey: cacheKey, allowStale: offline);
      developer.log(
        'Loaded ${cachedRituals.length} rituals from cache (key: $cacheKey)',
        name: 'RitualsRepository',
      );

      // Hors-ligne : servir le cache de la clé s'il existe. Sinon on tente
      // quand même le réseau — s'il n'y en a vraiment pas, l'erreur remontera.
      if (offline && cachedRituals.isNotEmpty) {
        developer.log('No connection, using cached rituals (key: $cacheKey)',
            name: 'RitualsRepository');
        return cachedRituals;
      }

      // Étape 2: fetch backend si nécessaire.
      if (remoteDataSource != null && (forceRefresh || cachedRituals.isEmpty)) {
        developer.log('Fetching rituals from API', name: 'RitualsRepository');
        return await _fetchAndCacheRituals(
          userId: userId,
          gender: gender,
          states: states,
          lang: lang,
          type: type,
        );
      }

      return cachedRituals;
    } catch (e) {
      developer.log('Error in getRituals: $e', name: 'RitualsRepository');
      // Échec réseau : fallback sur le cache de CETTE clé, même expiré.
      // Échouer ("Réessayer" côté UI) seulement si aucun cache pour cette clé.
      final stale =
          await localDataSource.getRituals(cacheKey: cacheKey, allowStale: true);
      if (stale.isNotEmpty) {
        return stale;
      }
      rethrow;
    }
  }

  /// Récupère les rituels depuis l'API et les met en cache
  Future<List<RitualModel>> _fetchAndCacheRituals({
    String? userId,
    String? gender,
    String? states,
    String? lang,
    String? type,
  }) async {
    final cacheKey =
        cacheKeyFor(gender: gender, states: states, lang: lang, type: type);

    if (remoteDataSource == null) {
      return await localDataSource.getRituals(cacheKey: cacheKey);
    }

    try {
      final remoteData = await remoteDataSource!.getRituals(
        userId: userId,
        gender: gender,
        states: states,
        lang: lang,
        type: type,
      );
      final rituals = remoteData.map((data) => RitualModel.fromJson(data)).toList();

      // Déterminer la version de contenu maximale
      int? maxContentVersion;
      if (rituals.isNotEmpty && rituals.first.contentVersion != null) {
        maxContentVersion = rituals
            .map((r) => r.contentVersion ?? 0)
            .reduce((a, b) => a > b ? a : b);
      }

      // Sauvegarder dans le cache, sous la clé composite de la requête
      await localDataSource.saveRituals(rituals,
          contentVersion: maxContentVersion, cacheKey: cacheKey);
      developer.log(
        'Saved ${rituals.length} rituals to cache (key: $cacheKey, version: $maxContentVersion)',
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
      // Resynchroniser avec les paramètres de la dernière requête ciblée
      // (contenu réellement affiché), pas une requête neutre qui écraserait
      // le mauvais lot de cache.
      final last = await localDataSource.getLastRitualsQuery();
      await _fetchAndCacheRituals(
        userId: last?['userId'],
        gender: last?['gender'],
        states: last?['states'],
        lang: last?['lang'],
        type: last?['type'],
      );
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
    final bool offline =
        connectivityService != null && !connectivityService!.isConnected;
    List<DuaModel> cachedDuas = [];

    try {
      // Charger depuis le cache (stale accepté hors-ligne : mieux vaut du
      // contenu périmé que rien ; le TTL déclenchera un refresh en ligne).
      cachedDuas = await localDataSource.getDuas(allowStale: offline);
      developer.log(
        'Loaded ${cachedDuas.length} duas from cache',
        name: 'RitualsRepository',
      );

      // Si pas de connexion, retourner le cache
      if (offline) {
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
      // Échec réseau : servir le cache même expiré plutôt que rien.
      final stale = await localDataSource.getDuas(allowStale: true);
      if (stale.isNotEmpty) {
        return stale;
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

