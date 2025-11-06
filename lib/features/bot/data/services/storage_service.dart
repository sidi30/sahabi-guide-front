import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/bot_message_model.dart';

/// Service de stockage local avec Hive
/// Persiste l'historique de conversation et les préférences du bot
class StorageService {
  final Logger logger;
  
  static const String _messagesBoxName = 'bot_messages';
  static const String _conversationStateBoxName = 'bot_conversation_state';
  static const String _preferencesBoxName = 'bot_preferences';
  
  Box<dynamic>? _messagesBox;
  Box<dynamic>? _stateBox;
  Box<dynamic>? _preferencesBox;
  
  bool _initialized = false;

  StorageService({required this.logger});

  /// Initialise Hive et les boxes
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      logger.d('Initializing StorageService...');
      
      // Initialise Hive (déjà fait dans main.dart normalement)
      // await Hive.initFlutter();
      
      // Ouvre les boxes
      _messagesBox = await Hive.openBox<dynamic>(_messagesBoxName);
      _stateBox = await Hive.openBox<dynamic>(_conversationStateBoxName);
      _preferencesBox = await Hive.openBox<dynamic>(_preferencesBoxName);
      
      _initialized = true;
      logger.i('✅ StorageService initialized');
      logger.d('Messages count: ${_messagesBox?.length ?? 0}');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing StorageService: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Sauvegarde un message dans l'historique
  Future<void> saveMessage(BotMessageModel message) async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return;
    }

    try {
      final messageData = {
        'id': message.id,
        'content': message.content,
        'contentAr': message.contentAr,
        'isBot': message.isBot,
        'timestamp': message.timestamp.toIso8601String(),
        'quickReplies': message.quickReplies,
        'relatedStepId': message.relatedStepId,
        'relatedRitualId': message.relatedRitualId,
      };

      await _messagesBox?.put(message.id, messageData);
      logger.d('Message saved: ${message.id}');
    } catch (e) {
      logger.e('Error saving message: $e');
    }
  }

  /// Sauvegarde tout l'historique de messages
  Future<void> saveMessages(List<BotMessageModel> messages) async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return;
    }

    try {
      final messagesData = <String, Map>{};
      
      for (final message in messages) {
        messagesData[message.id] = {
          'id': message.id,
          'content': message.content,
          'contentAr': message.contentAr,
          'isBot': message.isBot,
          'timestamp': message.timestamp.toIso8601String(),
          'quickReplies': message.quickReplies,
          'relatedStepId': message.relatedStepId,
          'relatedRitualId': message.relatedRitualId,
        };
      }

      await _messagesBox?.putAll(messagesData);
      logger.d('${messages.length} messages saved');
    } catch (e) {
      logger.e('Error saving messages: $e');
    }
  }

  /// Récupère l'historique de messages
  Future<List<BotMessageModel>> loadMessages() async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return [];
    }

    try {
      final messages = <BotMessageModel>[];
      
      final values = _messagesBox?.values ?? [];
      for (final value in values) {
        try {
          final messageData = value as Map<dynamic, dynamic>;
          final message = BotMessageModel(
            id: messageData['id'] as String,
            content: messageData['content'] as String,
            contentAr: messageData['contentAr'] as String?,
            isBot: messageData['isBot'] as bool,
            timestamp: DateTime.parse(messageData['timestamp'] as String),
            quickReplies: (messageData['quickReplies'] as List?)?.cast<String>(),
            relatedStepId: messageData['relatedStepId'] as String?,
            relatedRitualId: messageData['relatedRitualId'] as String?,
          );
          
          messages.add(message);
        } catch (e) {
          logger.w('Error parsing message: $e');
        }
      }

      // Trie par timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      logger.d('${messages.length} messages loaded');
      return messages;
    } catch (e) {
      logger.e('Error loading messages: $e');
      return [];
    }
  }

  /// Sauvegarde l'état de la conversation
  Future<void> saveConversationState({
    required String? currentStepId,
    required int currentOrder,
    required bool conversationStarted,
  }) async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return;
    }

    try {
      final state = {
        'currentStepId': currentStepId,
        'currentOrder': currentOrder,
        'conversationStarted': conversationStarted,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _stateBox?.put('current_state', state);
      logger.d('Conversation state saved');
    } catch (e) {
      logger.e('Error saving conversation state: $e');
    }
  }

  /// Charge l'état de la conversation
  Future<Map<String, dynamic>?> loadConversationState() async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return null;
    }

    try {
      final stateValue = _stateBox?.get('current_state');
      
      if (stateValue == null) {
        logger.d('No saved conversation state');
        return null;
      }

      final state = stateValue as Map<dynamic, dynamic>;

      logger.d('Conversation state loaded');
      return {
        'currentStepId': state['currentStepId'],
        'currentOrder': state['currentOrder'],
        'conversationStarted': state['conversationStarted'],
        'lastUpdated': state['lastUpdated'],
      };
    } catch (e) {
      logger.e('Error loading conversation state: $e');
      return null;
    }
  }

  /// Efface l'historique de conversation
  Future<void> clearConversationHistory() async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return;
    }

    try {
      await _messagesBox?.clear();
      await _stateBox?.clear();
      logger.d('Conversation history cleared');
    } catch (e) {
      logger.e('Error clearing conversation history: $e');
    }
  }

  /// Sauvegarde une préférence
  Future<void> savePreference(String key, dynamic value) async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return;
    }

    try {
      await _preferencesBox?.put(key, value);
      logger.d('Preference saved: $key = $value');
    } catch (e) {
      logger.e('Error saving preference: $e');
    }
  }

  /// Récupère une préférence
  Future<T?> getPreference<T>(String key, {T? defaultValue}) async {
    if (!_initialized) {
      logger.w('StorageService not initialized');
      return defaultValue;
    }

    try {
      final value = _preferencesBox?.get(key, defaultValue: defaultValue);
      return value as T?;
    } catch (e) {
      logger.e('Error getting preference: $e');
      return defaultValue;
    }
  }

  /// Préférences spécifiques : LLM activé/désactivé
  Future<void> setLLMEnabled(bool enabled) async {
    await savePreference('llm_enabled', enabled);
  }

  Future<bool> isLLMEnabled() async {
    return await getPreference<bool>('llm_enabled', defaultValue: false) ?? false;
  }

  /// Préférences spécifiques : API Key LLM
  Future<void> setLLMApiKey(String? apiKey) async {
    await savePreference('llm_api_key', apiKey);
  }

  Future<String?> getLLMApiKey() async {
    return await getPreference<String>('llm_api_key');
  }

  /// Préférences spécifiques : Provider LLM (huggingface, openai, etc.)
  Future<void> setLLMProvider(String provider) async {
    await savePreference('llm_provider', provider);
  }

  Future<String> getLLMProvider() async {
    return await getPreference<String>('llm_provider', defaultValue: 'huggingface') ?? 'huggingface';
  }

  /// Préférences spécifiques : Notifications activées
  Future<void> setNotificationsEnabled(bool enabled) async {
    await savePreference('notifications_enabled', enabled);
  }

  Future<bool> areNotificationsEnabled() async {
    return await getPreference<bool>('notifications_enabled', defaultValue: true) ?? true;
  }

  /// Statistiques
  Future<Map<String, dynamic>> getStorageStats() async {
    if (!_initialized) return {};

    return {
      'messages_count': _messagesBox?.length ?? 0,
      'has_saved_state': _stateBox?.get('current_state') != null,
      'preferences_count': _preferencesBox?.length ?? 0,
      'llm_enabled': await isLLMEnabled(),
      'notifications_enabled': await areNotificationsEnabled(),
    };
  }

  /// Dispose
  Future<void> dispose() async {
    try {
      await _messagesBox?.close();
      await _stateBox?.close();
      await _preferencesBox?.close();
      logger.d('StorageService disposed');
    } catch (e) {
      logger.e('Error disposing StorageService: $e');
    }
  }
}

