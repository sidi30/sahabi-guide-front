import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../../data/models/bot_message_model.dart';
import '../../data/services/bot_service.dart';
import '../../data/services/hajj_chat_api.dart';
import '../../data/services/translate_api.dart';
import '../../data/services/knowledge_base_service.dart';
import '../../data/services/context_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/llm_service.dart';
import '../../data/services/voice_service.dart';
import '../../data/services/voice_remote_api.dart';
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
  return StorageService();
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

/// Provider pour TranslateApi (traduction batch de l'historique du chat)
final translateApiProvider = Provider<TranslateApi>((ref) {
  final logger = ref.watch(loggerProvider);
  return TranslateApi(sl<DioClient>(), logger: logger);
});

/// Provider pour VoiceRemoteApi (microservice voix backend)
final voiceRemoteApiProvider = Provider<VoiceRemoteApi>((ref) {
  final logger = ref.watch(loggerProvider);
  return VoiceRemoteApi(sl<DioClient>(), logger: logger);
});

/// Provider pour VoiceService (STT + TTS multilingue)
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final logger = ref.watch(loggerProvider);
  final remoteApi = ref.watch(voiceRemoteApiProvider);
  final service = VoiceService(logger: logger, remoteApi: remoteApi);
  // Le service n'est disposé que lorsque le provider lui-même est détruit,
  // pas à chaque fermeture de la page chat (sinon AudioPlayer/TTS resteraient
  // morts pour la session suivante).
  ref.onDispose(() => service.dispose());
  return service;
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

  /// Vrai pendant la traduction de l'historique au changement de langue.
  /// Permet d'afficher un indicateur discret sans bloquer le chat.
  final bool isTranslating;

  const BotChatState({
    required this.messages,
    required this.isLoading,
    required this.isTyping,
    this.error,
    required this.progressPercentage,
    required this.conversationStarted,
    this.isTranslating = false,
  });

  factory BotChatState.initial() {
    return const BotChatState(
      messages: [],
      isLoading: false,
      isTyping: false,
      progressPercentage: 0,
      conversationStarted: false,
      isTranslating: false,
    );
  }

  BotChatState copyWith({
    List<BotMessageModel>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    int? progressPercentage,
    bool? conversationStarted,
    bool? isTranslating,
  }) {
    return BotChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      conversationStarted: conversationStarted ?? this.conversationStarted,
      isTranslating: isTranslating ?? this.isTranslating,
    );
  }
}

/// Notifier pour gérer l'état du chat
class BotChatNotifier extends StateNotifier<BotChatState> {
  final BotService botService;
  final TranslateApi translateApi;
  final Logger logger;

  /// Langue dans laquelle l'historique est ACTUELLEMENT affiché. Sert à éviter
  /// de re-traduire inutilement quand on rebascule sur la même langue.
  String? _displayLang;

  BotChatNotifier({
    required this.botService,
    required this.translateApi,
    required this.logger,
  }) : super(BotChatState.initial());

