import 'package:dio/dio.dart';
import '../models/contact_message_model.dart';

abstract class ContactMessageRemoteDataSource {
  Future<ContactMessageModel> sendMessage(ContactMessageModel message, String? token);
  Future<List<ContactMessageModel>> getMyMessages(String token);
  Future<ContactMessageModel> getMessage(String id, String token);
}

class ContactMessageRemoteDataSourceImpl implements ContactMessageRemoteDataSource {
  final Dio dioClient;

  ContactMessageRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ContactMessageModel> sendMessage(ContactMessageModel message, String? token) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dioClient.post(
        '/api/contact',
        data: message.toJson(),
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ContactMessageModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      throw Exception('Erreur d\'envoi du message: $e');
    }
  }

  @override
  Future<List<ContactMessageModel>> getMyMessages(String token) async {
    try {
      final response = await dioClient.get(
        '/api/contact/my-messages',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ContactMessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des messages');
      }
    } catch (e) {
      throw Exception('Erreur de récupération des messages: $e');
    }
  }

  @override
  Future<ContactMessageModel> getMessage(String id, String token) async {
    try {
      final response = await dioClient.get(
        '/api/contact/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ContactMessageModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la récupération du message');
      }
    } catch (e) {
      throw Exception('Erreur de récupération du message: $e');
    }
  }
}

