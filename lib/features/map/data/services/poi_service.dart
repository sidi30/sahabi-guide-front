import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/poi_model.dart';

/// Résultat d'un chargement de POI, en distinguant réseau et cache local :
/// la carte doit pouvoir dire au pèlerin « données du 12/07, hors-ligne ».
class PoiFetchResult {
  final List<PoiModel> pois;
  final bool fromCache;
  final DateTime? cachedAt;

  const PoiFetchResult({
    required this.pois,
    required this.fromCache,
    this.cachedAt,
  });
}

class PoiService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;
  final CacheService? _cacheService;

  // Toggle pour utiliser l'API réelle ou les données de test
  static const bool _useRealApi = true; // ✅ Activé - API backend disponible

  /// Clé de cache des POI. TTL volontairement très long : sur place le réseau
  /// est souvent inutilisable, et des POI un peu datés valent mieux qu'un
  /// écran vide (l'âge est affiché à l'utilisateur).
  static const String _cacheKey = 'geo_pois_all';
  static const String _myPoisCacheKey = 'geo_pois_mine';
  static const Duration _cacheTtl = Duration(days: 365);

  PoiService({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
    CacheService? cacheService,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage,
        _cacheService = cacheService;

  String get _baseEndpoint => _useRealApi ? '/api/v1/geo/pois' : '/api/v1/poi';

  /// Lieux ATTRIBUÉS au pèlerin depuis le back-office : son hôtel, son point
  /// de rassemblement, et ce qui est rattaché à son hôtel (restaurant,
  /// pharmacie, mosquée). Nécessite un jeton pèlerin.
  ///
  /// Mis en cache séparément des POI généraux : c'est la liste dont le pèlerin
  /// a besoin en priorité, et elle doit rester consultable hors ligne.
  Future<PoiFetchResult> loadMyPois() async {
    try {
      final response = await _dioClient.get('$_baseEndpoint/mine');
      if (response.statusCode != 200) {
        throw Exception('Échec de récupération des lieux attribués: '
            '${response.statusCode}');
      }

      final data = response.data;
      final poisList = data is List ? data : (data['content'] as List? ?? []);
      final pois = poisList
          .map((json) => PoiModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('✅ ${pois.length} lieu(x) attribué(s) récupéré(s)');
      await _cachePois(pois, key: _myPoisCacheKey);
      return PoiFetchResult(pois: pois, fromCache: false);
    } catch (e) {
      AppLogger.warning('Lieux attribués indisponibles, repli sur le cache',
          error: e);
      final cached = await getCachedPois(key: _myPoisCacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// POI mis en cache lors du dernier chargement réussi. Utilisable sans réseau.
  Future<PoiFetchResult?> getCachedPois({String key = _cacheKey}) async {
    final cache = _cacheService;
    if (cache == null) return null;
    try {
      final entry = await cache.get<List<dynamic>>(key);
      if (entry == null) return null;
      final pois = entry.data
          .whereType<Map<String, dynamic>>()
          .map(PoiModel.fromJson)
          .toList();
      if (pois.isEmpty) return null;
      return PoiFetchResult(
        pois: pois,
        fromCache: true,
        cachedAt: entry.timestamp,
      );
    } catch (e) {
      AppLogger.warning('Cache POI illisible', error: e);
      return null;
    }
  }

  /// Charge les POI depuis l'API et met le cache à jour.
  /// En cas d'échec réseau, retombe sur le cache plutôt que sur une liste vide.
  Future<PoiFetchResult> loadPois() async {
    try {
      final response = await _dioClient.get(_baseEndpoint);
      if (response.statusCode != 200) {
        throw Exception('Échec de récupération des POI: ${response.statusCode}');
      }

      final data = response.data;
      final poisList = data is List ? data : (data['content'] as List? ?? []);
      final pois = poisList
          .map((json) => PoiModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('✅ ${pois.length} POI récupérés');
      await _cachePois(pois);
      return PoiFetchResult(pois: pois, fromCache: false);
    } catch (e) {
      AppLogger.warning('POI réseau indisponible, repli sur le cache', error: e);
      final cached = await getCachedPois();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> _cachePois(List<PoiModel> pois, {String key = _cacheKey}) async {
    final cache = _cacheService;
    if (cache == null || pois.isEmpty) return;
    try {
      await cache.set<List<Map<String, dynamic>>>(
        key: key,
        data: pois.map((p) => p.toJson()).toList(),
        ttl: _cacheTtl,
      );
    } catch (e) {
      AppLogger.warning('Écriture du cache POI impossible', error: e);
    }
  }

  /// Récupère un POI spécifique par ID
  Future<PoiModel?> getPoiById(String id) async {
    try {
      AppLogger.info('📍 Récupération du POI avec ID: $id');
      final response = await _dioClient.get('$_baseEndpoint/$id');
      
      if (response.statusCode == 200) {
        final poi = PoiModel.fromJson(response.data as Map<String, dynamic>);
        AppLogger.info('✅ POI récupéré: ${poi.name}');
        return poi;
      } else {
        throw Exception('Échec de récupération du POI: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération du POI: $e');
      return null;
    }
  }

  /// Appelle le guide via l'API backend
  Future<void> callGuide() async {
    try {
      AppLogger.info('📞 Appel du guide...');
      final token = await _secureStorage.read(key: 'auth_token');
      
      const endpoint = _useRealApi 
          ? '/api/v1/guide/call' 
          : '/api/v1/poi/guide/call';
      
      final response = await _dioClient.post(
        endpoint,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ Guide appelé avec succès');
      } else {
        throw Exception('Échec de l\'appel du guide: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de l\'appel du guide: $e');
      rethrow;
    }
  }

  /// Déclenche une alerte d'urgence via l'API backend
  Future<void> triggerEmergency() async {
    try {
      AppLogger.info('🚨 Déclenchement de l\'urgence...');
      final token = await _secureStorage.read(key: 'auth_token');
      
      // TODO: Vérifier le bon endpoint d'urgence dans le backend
      const endpoint = '/api/v1/alerts/emergency';
      
      final response = await _dioClient.post(
        endpoint,
        data: {
          'type': 'EMERGENCY',
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ Urgence déclenchée avec succès');
      } else {
        throw Exception('Échec du déclenchement d\'urgence: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors du déclenchement d\'urgence: $e');
      rethrow;
    }
  }

}
