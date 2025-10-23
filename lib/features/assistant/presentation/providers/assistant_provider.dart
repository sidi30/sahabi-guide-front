import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/datasources/assistant_remote_data_source.dart';
import '../../data/datasources/assistant_local_data_source.dart';
import '../../data/services/bot_service.dart';
import '../../data/services/assistant_notification_service.dart';
import '../../data/services/assistant_sync_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../../../core/utils/constants.dart';

// --- Providers de dépendances ---

final loggerProvider = Provider<Logger>((ref) => Logger());

final dioProvider = Provider<Dio>((ref) {
  // Détermine l'URL selon la plateforme
  final String baseUrl = kIsWeb 
      ? 'http://localhost:8084/api/v1'  // Web : localhost
      : AppConstants.apiBaseUrl + '/api/v1';  // Android/iOS : 10.0.2.2 ou IP
  
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  // TODO: Ajouter les intercepteurs d'authentification si nécessaire
  
  return dio;
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final flutterLocalNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

// --- Data Sources ---

final assistantRemoteDataSourceProvider = Provider<AssistantRemoteDataSource>((ref) {
  return AssistantRemoteDataSource(
    dio: ref.watch(dioProvider),
    logger: ref.watch(loggerProvider),
  );
});

final assistantLocalDataSourceProvider = Provider<AssistantLocalDataSource>((ref) {
  return AssistantLocalDataSource(
    logger: ref.watch(loggerProvider),
  );
});

// --- Services ---

final assistantNotificationServiceProvider = Provider<AssistantNotificationService>((ref) {
  return AssistantNotificationService(
    notifications: ref.watch(flutterLocalNotificationsProvider),
    logger: ref.watch(loggerProvider),
  );
});

final assistantSyncServiceProvider = Provider<AssistantSyncService>((ref) {
  return AssistantSyncService(
    remoteDataSource: ref.watch(assistantRemoteDataSourceProvider),
    localDataSource: ref.watch(assistantLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
    logger: ref.watch(loggerProvider),
  );
});

final botServiceProvider = Provider<BotService>((ref) {
  return BotService(
    remoteDataSource: ref.watch(assistantRemoteDataSourceProvider),
    localDataSource: ref.watch(assistantLocalDataSourceProvider),
    notificationService: ref.watch(assistantNotificationServiceProvider),
    syncService: ref.watch(assistantSyncServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// --- État du chat ---

class AssistantChatState {
  final List<ChatMessageModel> messages;
  final List<String> currentQuickReplies;
  final String? currentAnswerType;
  final bool isProcessing;
  final String? error;

  AssistantChatState({
    this.messages = const [],
    this.currentQuickReplies = const [],
    this.currentAnswerType,
    this.isProcessing = false,
    this.error,
  });

  AssistantChatState copyWith({
    List<ChatMessageModel>? messages,
    List<String>? currentQuickReplies,
    String? currentAnswerType,
    bool? isProcessing,
    String? error,
  }) {
    return AssistantChatState(
      messages: messages ?? this.messages,
      currentQuickReplies: currentQuickReplies ?? this.currentQuickReplies,
      currentAnswerType: currentAnswerType ?? this.currentAnswerType,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}

// --- Notifier ---

class AssistantChatNotifier extends StateNotifier<AsyncValue<AssistantChatState>> {
  final BotService botService;
  final String userId;

  AssistantChatNotifier({
    required this.botService,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await botService.initialize(userId);
      
      // Charge l'historique
      final messages = await botService.getChatHistory();
      
      // Génère le premier message si nécessaire
      if (messages.isEmpty) {
        await _generateBotMessage();
      } else {
        await _loadCurrentState();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _loadCurrentState() async {
    try {
      final messages = await botService.getChatHistory();
      final currentStep = botService.getCurrentStep();
      
      state = AsyncValue.data(AssistantChatState(
        messages: messages,
        currentQuickReplies: currentStep != null ? _getQuickReplies(currentStep.answerType, currentStep.answerOptions) : [],
        currentAnswerType: currentStep?.answerType,
        isProcessing: false,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> startConversation() async {
    state = const AsyncValue.loading();
    
    try {
      await botService.startOrResumeSession();
      await _generateBotMessage();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendAnswer(String answer) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Met à jour l'état en "processing"
    state = AsyncValue.data(currentState.copyWith(isProcessing: true));

    try {
      // Envoie la réponse au bot
      final botResponse = await botService.handleUserAnswer(answer);
      
      // Recharge l'historique
      final messages = await botService.getChatHistory();
      final currentStep = botService.getCurrentStep();
      
      state = AsyncValue.data(AssistantChatState(
        messages: messages,
        currentQuickReplies: currentStep != null 
            ? _getQuickReplies(currentStep.answerType, currentStep.answerOptions) 
            : [],
        currentAnswerType: currentStep?.answerType,
        isProcessing: false,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _generateBotMessage() async {
    try {
      final message = await botService.generateBotMessage();
      
      if (message != null) {
        final messages = await botService.getChatHistory();
        final currentStep = botService.getCurrentStep();
        
        state = AsyncValue.data(AssistantChatState(
          messages: messages,
          currentQuickReplies: currentStep != null 
              ? _getQuickReplies(currentStep.answerType, currentStep.answerOptions) 
              : [],
          currentAnswerType: currentStep?.answerType,
          isProcessing: false,
        ));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<String> _getQuickReplies(String answerType, List<String>? options) {
    switch (answerType) {
      case 'YES_NO':
        return ['Oui', 'Non'];
      case 'MULTIPLE_CHOICE':
        return options ?? [];
      default:
        return [];
    }
  }

  Future<void> restartConversation() async {
    state = const AsyncValue.loading();
    
    try {
      await botService.restartConversation();
      await _generateBotMessage();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    return await botService.getProgressStats();
  }

  Future<void> syncNow() async {
    // La synchronisation se fait en arrière-plan via le SyncService
    await botService.syncService.forceSyncNow();
  }
}

// --- Provider principal ---

final assistantChatProvider = StateNotifierProvider.autoDispose<
    AssistantChatNotifier, AsyncValue<AssistantChatState>>((ref) {
  
  // TODO: Récupérer le vrai userId depuis l'authentification
  // UUID d'utilisateur réel existant (Ahmed Ben Ali)
  const userId = '550e8400-e29b-41d4-a716-446655440020';
  
  final botService = ref.watch(botServiceProvider);
  
  final notifier = AssistantChatNotifier(
    botService: botService,
    userId: userId,
  );
  
  ref.onDispose(() {
    botService.dispose();
  });
  
  return notifier;
});

