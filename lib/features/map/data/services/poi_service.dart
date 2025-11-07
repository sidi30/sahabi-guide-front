import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/poi_model.dart';

class PoiService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  // Toggle pour utiliser l'API réelle ou les données de test
  static const bool _useRealApi = true; // ✅ Activé - API backend disponible

  PoiService({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  String get _baseEndpoint => _useRealApi ? '/api/v1/geo/pois' : '/api/v1/poi';

  /// Récupère tous les POI depuis le backend
  Future<List<PoiModel>> getAllPois() async {
    try {
      AppLogger.info('📍 Récupération de tous les POI...');
      final response = await _dioClient.get(_baseEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final poisList = data is List ? data : (data['content'] as List? ?? []);
        
        final pois = poisList
            .map((json) => PoiModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        AppLogger.info('✅ ${pois.length} POI récupérés');
        return pois;
      } else {
        throw Exception('Échec de récupération des POI: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération des POI: $e');
      // Retourner une liste vide plutôt que de crasher
      return [];
    }
  }

  /// Récupère les POI filtrés par type
  Future<List<PoiModel>> getPoisByType(String type) async {
    try {
      AppLogger.info('📍 Récupération des POI de type: $type');
      
      // Convertir le type en format backend si nécessaire
      final backendType = _convertTypeToBackend(type);
      
      final response = await _dioClient.get(
        _baseEndpoint,
        queryParameters: {'type': backendType}
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final poisList = data is List ? data : (data['content'] as List? ?? []);
        
        final pois = poisList
            .map((json) => PoiModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        AppLogger.info('✅ ${pois.length} POI de type "$type" récupérés');
        return pois;
      } else {
        throw Exception('Échec de récupération des POI: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération des POI par type: $e');
      return [];
    }
  }

  /// Récupère les POI dans un rayon donné
  Future<List<PoiModel>> getPoisNearby({
    required double lat,
    required double lng,
    double radius = 10.0, // km
    String? type,
  }) async {
    if (!_useRealApi) {
      // L'API de test ne supporte pas la recherche géographique
      return getAllPois();
    }

    try {
      AppLogger.info('📍 Récupération des POI à proximité ($lat, $lng, rayon: ${radius}km)');
      
      final queryParams = <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius,
      };
      
      if (type != null) {
        queryParams['type'] = _convertTypeToBackend(type);
      }
      
      final response = await _dioClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final poisList = data is List ? data : (data['content'] as List? ?? []);
        
        final pois = poisList
            .map((json) => PoiModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        AppLogger.info('✅ ${pois.length} POI à proximité récupérés');
        return pois;
      } else {
        throw Exception('Échec de récupération des POI: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération des POI à proximité: $e');
      return [];
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

  /// Convertit un type frontend en type backend
  String _convertTypeToBackend(String type) {
    if (_useRealApi) {
      // Pour l'API réelle, utiliser les majuscules
      return type.toUpperCase();
    }
    // Pour l'API de test, utiliser les minuscules avec snake_case
    return type.toLowerCase();
  }
}
