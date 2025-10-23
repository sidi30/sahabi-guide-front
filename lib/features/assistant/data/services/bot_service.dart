import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../datasources/assistant_remote_data_source.dart';
import '../datasources/assistant_local_data_source.dart';
import '../models/conversation_step_model.dart';
import '../models/user_progress_model.dart';
import '../models/chat_message_model.dart';
import '../models/session_model.dart';
import 'assistant_notification_service.dart';
import 'assistant_sync_service.dart';

class BotService {
  final AssistantRemoteDataSource remoteDataSource;
  final AssistantLocalDataSource localDataSource;
  final AssistantNotificationService notificationService;
  final AssistantSyncService syncService;
  final Logger logger;
  final Uuid uuid = const Uuid();

  String? _currentUserId;
  ConversationStepModel? _currentStep;
  SessionModel? _currentSession;

  BotService({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.notificationService,
    required this.syncService,
    required this.logger,
  });

  /// Initialise le bot pour un utilisateur
  Future<void> initialize(String userId) async {
    try {
      _currentUserId = userId;
      logger.d('Initializing bot for user: $userId');

      // Initialise les dépendances
      await localDataSource.initialize();
      await notificationService.initialize();
      await notificationService.requestPermissions();
      await syncService.initialize();

      // Vérifie si resync nécessaire
      if (await syncService.shouldResync()) {
        logger.d('Data is stale, syncing...');
        await syncService.fullSync(userId);
      }

      // Charge les données locales
      // 🔧 PATCH : Force le téléchargement pour éviter les UUIDs obsolètes
      try {
        await syncService.downloadSteps();
        logger.d('Steps synced from server');
      } catch (e) {
        logger.w('Cannot sync steps, using local cache: $e');
        // Utilise le cache local seulement en cas d'échec réseau
      }

      // Démarre ou reprend la session
      await startOrResumeSession();

      logger.d('Bot initialized successfully');
    } catch (e) {
      logger.e('Error initializing bot: $e');
      rethrow;
    }
  }

  /// Démarre ou reprend une session de conversation
  Future<SessionModel?> startOrResumeSession() async {
    if (_currentUserId == null) {
      throw Exception('User not initialized');
    }

    try {
      // Essaie de récupérer depuis le serveur
      try {
        _currentSession = await remoteDataSource.startOrResumeSession(_currentUserId!);
        _currentStep = _currentSession?.currentStep;
        
        if (_currentStep != null) {
          await localDataSource.saveCurrentStepCode(_currentStep!.stepCode);
        }
        
        return _currentSession;
      } catch (e) {
        logger.w('Cannot fetch session from server, using local data: $e');
      }

      // Fallback : utilise les données locales
      final stepCode = await localDataSource.getCurrentStepCode();
      if (stepCode != null) {
        _currentStep = await localDataSource.getStepByCode(stepCode);
      } else {
        // Première étape
        final steps = await localDataSource.getSteps();
        if (steps.isNotEmpty) {
          _currentStep = steps.first;
          await localDataSource.saveCurrentStepCode(_currentStep!.stepCode);
        }
      }

      return null;
    } catch (e) {
      logger.e('Error starting session: $e');
      rethrow;
    }
  }

  /// Récupère l'étape actuelle
  ConversationStepModel? getCurrentStep() {
    return _currentStep;
  }

  /// Récupère tous les messages de l'historique
  Future<List<ChatMessageModel>> getChatHistory() async {
    return await localDataSource.getAllMessages();
  }

  /// Génère un message du bot pour l'étape actuelle
  Future<ChatMessageModel?> generateBotMessage({
    String? locale = 'fr',
  }) async {
    if (_currentStep == null) return null;

    final question = _currentStep!.getLocalizedQuestion(locale ?? 'fr');
    
    final message = ChatMessageModel.botMessage(
      id: uuid.v4(),
      content: question,
      stepId: _currentStep!.id,
      stepCode: _currentStep!.stepCode,
      quickReplies: _getQuickReplies(_currentStep!),
      answerType: _currentStep!.answerType,
    );

    await localDataSource.saveMessage(message);
    return message;
  }

  /// Génère les réponses rapides pour une étape
  List<String> _getQuickReplies(ConversationStepModel step) {
    switch (step.answerType) {
      case 'YES_NO':
        return ['Oui', 'Non'];
      case 'MULTIPLE_CHOICE':
        return step.answerOptions ?? [];
      default:
        return [];
    }
  }

  /// Enregistre une réponse utilisateur et passe à l'étape suivante
  Future<ChatMessageModel?> handleUserAnswer(String answer) async {
    if (_currentUserId == null || _currentStep == null) {
      throw Exception('Bot not properly initialized');
    }

    try {
      // 1. Sauvegarde le message utilisateur
      final userMessage = ChatMessageModel.userMessage(
        id: uuid.v4(),
        content: answer,
        stepId: _currentStep!.id,
        stepCode: _currentStep!.stepCode,
      );
      await localDataSource.saveMessage(userMessage);

      // 2. Crée l'objet de progression
      final progress = UserProgressModel(
        id: uuid.v4(),
        userId: _currentUserId!,
        stepId: _currentStep!.id,
        stepCode: _currentStep!.stepCode,
        answer: answer,
        answeredAt: DateTime.now(),
        isOffline: true, // Marqué offline par défaut
        deviceId: await _getDeviceId(),
      );

      // 3. Sauvegarde localement
      await localDataSource.saveProgress(progress);

      // 4. Essaie de synchroniser immédiatement
      try {
        final synced = await remoteDataSource.saveAnswer(
          userId: _currentUserId!,
          stepId: _currentStep!.id,
          answer: answer,
          answeredAt: progress.answeredAt,
          isOffline: false,
          deviceId: progress.deviceId,
        );
        
        // Met à jour avec la version synchronisée
        await localDataSource.saveProgress(synced);
        logger.d('Answer synced immediately');
      } catch (e) {
        logger.w('Cannot sync immediately, will retry later: $e');
        // La synchronisation automatique s'en chargera
      }

      // 5. Programme un rappel si nécessaire
      if (_currentStep!.isCritical == true && _currentStep!.reminderAfterHours != null) {
        await notificationService.scheduleStepReminder(
          step: _currentStep!,
          lastAnswered: DateTime.now(),
        );
      }

      // 6. Détermine l'étape suivante
      await _moveToNextStep(answer);

      // 7. Génère le message du bot pour la nouvelle étape
      if (_currentStep != null) {
        return await generateBotMessage();
      } else {
        // Fin de la conversation
        await _handleConversationEnd();
        return null;
      }
    } catch (e) {
      logger.e('Error handling answer: $e');
      rethrow;
    }
  }

