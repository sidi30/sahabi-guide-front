import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';

class AlertsService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  AlertsService({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
  }) : _dioClient = dioClient,
       _secureStorage = secureStorage;

  /// Récupère toutes les alertes d'un pèlerin
  Future<List<AlertModel>> getPilgrimAlerts(String pilgrimId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await _dioClient.dio.get(
        '/api/v1/pilgrims/$pilgrimId/alerts',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = response.data;
        return alertsJson.map((json) => AlertModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des alertes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère les alertes avec pagination (pour admin)
  Future<List<AlertModel>> getAlerts({
    String? status,
    String? pilgrimId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (status != null) queryParams['status'] = status;
      if (pilgrimId != null) queryParams['pilgrimId'] = pilgrimId;

      final response = await _dioClient.dio.get(
        '/api/v1/alerts',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = response.data;
        return alertsJson.map((json) => AlertModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des alertes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Crée une nouvelle alerte
  Future<AlertModel> createAlert({
    String? pilgrimId,
    required AlertType type,
    required String title,
    required String message,
    AlertPriority priority = AlertPriority.medium,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final alertData = {
        if (pilgrimId != null) 'pilgrimId': pilgrimId,
        'type': type.name,
        'title': title,
        'message': message,
        'priority': priority.name,
        if (payload != null) 'payload': payload,
      };

      final response = await _dioClient.dio.post(
        '/api/v1/alerts',
        data: alertData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AlertModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la création de l\'alerte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Marque une alerte comme lue (endpoint personnalisé - à ajouter au backend)
  Future<void> markAsRead(String alertId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      // Pour l'instant on simule - il faudra ajouter cet endpoint au backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Implémenter l'endpoint réel
      // final response = await _dioClient.dio.patch(
      //   '/api/v1/alerts/$alertId/read',
      //   options: Options(
      //     headers: {'Authorization': 'Bearer $token'},
      //   ),
      // );
      
      AppLogger.debug('Alerte $alertId marquée comme lue');
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Résout une alerte (endpoint personnalisé - à ajouter au backend)
  Future<void> resolveAlert(String alertId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      // Pour l'instant on simule - il faudra ajouter cet endpoint au backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Implémenter l'endpoint réel
      // final response = await _dioClient.dio.patch(
      //   '/api/v1/alerts/$alertId/resolve',
      //   options: Options(
      //     headers: {'Authorization': 'Bearer $token'},
      //   ),
      // );
      
      AppLogger.debug('Alerte $alertId résolue');
    } catch (e) {
      throw Exception('Erreur lors de la résolution: $e');
    }
  }
}