  /// Initialise le bot. Protege contre les setState() apres dispose
  /// (utilisateur quittant la page pendant l'init async).
  Future<void> initialize() async {
    if (!mounted) return;
    try {
      state = state.copyWith(isLoading: true, error: null);

      await botService.initialize();

      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: null);
      logger.i('✅ BotChatNotifier initialized');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing bot: $e', stackTrace: stackTrace);

      String userMessage = 'Impossible d\'initialiser l\'assistant.';
      if (e.toString().contains('knowledge base')) {
        userMessage = 'Erreur de chargement de la base de connaissances. Vérifiez que les fichiers de données sont présents.';
      } else if (e.toString().contains('storage')) {
        userMessage = 'Erreur d\'accès au stockage local.';
      }

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: userMessage,
      );
    }
  }

  /// Setter securise : n'applique state que si le notifier est toujours monte.
  /// Evite les exceptions "markNeedsBuild on defunct element" quand l'utilisateur
  /// quitte la page avant la fin d'une operation asynchrone.
  void _safeState(BotChatState next) {
    if (!mounted) return;
    state = next;
  }

  /// Démarre la conversation
  Future<void> startConversation({String locale = 'fr'}) async {
    try {
      _safeState(state.copyWith(isTyping: true));

      await botService.startConversation(locale: locale);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      final allMessages = botService.getMessageHistory();
      final progress = botService.getProgressPercentage();

      // La conversation vient d'être produite dans `locale` : c'est la langue
      // d'affichage courante (point de départ pour les futures traductions).
      _displayLang = locale;

      _safeState(state.copyWith(
        messages: allMessages,
        isTyping: false,
        progressPercentage: progress,
        conversationStarted: true,
      ));

      logger.d('Conversation started');
    } catch (e, stackTrace) {
      logger.e('❌ Error starting conversation: $e', stackTrace: stackTrace);
      _safeState(state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      ));
    }
  }

  /// Envoie une réponse
  Future<void> sendAnswer(String answer, {String locale = 'fr'}) async {
    if (answer.trim().isEmpty) return;
    try {
      _safeState(state.copyWith(isTyping: true));

      await botService.handleAnswer(answer, locale: locale);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      final allMessages = botService.getMessageHistory();
      final progress = botService.getProgressPercentage();

      _displayLang = locale;

      _safeState(state.copyWith(
        messages: allMessages,
        isTyping: false,
        progressPercentage: progress,
      ));

      logger.d('Answer sent: $answer');
    } catch (e, stackTrace) {
      logger.e('❌ Error sending answer: $e', stackTrace: stackTrace);
      _safeState(state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      ));
    }
  }

  /// Recherche dans les FAQs avec langue configuree.
  Future<void> askQuestion(String question, {String language = 'fr'}) async {
    if (question.trim().isEmpty) return;
    try {
      _safeState(state.copyWith(isTyping: true));

      await botService.searchFAQs(question, language: language);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final allMessages = botService.getMessageHistory();
      _displayLang = language;
      _safeState(state.copyWith(
        messages: allMessages,
        isTyping: false,
      ));

      logger.d('Question asked: $question (lang=$language)');
    } catch (e, stackTrace) {
      logger.e('❌ Error asking question: $e', stackTrace: stackTrace);
      _safeState(state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      ));
    }
  }

  /// Redémarre la conversation
  Future<void> restartConversation({String locale = 'fr'}) async {
    try {
      _safeState(BotChatState.initial().copyWith(isTyping: true));

      await botService.initialize();
      if (!mounted) return;
      await startConversation(locale: locale);

      logger.d('Conversation restarted');
    } catch (e, stackTrace) {
      logger.e('❌ Error restarting conversation: $e', stackTrace: stackTrace);
      _safeState(state.copyWith(
        isTyping: false,
        error: 'Erreur: $e',
      ));
    }
  }

  /// Traduit l'historique du chat vers [targetLang] (`fr|en|ar|ha`) en UN SEUL
  /// appel batch. On traduit TOUJOURS depuis le texte d'origine de chaque
  /// message ([sourceContent] + [originalLang]) pour éviter de traduire une
  /// traduction et garder un re-switch fidèle. En cas d'échec réseau, on
  /// conserve le texte actuel (le chat n'est jamais cassé).
  ///
  /// Les `quickReplies` ne sont PAS envoyés ici : l'ensemble FIXE est localisé
  /// via l10n (clés `qr:*`) et re-rendu automatiquement avec la locale.
  Future<void> translateHistoryTo(String targetLang) async {
    // Première application : on mémorise juste la langue d'affichage courante.
    _displayLang ??= targetLang;
    if (_displayLang == targetLang) {
      _displayLang = targetLang;
      return;
    }

    final messages = state.messages;
    if (messages.isEmpty) {
      _displayLang = targetLang;
      return;
    }

    // Indices et textes source des messages à (re)traduire : on saute ceux dont
    // la langue d'origine est déjà la cible (on restaure alors l'original).
    final indices = <int>[];
    final texts = <String>[];
    final restored = List<BotMessageModel>.from(messages);

    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final src = m.sourceContent;
      if (src.trim().isEmpty) continue;
      if (m.originalLang == targetLang) {
        // La cible == langue d'origine : on réaffiche le texte d'origine.
        restored[i] = m.copyWith(content: src);
        continue;
      }
      indices.add(i);
      texts.add(src);
    }

    if (indices.isEmpty) {
      // Rien à traduire (tout est déjà en langue d'origine == cible).
      _safeState(state.copyWith(messages: restored));
      _displayLang = targetLang;
      return;
    }

    _safeState(state.copyWith(messages: restored, isTranslating: true));

    try {
      // Tous les messages partagent la même langue source dans la pratique
      // (la conversation est produite dans une langue à la fois), donc on passe
      // la langue d'origine du premier message comme indice `sourceLang`.
      final sourceLang = messages[indices.first].originalLang;
      final translations = await translateApi.translateBatch(
        texts: texts,
        targetLang: targetLang,
        sourceLang: sourceLang,
      );

      if (!mounted) return;

      final updated = List<BotMessageModel>.from(restored);
      for (var k = 0; k < indices.length; k++) {
        final i = indices[k];
        final translated = k < translations.length ? translations[k] : texts[k];
        updated[i] = updated[i].copyWith(content: translated);
      }

      _safeState(state.copyWith(messages: updated, isTranslating: false));
      _displayLang = targetLang;
      logger.d('Chat history translated to $targetLang '
          '(${indices.length} messages)');
    } catch (e, stackTrace) {
      logger.e('❌ Error translating history: $e', stackTrace: stackTrace);
      // On garde le texte actuel : pas de régression d'affichage.
      _safeState(state.copyWith(isTranslating: false));
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
  final translateApi = ref.watch(translateApiProvider);
  final logger = ref.watch(loggerProvider);

  final notifier = BotChatNotifier(
    botService: botService,
    translateApi: translateApi,
    logger: logger,
  );
  
  // Initialise automatiquement
  Future.microtask(() => notifier.initialize());
  
  return notifier;
});

