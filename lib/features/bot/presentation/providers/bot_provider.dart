import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../../data/models/bot_message_model.dart';
import '../../data/services/bot_service.dart';
import '../../data/services/hajj_chat_api.dart';
import '../../data/services/knowledge_base_service.dart';
import '../../data/services/context_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/llm_service.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';
import 'package:sahabi_guide/core/di/injection_container.dart';

/// Provider pour le logger
final loggerProvider = Provider<Logger>((ref) => Logger());

/// Provider pour Dio
final dioProvider = Provider<Dio>((ref) => Dio());

/// Provider pour KnowledgeBaseService
final knowledgeBaseServiceProvider = Provider<KnowledgeBaseService>((ref) {
  final logger = ref.watch(loggerProvider);
  return KnowledgeBaseService(logger: logger);
});

/// Provider pour ContextService
final contextServiceProvider = Provider<ContextService>((ref) {
  final logger = ref.watch(loggerProvider);
  return ContextService(logger: logger);
});

/// Provider pour NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final contextService = ref.watch(contextServiceProvider);
  final logger = ref.watch(loggerProvider);
  return NotificationService(
    contextService: contextService,
    logger: logger,
  );
});

/// Provider pour StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final logger = ref.watch(loggerProvider);
  return StorageService(logger: logger);
});

/// Provider pour LLMService
final llmServiceProvider = Provider<LLMService>((ref) {
  final dio = ref.watch(dioProvider);
  final storageService = ref.watch(storageServiceProvider);
  final logger = ref.watch(loggerProvider);
  return LLMService(
    dio: dio,
    storageService: storageService,
    logger: logger,
  );
});

/// Provider pour HajjChatApi
final hajjChatApiProvider = Provider<HajjChatApi>((ref) {
  return HajjChatApi(sl<DioClient>());
});

/// Provider pour BotService
final botServiceProvider = Provider<BotService>((ref) {
  final knowledgeBase = ref.watch(knowledgeBaseServiceProvider);
  final contextService = ref.watch(contextServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final llmService = ref.watch(llmServiceProvider);
  final chatApi = ref.watch(hajjChatApiProvider);
  final logger = ref.watch(loggerProvider);

  return BotService(
    knowledgeBase: knowledgeBase,
    contextService: contextService,
    notificationService: notificationService,
    storageService: storageService,
    llmService: llmService,
    chatApi: chatApi,
    logger: logger,
  );
});

/// État du chat bot
class BotChatState {
  final List<BotMessageModel> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final int progressPercentage;
  final bool conversationStarted;

  const BotChatState({
    required this.messages,
    required this.isLoading,
    required this.isTyping,
    this.error,
    required this.progressPercentage,
    required this.conversationStarted,
  });

  factory BotChatState.initial() {
    return const BotChatState(
      messages: [],
      isLoading: false,
      isTyping: false,
      progressPercentage: 0,
      conversationStarted: false,
    );
  }

  BotChatState copyWith({
    List<BotMessageModel>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    int? progressPercentage,
    bool? conversationStarted,
  }) {
    return BotChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      conversationStarted: conversationStarted ?? this.conversationStarted,
    );
  }
}

/// Notifier pour gérer l'état du chat
class BotChatNotifier extends StateNotifier<BotChatState> {
  final BotService botService;
  final Logger logger;

  BotChatNotifier({
    required this.botService,
    required this.logger,
  }) : super(BotChatState.initial());

  /// Initialise le bot
  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await botService.initialize();
      
      state = state.copyWith(isLoading: false, error: null);
      logger.i('✅ BotChatNotifier initialized');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing bot: $e', stackTrace: stackTrace);
      
      // Message d'erreur plus clair pour l'utilisateur
      String userMessage = 'Impossible d\'initialiser l\'assistant.';
      if (e.toString().contains('knowledge base')) {
        userMessage = 'Erreur de chargement de la base de connaissances. Vérifiez que les fichiers de données sont présents.';
      } else if (e.toString().contains('storage')) {
        userMessage = 'Erreur d\'accès au stockage local.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: userMessage,
      );
    }
  }

  /// Démarre la conversation
  Future<void> startConversation({String locale = 'fr'}) async {
    try {
      state = state.copyWith(isTyping: true);
      
      await botService.startConversation(locale: locale);
      
      // Simule un délai pour l'effet de frappe
      await Future.delayed(const Duration(milliseconds: 800));
      
      final allMessages = botService.getMessageHistory();
      final progress = botService.getProgressPercentage();
      
      state = state.copyWith(
        messages: allMessages,
        isTyping: false,
        progressPercentage: progress,
        conversationStarted: true,
      );
      
      logger.d('Conversation started');
    } catch (e, stackTrace) {
      logger.e('❌ Error starting conversation: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// Envoie une réponse
  Future<void> sendAnswer(String answer, {String locale = 'fr'}) async {
    if (answer.trim().isEmpty) return;

    try {
      state = state.copyWith(isTyping: true);
      
      // Le message utilisateur est ajouté automatiquement par BotService
      await botService.handleAnswer(answer, locale: locale);
      
      // Simule un délai pour l'effet de frappe du bot
      await Future.delayed(const Duration(milliseconds: 800));
      
      final allMessages = botService.getMessageHistory();
      final progress = botService.getProgressPercentage();
      
      state = state.copyWith(
        messages: allMessages,
        isTyping: false,
        progressPercentage: progress,
      );
      
      logger.d('Answer sent: $answer');
    } catch (e, stackTrace) {
      logger.e('❌ Error sending answer: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// Recherche dans les FAQs
  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) return;

    try {
      state = state.copyWith(isTyping: true);
      
      await botService.searchFAQs(question);
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      final allMessages = botService.getMessageHistory();
      
      state = state.copyWith(
        messages: allMessages,
        isTyping: false,
      );
      
      logger.d('Question asked: $question');
    } catch (e, stackTrace) {
      logger.e('❌ Error asking question: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// Redémarre la conversation
  Future<void> restartConversation({String locale = 'fr'}) async {
    try {
      state = BotChatState.initial().copyWith(isTyping: true);
      
      await botService.initialize();
      await startConversation(locale: locale);
      
      logger.d('Conversation restarted');
    } catch (e, stackTrace) {
      logger.e('❌ Error restarting conversation: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// Récupère les statistiques
  Map<String, dynamic> getStats() {
    return botService.getStats();
  }

  @override
  void dispose() {
    botService.dispose();
    super.dispose();
  }
}

/// Provider principal du chat bot
final botChatProvider = StateNotifierProvider<BotChatNotifier, BotChatState>((ref) {
  final botService = ref.watch(botServiceProvider);
  final logger = ref.watch(loggerProvider);
  
  final notifier = BotChatNotifier(
    botService: botService,
    logger: logger,
  );
  
  // Initialise automatiquement
  Future.microtask(() => notifier.initialize());
  
  return notifier;
});

