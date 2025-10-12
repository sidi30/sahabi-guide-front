import '../../data/models/contact_message_model.dart';

abstract class ContactMessageRepository {
  Future<ContactMessageModel> sendMessage(ContactMessageModel message);
  Future<List<ContactMessageModel>> getMyMessages();
  Future<ContactMessageModel> getMessage(String id);
}

