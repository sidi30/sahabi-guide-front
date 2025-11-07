import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/emergency_contact_model.dart';
import '../../../../core/network/dio_client.dart';

class EmergencyContactsService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  EmergencyContactsService({
    required DioClient dioClient,
    required FlutterSecureStorage secureStorage,
  }) : _dioClient = dioClient,
       _secureStorage = secureStorage;

  /// Récupère tous les contacts d'urgence
  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await _dioClient.dio.get(
        '/api/v1/emergency-contacts',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> contactsJson = response.data;
        return contactsJson.map((json) => EmergencyContactModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des contacts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère un contact d'urgence par ID
  Future<EmergencyContactModel> getEmergencyContact(String contactId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await _dioClient.dio.get(
        '/api/v1/emergency-contacts/$contactId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return EmergencyContactModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du chargement du contact: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Crée un nouveau contact d'urgence
  Future<EmergencyContactModel> createEmergencyContact({
    required String name,
    required String phone,
    String? relation,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final contactData = {
        'fullName': name,
        'phone': phone,
        'relationship': relation,
        'isPrimary': isPrimary,
      };

      final response = await _dioClient.dio.post(
        '/api/v1/emergency-contacts',
        data: contactData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return EmergencyContactModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la création du contact: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour un contact d'urgence
  Future<EmergencyContactModel> updateEmergencyContact(
    String contactId, {
    required String name,
    required String phone,
    String? relation,
    bool isPrimary = false,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final contactData = {
        'fullName': name,
        'phone': phone,
        'relationship': relation,
        'isPrimary': isPrimary,
      };

      final response = await _dioClient.dio.put(
        '/api/v1/emergency-contacts/$contactId',
        data: contactData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return EmergencyContactModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la mise à jour du contact: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Supprime un contact d'urgence
  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await _dioClient.dio.delete(
        '/api/v1/emergency-contacts/$contactId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du contact: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Appelle un contact d'urgence
  Future<void> callEmergencyContact(String phone) async {
    try {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Impossible d\'appeler ce numéro');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel: $e');
    }
  }
}
