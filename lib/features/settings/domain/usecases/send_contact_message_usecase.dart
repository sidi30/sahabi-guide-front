import '../../data/models/contact_message_model.dart';
import '../repositories/contact_message_repository.dart';

class SendContactMessageUseCase {
  final ContactMessageRepository repository;

  SendContactMessageUseCase(this.repository);

  Future<ContactMessageModel> call(ContactMessageModel message) async {
    return await repository.sendMessage(message);
  }
}

