import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/conversation_step_model.dart';
import '../models/user_progress_model.dart';
import '../models/chat_message_model.dart';

class AssistantLocalDataSource {
  final Logger logger;
  
  static const String _stepsBoxName = 'conversation_steps';
  static const String _progressBoxName = 'user_progress';
  static const String _messagesBoxName = 'chat_messages';
  static const String _metadataBoxName = 'assistant_metadata';

  AssistantLocalDataSource({required this.logger});

  /// Initialise les boxes Hive
  Future<void> initialize() async {
    try {
      await Hive.openBox<ConversationStepModel>(_stepsBoxName);
      await Hive.openBox<UserProgressModel>(_progressBoxName);
      await Hive.openBox<ChatMessageModel>(_messagesBoxName);
      await Hive.openBox(_metadataBoxName);
      
      logger.d('Assistant local data source initialized');
    } catch (e) {
      logger.e('Error initializing assistant local storage: $e');
      rethrow;
    }
  }

  // --- STEPS ---

  Future<void> saveSteps(List<ConversationStepModel> steps) async {
    try {
      final box = Hive.box<ConversationStepModel>(_stepsBoxName);
      await box.clear();
      
      for (var step in steps) {
        await box.put(step.id, step);
      }
      
      await _saveLastUpdated('steps');
      logger.d('Saved ${steps.length} steps to local storage');
    } catch (e) {
      logger.e('Error saving steps: $e');
      rethrow;
    }
  }

  Future<List<ConversationStepModel>> getSteps() async {
    try {
      final box = Hive.box<ConversationStepModel>(_stepsBoxName);
      final steps = box.values.toList();
      steps.sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
      return steps;
    } catch (e) {
      logger.e('Error getting steps: $e');
      return [];
    }
  }

  Future<ConversationStepModel?> getStepByCode(String stepCode) async {
    try {
      final box = Hive.box<ConversationStepModel>(_stepsBoxName);
      return box.values.firstWhere(
        (step) => step.stepCode == stepCode,
        orElse: () => throw Exception('Step not found'),
      );
    } catch (e) {
      logger.e('Error getting step by code: $e');
      return null;
    }
  }

  // --- PROGRESS ---

  Future<void> saveProgress(UserProgressModel progress) async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      await box.put(progress.id, progress);
      logger.d('Saved progress: ${progress.id}');
    } catch (e) {
      logger.e('Error saving progress: $e');
      rethrow;
    }
  }

  Future<void> saveProgressList(List<UserProgressModel> progressList) async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      for (var progress in progressList) {
        await box.put(progress.id, progress);
      }
      logger.d('Saved ${progressList.length} progress items');
    } catch (e) {
      logger.e('Error saving progress list: $e');
      rethrow;
    }
  }

  Future<List<UserProgressModel>> getAllProgress() async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      return box.values.toList();
    } catch (e) {
      logger.e('Error getting all progress: $e');
      return [];
    }
  }

  Future<List<UserProgressModel>> getUnsyncedProgress() async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      return box.values.where((p) => !p.isSynced).toList();
    } catch (e) {
      logger.e('Error getting unsynced progress: $e');
      return [];
    }
  }

  Future<UserProgressModel?> getProgressForStep(String stepId) async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      return box.values.firstWhere(
        (p) => p.stepId == stepId,
        orElse: () => throw Exception('Progress not found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProgress(String progressId) async {
    try {
      final box = Hive.box<UserProgressModel>(_progressBoxName);
      await box.delete(progressId);
    } catch (e) {
      logger.e('Error deleting progress: $e');
    }
  }

  // --- CHAT MESSAGES ---

  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      final box = Hive.box<ChatMessageModel>(_messagesBoxName);
      await box.put(message.id, message);
      logger.d('Saved message: ${message.id}');
    } catch (e) {
      logger.e('Error saving message: $e');
      rethrow;
    }
  }

  Future<List<ChatMessageModel>> getAllMessages() async {
    try {
      final box = Hive.box<ChatMessageModel>(_messagesBoxName);
      final messages = box.values.toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      logger.e('Error getting messages: $e');
      return [];
    }
  }

  Future<void> clearMessages() async {
    try {
      final box = Hive.box<ChatMessageModel>(_messagesBoxName);
      await box.clear();
      logger.d('Cleared all messages');
    } catch (e) {
      logger.e('Error clearing messages: $e');
    }
  }

  // --- METADATA ---

  Future<void> _saveLastUpdated(String key) async {
    try {
      final box = Hive.box(_metadataBoxName);
      await box.put('${key}_last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      logger.e('Error saving last updated: $e');
    }
  }

  Future<DateTime?> getLastUpdated(String key) async {
    try {
      final box = Hive.box(_metadataBoxName);
      final value = box.get('${key}_last_updated') as String?;
      return value != null ? DateTime.parse(value) : null;
    } catch (e) {
      logger.e('Error getting last updated: $e');
      return null;
    }
  }

  Future<void> saveCurrentStepCode(String stepCode) async {
    try {
      final box = Hive.box(_metadataBoxName);
      await box.put('current_step_code', stepCode);
    } catch (e) {
      logger.e('Error saving current step: $e');
    }
  }

  Future<String?> getCurrentStepCode() async {
    try {
      final box = Hive.box(_metadataBoxName);
      return box.get('current_step_code') as String?;
    } catch (e) {
      logger.e('Error getting current step: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await Hive.box<ConversationStepModel>(_stepsBoxName).clear();
      await Hive.box<UserProgressModel>(_progressBoxName).clear();
      await Hive.box<ChatMessageModel>(_messagesBoxName).clear();
      await Hive.box(_metadataBoxName).clear();
      
      logger.d('Cleared all assistant data');
    } catch (e) {
      logger.e('Error clearing all data: $e');
    }
  }

  /// Vérifie si les données locales sont à jour (< 24h)
  Future<bool> isDataFresh() async {
    final lastUpdated = await getLastUpdated('steps');
    if (lastUpdated == null) return false;
    
    final hoursSinceUpdate = DateTime.now().difference(lastUpdated).inHours;
    return hoursSinceUpdate < 24;
  }
}

