import '../../domain/repositories/contact_message_repository.dart';
import '../datasources/contact_message_remote_data_source.dart';
import '../models/contact_message_model.dart';
import '../../../auth/data/datasources/passport_auth_local_data_source.dart';

class ContactMessageRepositoryImpl implements ContactMessageRepository {
  final ContactMessageRemoteDataSource remoteDataSource;
  final PassportAuthLocalDataSource authLocalDataSource;

  ContactMessageRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  Future<String?> _getToken() async {
    try {
      return await authLocalDataSource.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ContactMessageModel> sendMessage(ContactMessageModel message) async {
    try {
      // Récupérer le token (peut être null si non authentifié)
      final token = await _getToken();
      
      final sentMessage = await remoteDataSource.sendMessage(message, token);
      return sentMessage;
    } catch (e) {
      throw Exception('Erreur d\'envoi du message: $e');
    }
  }

  @override
  Future<List<ContactMessageModel>> getMyMessages() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }
      
      return await remoteDataSource.getMyMessages(token);
    } catch (e) {
      throw Exception('Erreur de récupération des messages: $e');
    }
  }

  @override
  Future<ContactMessageModel> getMessage(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }
      
      return await remoteDataSource.getMessage(id, token);
    } catch (e) {
      throw Exception('Erreur de récupération du message: $e');
    }
  }
}

