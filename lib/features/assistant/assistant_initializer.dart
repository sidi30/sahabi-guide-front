import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'data/models/conversation_step_model.dart';
import 'data/models/user_progress_model.dart';
import 'data/models/chat_message_model.dart';

/// Initialise le module assistant
class AssistantInitializer {
  static final Logger _logger = Logger();

  /// Initialise Hive et les adapters
  static Future<void> initialize() async {
    try {
      _logger.d('Initializing assistant module...');

      // Initialise Hive
      await Hive.initFlutter();

      // Enregistre les adapters Hive
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ConversationStepModelAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(UserProgressModelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(ChatMessageModelAdapter());
      }

      // Initialise les timezones pour les notifications
      tz.initializeTimeZones();

      _logger.d('Assistant module initialized successfully');
    } catch (e) {
      _logger.e('Error initializing assistant module: $e');
      rethrow;
    }
  }
}

