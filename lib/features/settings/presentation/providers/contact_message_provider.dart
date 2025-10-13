import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/contact_message_model.dart';
import '../../domain/usecases/send_contact_message_usecase.dart';
import '../../domain/usecases/get_my_messages_usecase.dart';

// Provider pour récupérer mes messages de contact
final myContactMessagesProvider = FutureProvider<List<ContactMessageModel>>((ref) async {
  final getMyMessagesUseCase = sl<GetMyMessagesUseCase>();
  try {
    return await getMyMessagesUseCase();
  } catch (e) {
    print('Erreur récupération messages: $e');
    return [];
  }
});

// État pour l'envoi de message
class ContactMessageState {
  final bool isLoading;
  final String? error;
  final ContactMessageModel? sentMessage;

  ContactMessageState({
    this.isLoading = false,
    this.error,
    this.sentMessage,
  });

  ContactMessageState copyWith({
    bool? isLoading,
    String? error,
    ContactMessageModel? sentMessage,
  }) {
    return ContactMessageState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sentMessage: sentMessage ?? this.sentMessage,
    );
  }
}

// Notifier pour gérer l'envoi de messages
class ContactMessageNotifier extends StateNotifier<ContactMessageState> {
  final SendContactMessageUseCase sendContactMessageUseCase;

  ContactMessageNotifier({
    required this.sendContactMessageUseCase,
  }) : super(ContactMessageState());

  Future<bool> sendMessage(ContactMessageModel message) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sentMessage = await sendContactMessageUseCase(message);
      state = ContactMessageState(
        isLoading: false,
        sentMessage: sentMessage,
      );
      return true;
    } catch (e) {
      state = ContactMessageState(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void resetState() {
    state = ContactMessageState();
  }
}

// Provider pour le notifier
final contactMessageNotifierProvider = StateNotifierProvider<ContactMessageNotifier, ContactMessageState>((ref) {
  return ContactMessageNotifier(
    sendContactMessageUseCase: sl<SendContactMessageUseCase>(),
  );
});


