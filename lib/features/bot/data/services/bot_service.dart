import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/bot_message_model.dart';
import '../models/hajj_step_model.dart';
import '../models/faq_model.dart';
import 'knowledge_base_service.dart';

/// Service principal du bot Hajj
/// Gère la conversation, la navigation entre étapes, les réponses
class BotService {
  final KnowledgeBaseService knowledgeBase;
  final Logger logger;
  final Uuid uuid = const Uuid();

  // État de la conversation
  HajjStepModel? _currentStep;
  final List<BotMessageModel> _messageHistory = [];
  bool _conversationStarted = false;

  BotService({
    required this.knowledgeBase,
    required this.logger,
  });

  /// Initialise le bot
  Future<void> initialize() async {
    try {
      logger.d('Initializing BotService...');
      
      // Initialise la base de connaissances
      await knowledgeBase.initialize();
      
      // Charge la première étape
      _currentStep = knowledgeBase.getFirstStep();
      
      if (_currentStep == null) {
        throw Exception('No first step found in knowledge base');
      }
      
      logger.i('✅ BotService initialized with first step: ${_currentStep!.name}');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing BotService: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Démarre la conversation
  Future<BotMessageModel> startConversation({String locale = 'fr'}) async {
    if (_currentStep == null) {
      throw StateError('BotService not initialized');
    }

    _conversationStarted = true;
    
    // Message de bienvenue
    final welcomeMessage = BotMessageModel.bot(
      id: uuid.v4(),
      content: '🕋 As-salamu alaykum ! Je suis votre assistant personnel pour le Hajj.\n\n'
               'Je vais vous guider étape par étape à travers tous les rituels. '
               'Répondez simplement aux questions et je vous accompagnerai ! 🤲',
      contentAr: 'السلام عليكم! أنا مساعدك الشخصي للحج.',
    );
    
    _messageHistory.add(welcomeMessage);
    
    // Génère le premier message de question
    await Future.delayed(const Duration(milliseconds: 500));
    final firstQuestion = await _generateQuestionMessage(locale: locale);
    
    return welcomeMessage;
  }

  /// Génère un message de question pour l'étape actuelle
  Future<BotMessageModel> _generateQuestionMessage({
    required String locale,
  }) async {
    if (_currentStep == null) {
      throw StateError('No current step');
    }

    String content = _currentStep!.getLocalizedQuestion(locale);
    
    // Ajoute les rappels urgents si présents
    final urgentReminders = knowledgeBase.getUrgentReminders(_currentStep!.id);
    if (urgentReminders.isNotEmpty) {
      content += '\n\n${urgentReminders.join('\n')}';
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
    return message;
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
    final faq = knowledgeBase.getBestFAQ(query);
    
    String content;
    
    if (faq != null) {
      content = '❓ ${faq.question}\n\n${faq.answer}';
    } else {
      content = '🤔 Je n\'ai pas trouvé de réponse exacte à votre question.\n\n'
                'Vous pouvez :\n'
                '- Reformuler votre question\n'
                '- Consulter la section "Rituels"\n'
                '- Poser une question plus générale';
    }
    
    final message = BotMessageModel.bot(
      id: uuid.v4(),
      content: content,
      quickReplies: ['Autre question', 'Continuer'],
    );
    
    _messageHistory.add(message);
    return message;
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

