import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/bot_message_model.dart';
import '../models/hajj_step_model.dart';
import '../models/ritual_context_model.dart';
import 'hajj_chat_api.dart';
import 'knowledge_base_service.dart';
import 'context_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'llm_service.dart';

/// Service principal du bot Hajj
/// Gère la conversation, la navigation entre étapes, les réponses
class BotService {
  final KnowledgeBaseService knowledgeBase;
  final ContextService contextService;
  final NotificationService? notificationService;
  final StorageService? storageService;
  final LLMService? llmService;
  final HajjChatApi? chatApi;
  final Logger logger;
  final Uuid uuid = const Uuid();

  // État de la conversation
  HajjStepModel? _currentStep;
  final List<BotMessageModel> _messageHistory = [];
  bool _conversationStarted = false;
  RitualContextModel? _lastContext;

  /// Estimated durations per ritual step (in minutes)
  static const Map<String, int> _ritualEstimatedMinutes = {
    'ihram': 30,
    'tawaf_arrival': 60,
    'sai': 90,
    'mina_day8': 720, // 12 hours
    'arafat': 480, // 8 hours (Dhuhr to Maghrib)
    'muzdalifah': 600, // 10 hours (night)
    'ramy_jamarat_day10': 60,
    'sacrifice': 120,
    'haircut': 15,
    'tawaf_ifadah': 60,
    'mina_days_tashriq': 720,
    'ramy_days_11_13': 60,
    'tawaf_wida': 60,
  };

  BotService({
    required this.knowledgeBase,
    required this.contextService,
    this.notificationService,
    this.storageService,
    this.llmService,
    this.chatApi,
    required this.logger,
  });