  /// Passe à l'étape suivante basée sur la réponse
  Future<void> _moveToNextStep(String answer) async {
    if (_currentStep == null) return;

    try {
      // Essaie de récupérer depuis le serveur
      try {
        final nextStep = await remoteDataSource.getNextStep(
          stepId: _currentStep!.id,
          answer: answer,
        );
        
        if (nextStep != null) {
          _currentStep = nextStep;
          await localDataSource.saveCurrentStepCode(nextStep.stepCode);
          return;
        } else {
          // Fin de la conversation
          _currentStep = null;
          return;
        }
      } catch (e) {
        logger.w('Cannot fetch next step from server, using local logic: $e');
      }

      // Fallback : logique locale
      String? nextStepCode;

      // Utilise les règles de navigation si disponibles
      if (_currentStep!.navigationRules != null) {
        // Normalise la réponse : enlève accents, ponctuation, et met en majuscules
        final normalizedAnswer = _normalizeAnswer(answer);
        logger.d('Looking for navigation rule with: "$normalizedAnswer"');
        logger.d('Available rules: ${_currentStep!.navigationRules!.keys}');
        
        nextStepCode = _currentStep!.navigationRules![normalizedAnswer] ??
            _currentStep!.navigationRules!['DEFAULT'];
      }

      // Sinon utilise nextStepCode
      nextStepCode ??= _currentStep!.nextStepCode;

      if (nextStepCode != null) {
        _currentStep = await localDataSource.getStepByCode(nextStepCode);
        if (_currentStep != null) {
          await localDataSource.saveCurrentStepCode(_currentStep!.stepCode);
        }
      } else {
        _currentStep = null;
      }
    } catch (e) {
      logger.e('Error moving to next step: $e');
      rethrow;
    }
  }

  /// Gère la fin de la conversation
  Future<void> _handleConversationEnd() async {
    logger.d('Conversation ended');
    
    await notificationService.showCompletionNotification();
    
    // Sauvegarde un message de fin
    final endMessage = ChatMessageModel.botMessage(
      id: uuid.v4(),
      content: '🎉 Félicitations ! Vous avez terminé toutes les étapes. N\'hésitez pas à revenir si vous avez besoin d\'aide.',
    );
    
    await localDataSource.saveMessage(endMessage);
  }

  /// Redémarre la conversation
  Future<void> restartConversation() async {
    if (_currentUserId == null) {
      throw Exception('User not initialized');
    }

    try {
      logger.d('Restarting conversation...');

      // Efface l'historique local
      await localDataSource.clearMessages();

      // Réinitialise à la première étape
      final steps = await localDataSource.getSteps();
      if (steps.isNotEmpty) {
        _currentStep = steps.first;
        await localDataSource.saveCurrentStepCode(_currentStep!.stepCode);
      }

      // Démarre une nouvelle session
      await startOrResumeSession();

      logger.d('Conversation restarted');
    } catch (e) {
      logger.e('Error restarting conversation: $e');
      rethrow;
    }
  }

  /// Récupère un ID de device (simplifié)
  Future<String> _getDeviceId() async {
    // TODO: Utiliser un vrai device ID (package device_info_plus)
    return 'device_${_currentUserId ?? 'unknown'}';
  }

  /// Obtient des statistiques de progression
  Future<Map<String, dynamic>> getProgressStats() async {
    final allProgress = await localDataSource.getAllProgress();
    final unsyncedProgress = await localDataSource.getUnsyncedProgress();
    final allSteps = await localDataSource.getSteps();

    return {
      'totalSteps': allSteps.length,
      'completedSteps': allProgress.length,
      'unsyncedAnswers': unsyncedProgress.length,
      'progressPercentage': allSteps.isEmpty 
          ? 0 
          : (allProgress.length / allSteps.length * 100).round(),
    };
  }

  /// Normalise une réponse pour la correspondance avec les clés de navigation
  /// Enlève les accents, la ponctuation, et convertit en majuscules
  String _normalizeAnswer(String answer) {
    // Convertir en majuscules
    String normalized = answer.toUpperCase();
    
    // Enlever les accents courants en français
    normalized = normalized
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ô', 'O')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ç', 'C');
    
    // Enlever les apostrophes et les guillemets
    normalized = normalized.replaceAll("'", ' ').replaceAll('"', ' ');
    
    // Normaliser les espaces multiples
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }

  /// Nettoie et libère les ressources
  void dispose() {
    syncService.dispose();
    logger.d('Bot service disposed');
  }
}

