import '../models/bot_message_model.dart';

/// StorageService for bot conversation persistence and settings.
/// Uses in-memory storage with sensible defaults.
class StorageService {
  final Map<String, dynamic> _state = {};
  final List<BotMessageModel> _messages = [];
  bool _llmEnabled = false;
  String _llmProvider = 'none';
  String _llmApiKey = '';
  bool _notificationsEnabled = true;

  Future<void> initialize() async {}

  // ── Messages ──
  Future<void> saveMessage(BotMessageModel message) async {
    _messages.add(message);
  }

  Future<List<BotMessageModel>> loadMessages() async {
    return List.unmodifiable(_messages);
  }

  // ── Conversation State ──
  Future<void> saveConversationState({
    String? currentStepId,
    int currentOrder = 0,
    bool conversationStarted = false,
  }) async {
    _state['currentStepId'] = currentStepId;
    _state['currentOrder'] = currentOrder;
    _state['conversationStarted'] = conversationStarted;
  }

  Future<Map<String, dynamic>?> loadConversationState() async {
    return _state.isNotEmpty ? Map.unmodifiable(_state) : null;
  }

  // ── LLM Settings ──
  bool isLLMEnabled() => _llmEnabled;
  String getLLMProvider() => _llmProvider;
  String getLLMApiKey() => _llmApiKey;

  Future<void> setLLMEnabled(bool enabled) async => _llmEnabled = enabled;
  Future<void> setLLMProvider(String provider) async => _llmProvider = provider;
  Future<void> setLLMApiKey(String key) async => _llmApiKey = key;

  // ── Notifications ──
  bool areNotificationsEnabled() => _notificationsEnabled;
  Future<void> setNotificationsEnabled(bool enabled) async => _notificationsEnabled = enabled;

  // ── Storage Stats ──
  Map<String, dynamic> getStorageStats() => {
    'messages': _messages.length,
    'hasState': _state.isNotEmpty,
    'llmEnabled': _llmEnabled,
    'llmProvider': _llmProvider,
  };

  // ── Clear ──
  Future<void> clearConversationHistory() async {
    _messages.clear();
    _state.clear();
  }

  Future<void> clearAll() async {
    await clearConversationHistory();
    _llmEnabled = false;
    _llmProvider = 'none';
    _llmApiKey = '';
  }
}
