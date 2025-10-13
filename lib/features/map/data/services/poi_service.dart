import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/poi_model.dart';

class PoiService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  PoiService({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  /// Récupère tous les POI depuis le backend
  Future<List<PoiModel>> getAllPois() async {
    try {
      AppLogger.info('📍 Récupération de tous les POI...');
      final response = await _dioClient.get('/api/v1/poi');
      
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
      rethrow;
    }
  }

  /// Récupère les POI filtrés par type
  Future<List<PoiModel>> getPoisByType(String type) async {
    try {
      AppLogger.info('📍 Récupération des POI de type: $type');
      final response = await _dioClient.get('/api/v1/poi', queryParameters: {'type': type});
      
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
      rethrow;
    }
  }

  /// Récupère un POI spécifique par ID
  Future<PoiModel> getPoiById(String id) async {
    try {
      AppLogger.info('📍 Récupération du POI avec ID: $id');
      final response = await _dioClient.get('/api/v1/poi/$id');
      
      if (response.statusCode == 200) {
        final poi = PoiModel.fromJson(response.data as Map<String, dynamic>);
        AppLogger.info('✅ POI récupéré: ${poi.name}');
        return poi;
      } else {
        throw Exception('Échec de récupération du POI: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération du POI: $e');
      rethrow;
    }
  }

  /// Appelle le guide via l'API backend
  Future<void> callGuide() async {
    try {
      AppLogger.info('📞 Appel du guide...');
      final token = await _secureStorage.read(key: 'auth_token');
      
      final response = await _dioClient.post(
        '/api/v1/guide/call',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
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
      
      final response = await _dioClient.post(
        '/api/v1/urgency',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
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

