import '../../data/models/contact_message_model.dart';
import '../repositories/contact_message_repository.dart';

class GetMyMessagesUseCase {
  final ContactMessageRepository repository;

  GetMyMessagesUseCase(this.repository);

  Future<List<ContactMessageModel>> call() async {
    return await repository.getMyMessages();
  }
}