  /// Initialise le bot
  Future<void> initialize() async {
    try {
      logger.d('Initializing BotService...');
      
      // Initialise la base de connaissances
      await knowledgeBase.initialize();
      
      // Initialise les services optionnels
      await notificationService?.initialize();
      await storageService?.initialize();
      await llmService?.initialize();
      
      // Tente de restaurer l'état de la conversation
      if (storageService != null) {
        await _restoreConversationState();
      }
      
      // Charge la première étape si pas de restauration
      _currentStep ??= knowledgeBase.getFirstStep();
      
      if (_currentStep == null) {
        throw Exception('No first step found in knowledge base');
      }
      
      logger.i('✅ BotService initialized with first step: ${_currentStep!.name}');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing BotService: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Restaure l'état de la conversation depuis le storage
  Future<void> _restoreConversationState() async {
    try {
      final savedState = await storageService?.loadConversationState();
      final savedMessages = await storageService?.loadMessages() ?? [];
      
      if (savedState != null && savedMessages.isNotEmpty) {
        logger.d('Restoring conversation state...');
        
        _conversationStarted = savedState['conversationStarted'] as bool? ?? false;
        
        final stepId = savedState['currentStepId'] as String?;
        if (stepId != null) {
          _currentStep = knowledgeBase.getStepById(stepId);
        }
        
        _messageHistory.clear();
        _messageHistory.addAll(savedMessages);
        
        logger.i('✅ Conversation restored (${savedMessages.length} messages)');
      }
    } catch (e) {
      logger.w('Could not restore conversation state: $e');
    }
  }

  /// Démarre la conversation
  Future<BotMessageModel> startConversation({String locale = 'fr'}) async {
    if (_currentStep == null) {
      throw StateError('BotService not initialized');
    }

    _conversationStarted = true;
    
    // Récupère le contexte GPS
    _lastContext = await contextService.getCurrentContext();
    
    // Message de bienvenue contextuel
    String welcomeContent = '🕋 As-salamu alaykum ! Je suis votre assistant personnel pour le Hajj.\n\n';
    
    // Ajoute info de localisation si disponible
    if (_lastContext?.isInHolyPlace == true) {
      welcomeContent += '📍 Je vois que vous êtes à ${_lastContext!.currentLocation} !\n\n';
    }
    
    welcomeContent += 'Je vais vous guider étape par étape à travers tous les rituels. '
                      'Répondez simplement aux questions et je vous accompagnerai ! 🤲';
    
    final welcomeMessage = BotMessageModel.bot(
      id: uuid.v4(),
      content: welcomeContent,
      contentAr: 'السلام عليكم! أنا مساعدك الشخصي للحج.',
    );
    
    _messageHistory.add(welcomeMessage);
    await _saveMessage(welcomeMessage);
    
    // Planifie les notifications contextuelles si disponibles
    if (notificationService != null && _lastContext?.isInHolyPlace == true) {
      await notificationService!.scheduleContextualNotifications();
    }
    
    // Génère le premier message de question
    await Future.delayed(const Duration(milliseconds: 500));
    await _generateQuestionMessage(locale: locale);
    
    return welcomeMessage;
  }

  /// Génère un message de question pour l'étape actuelle
  Future<BotMessageModel> _generateQuestionMessage({
    required String locale,
  }) async {
    if (_currentStep == null) {
      throw StateError('No current step');
    }

    // Met à jour le contexte GPS
    _lastContext = await contextService.getCurrentContext();

    String content = _currentStep!.getLocalizedQuestion(locale);
    
    // Ajoute les rappels urgents du contexte GPS si présents
    if (_lastContext != null && _lastContext!.urgentReminders.isNotEmpty) {
      content += '\n\n⚠️ RAPPELS URGENTS :\n${_lastContext!.urgentReminders.join('\n')}';
    }
    
    // Ajoute les rappels urgents de la base de connaissances
    final urgentReminders = knowledgeBase.getUrgentReminders(_currentStep!.id);
    if (urgentReminders.isNotEmpty) {
      content += '\n\n${urgentReminders.join('\n')}';
    }
    
    // Ajoute les duas suggérées si présentes
    if (_lastContext != null && _lastContext!.suggestedDuas.isNotEmpty) {
      content += '\n\n🤲 DUAS RECOMMANDÉES :\n${_lastContext!.suggestedDuas.take(3).join('\n')}';
    }
    
    // Ajoute la description
    content += '\n\n💡 ${_currentStep!.description}';
    
    final message = BotMessageModel.bot(
      id: uuid.v4(),
      content: content,
      contentAr: _currentStep!.questionAr,
      quickReplies: _currentStep!.quickReplies,
      relatedStepId: _currentStep!.id,
      relatedRitualId: _currentStep!.relatedRitualId,
    );
    
    _messageHistory.add(message);
    await _saveMessage(message);
    await _saveConversationState();
    
    return message;
  }
  
  /// Sauvegarde un message
  Future<void> _saveMessage(BotMessageModel message) async {
    try {
      await storageService?.saveMessage(message);
    } catch (e) {
      logger.w('Could not save message: $e');
    }
  }
  
  /// Sauvegarde l'état de la conversation
  Future<void> _saveConversationState() async {
    try {
      await storageService?.saveConversationState(
        currentStepId: _currentStep?.id,
        currentOrder: _currentStep?.order ?? 0,
        conversationStarted: _conversationStarted,
      );
    } catch (e) {
      logger.w('Could not save conversation state: $e');
    }
  }

  /// Traite une réponse utilisateur
  Future<BotMessageModel> handleAnswer(
    String answer, {
    String locale = 'fr',
  }) async {
    if (_currentStep == null) {
      throw StateError('No current step');
    }

    // Enregistre le message utilisateur
    final userMessage = BotMessageModel.user(
      id: uuid.v4(),
      content: answer,
    );
    _messageHistory.add(userMessage);
    await _saveMessage(userMessage);

    // Si "Besoin d'aide", cherche dans les FAQs
    if (_isHelpRequest(answer)) {
      return await _handleHelpRequest(_currentStep!.id);
    }

    // Si "Recommencer"
    if (_normalizeAnswer(answer) == 'RECOMMENCER') {
      return await _restartConversation(locale: locale);
    }

    // Détermine l'étape suivante
    final nextStep = knowledgeBase.getNextStep(_currentStep!.id, answer);
    
    // Si c'était la dernière étape
    if (nextStep == null || _currentStep!.isFinal == true) {
      return await _handleConversationEnd();
    }
    
    // Passe à l'étape suivante
    _currentStep = nextStep;

    // Planifie les notifications si le contexte a changé
    if (notificationService != null) {
      await notificationService!.scheduleContextualNotifications();
    }

    // Schedule proactive reminder after estimated ritual duration
    final estimatedMinutes = _ritualEstimatedMinutes[_currentStep!.id] ?? 120;
    if (notificationService != null) {
      await notificationService!.scheduleRitualReminder(
        stepName: _currentStep!.name,
        delayMinutes: estimatedMinutes,
        message: '${_currentStep!.name} - Avez-vous terminé ce rituel ? Ouvrez l\'assistant pour confirmer.',
      );
    }

    // Génère le message de la nouvelle étape
    return await _generateQuestionMessage(locale: locale);
  }

  /// Traite une demande d'aide
  Future<BotMessageModel> _handleHelpRequest(String currentStepId) async {
    final relatedFAQs = knowledgeBase.searchFAQs(currentStepId, limit: 1);
    
    String helpContent;
    
    if (relatedFAQs.isNotEmpty) {
      final faq = relatedFAQs.first;
      helpContent = '❓ ${faq.question}\n\n${faq.answer}';
    } else {
      helpContent = '💡 Voici quelques informations supplémentaires :\n\n'
                    '${_currentStep?.description ?? 'Consultez la section Rituels pour plus de détails.'}';
    }
    
    final helpMessage = BotMessageModel.bot(
      id: uuid.v4(),
      content: helpContent,
      quickReplies: ['Compris', 'Autre question'],
    );
    
    _messageHistory.add(helpMessage);
    return helpMessage;
  }

  /// Recherche dans les FAQs
  Future<BotMessageModel> searchFAQs(String query) async {
    // Try API chat first (RAG + LLM)
    try {
      final apiResponse = await chatApi?.chat(query, 'fr');
      if (apiResponse != null && apiResponse['answer'] != null) {
        final answer = apiResponse['answer'] as String;
        final source = apiResponse['source'] as String? ?? 'api';
        String apiContent = '$answer';
        if (source == 'llm') apiContent += '\n\n💡 Réponse IA';
        // Skip the rest of FAQ search
        final message = BotMessageModel.bot(
          id: uuid.v4(),
          content: apiContent,
          quickReplies: ['Autre question', 'Continuer'],
        );
        _messageHistory.add(message);
        await _saveMessage(message);
        return message;
      }
    } catch (e) {
      logger.w('API chat failed, falling back to local: $e');
    }

    final faq = knowledgeBase.getBestFAQ(query);

    String content;
    
    if (faq != null) {
      content = '❓ ${faq.question}\n\n${faq.answer}';
      
      // Enrichissement optionnel avec LLM
      if (llmService != null && await llmService!.isAvailable()) {
        logger.d('Enriching FAQ response with LLM...');
        final enrichedContent = await llmService!.enrichResponse(
          originalResponse: content,
          userQuestion: query,
          context: _lastContext?.currentLocation,
        );
        
        if (enrichedContent != null && enrichedContent != content) {
          content = enrichedContent;
          content += '\n\n💡 Réponse enrichie par IA';
        }
      }
    } else {
      // Si pas de FAQ trouvée, essaye le LLM directement
      if (llmService != null && await llmService!.isAvailable()) {
        logger.d('Generating response with LLM...');
        final llmResponse = await llmService!.generateResponse(
          question: query,
          context: _lastContext?.currentLocation,
        );
        
        if (llmResponse != null) {
          content = '🤖 $llmResponse\n\n💡 Réponse générée par IA';
        } else {
          content = _getDefaultNoAnswerMessage();
        }
      } else {
        content = _getDefaultNoAnswerMessage();
      }
    }
    
    final message = BotMessageModel.bot(
      id: uuid.v4(),
      content: content,
      quickReplies: ['Autre question', 'Continuer'],
    );
    
    _messageHistory.add(message);
    await _saveMessage(message);
    return message;
  }
  
  /// Message par défaut quand aucune réponse n'est trouvée
  String _getDefaultNoAnswerMessage() {
    return '🤔 Je n\'ai pas trouvé de réponse exacte à votre question.\n\n'
           'Vous pouvez :\n'
           '- Reformuler votre question\n'
           '- Consulter la section "Rituels"\n'
           '- Poser une question plus générale';
  }

  /// Gère la fin de la conversation
  Future<BotMessageModel> _handleConversationEnd() async {
    final endMessage = BotMessageModel.bot(
      id: uuid.v4(),
      content: '🎉 Masha\'Allah ! Vous avez terminé toutes les étapes du Hajj !\n\n'
               '✨ Hajj Mabrour wa Sa\'y Mashkour !\n\n'
               'Qu\'Allah accepte votre Hajj et vos bonnes actions. '
               'N\'hésitez pas à revenir si vous avez des questions. 🤲',
      contentAr: '🎉 ماشاء الله! لقد أتممت جميع خطوات الحج!\n\n'
                 '✨ حج مبرور وسعي مشكور!',
      quickReplies: ['Alhamdulillah', 'Recommencer'],
    );
    
    _messageHistory.add(endMessage);
    return endMessage;
  }

  /// Redémarre la conversation
  Future<BotMessageModel> _restartConversation({String locale = 'fr'}) async {
    _messageHistory.clear();
    _currentStep = knowledgeBase.getFirstStep();
    _conversationStarted = false;
    
    return await startConversation(locale: locale);
  }

  /// Vérifie si c'est une demande d'aide
  bool _isHelpRequest(String answer) {
    final normalized = _normalizeAnswer(answer);
    return normalized.contains('AIDE') ||
           normalized.contains('HELP') ||
           normalized == 'BESOIN D AIDE' ||
           normalized == 'BESOIN DAIDE';
  }

  /// Normalise une réponse
  String _normalizeAnswer(String answer) {
    String normalized = answer.toUpperCase().trim();
    
    // Enlève les accents
    normalized = normalized
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Ù', 'U');
    
    // Enlève la ponctuation
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    
    // Normalise les espaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }

  /// Récupère l'historique des messages
  List<BotMessageModel> getMessageHistory() {
    return List.unmodifiable(_messageHistory);
  }

  /// Récupère l'étape actuelle
  HajjStepModel? getCurrentStep() {
    return _currentStep;
  }

  /// Récupère la progression (%)
  int getProgressPercentage() {
    if (_currentStep == null) return 0;
    
    final allSteps = knowledgeBase.getAllSteps();
    if (allSteps.isEmpty) return 0;
    
    final currentOrder = _currentStep!.order;
    final totalSteps = allSteps.length;
    
    return ((currentOrder / totalSteps) * 100).round();
  }

  /// Récupère le contexte actuel
  RitualContextModel? getCurrentContext() {
    return _lastContext;
  }

  /// Met à jour le contexte manuellement
  Future<RitualContextModel> refreshContext() async {
    _lastContext = await contextService.getCurrentContext();
    return _lastContext!;
  }

  /// Statistiques
  Map<String, dynamic> getStats() {
    final allSteps = knowledgeBase.getAllSteps();
    
    return {
      'current_step': _currentStep?.name ?? 'None',
      'current_order': _currentStep?.order ?? 0,
      'total_steps': allSteps.length,
      'progress_percentage': getProgressPercentage(),
      'messages_count': _messageHistory.length,
      'conversation_started': _conversationStarted,
      'current_location': _lastContext?.currentLocation,
      'is_in_holy_place': _lastContext?.isInHolyPlace ?? false,
      'suggested_duas_count': _lastContext?.suggestedDuas.length ?? 0,
      'urgent_reminders_count': _lastContext?.urgentReminders.length ?? 0,
    };
  }

  /// Dispose
  void dispose() {
    _messageHistory.clear();
    _currentStep = null;
    _conversationStarted = false;
    knowledgeBase.dispose();
    logger.d('BotService disposed');
  }
}

