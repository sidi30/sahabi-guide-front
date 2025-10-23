import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/conversation_step_model.dart';
import '../models/user_progress_model.dart';
import '../models/session_model.dart';

class AssistantRemoteDataSource {
  final Dio dio;
  final Logger logger;

  AssistantRemoteDataSource({
    required this.dio,
    required this.logger,
  });

  /// Récupère toutes les étapes de conversation
  Future<List<ConversationStepModel>> getAllSteps() async {
    try {
      logger.d('Fetching all conversation steps...');
      
      final response = await dio.get('/assistant/steps');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ConversationStepModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Failed to fetch steps: ${response.statusCode}');
    } catch (e) {
      logger.e('Error fetching steps: $e');
      rethrow;
    }
  }

  /// Récupère une étape par son code
  Future<ConversationStepModel> getStepByCode(String stepCode) async {
    try {
      logger.d('Fetching step: $stepCode');
      
      final response = await dio.get('/assistant/steps/$stepCode');
      
      if (response.statusCode == 200) {
        return ConversationStepModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to fetch step: ${response.statusCode}');
    } catch (e) {
      logger.e('Error fetching step $stepCode: $e');
      rethrow;
    }
  }

  /// Démarre ou reprend une session
  Future<SessionModel> startOrResumeSession(String userId) async {
    try {
      logger.d('Starting/resuming session for user: $userId');
      
      final response = await dio.post('/assistant/sessions/$userId/start');
      
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to start session: ${response.statusCode}');
    } catch (e) {
      logger.e('Error starting session: $e');
      rethrow;
    }
  }

  /// Récupère la session active
  Future<SessionModel> getCurrentSession(String userId) async {
    try {
      logger.d('Fetching current session for user: $userId');
      
      final response = await dio.get('/assistant/sessions/$userId/current');
      
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to fetch session: ${response.statusCode}');
    } catch (e) {
      logger.e('Error fetching session: $e');
      rethrow;
    }
  }

  /// Enregistre une réponse utilisateur
  Future<UserProgressModel> saveAnswer({
    required String userId,
    required String stepId,
    required String answer,
    DateTime? answeredAt,
    bool isOffline = false,
    String? deviceId,
  }) async {
    try {
      logger.d('Saving answer for step $stepId: $answer');
      
      final response = await dio.post(
        '/assistant/progress/$userId/answer',
        data: {
          'stepId': stepId,
          'answer': answer,
          'answeredAt': (answeredAt ?? DateTime.now()).toIso8601String(),
          'isOffline': isOffline,
          'deviceId': deviceId,
        },
      );
      
      if (response.statusCode == 200) {
        return UserProgressModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to save answer: ${response.statusCode}');
    } catch (e) {
      logger.e('Error saving answer: $e');
      rethrow;
    }
  }

  /// Synchronise plusieurs réponses offline
  Future<List<UserProgressModel>> syncAnswers({
    required String userId,
    required List<Map<String, dynamic>> answers,
    String? deviceId,
  }) async {
    try {
      logger.d('Syncing ${answers.length} offline answers...');
      
      final response = await dio.post(
        '/assistant/progress/$userId/sync',
        data: {
          'answers': answers,
          'deviceId': deviceId,
          'lastSyncTimestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => UserProgressModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Failed to sync answers: ${response.statusCode}');
    } catch (e) {
      logger.e('Error syncing answers: $e');
      rethrow;
    }
  }

  /// Récupère la progression de l'utilisateur
  Future<List<UserProgressModel>> getUserProgress(String userId) async {
    try {
      logger.d('Fetching user progress for: $userId');
      
      final response = await dio.get('/assistant/progress/$userId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => UserProgressModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Failed to fetch progress: ${response.statusCode}');
    } catch (e) {
      logger.e('Error fetching progress: $e');
      rethrow;
    }
  }

  /// Détermine l'étape suivante
  Future<ConversationStepModel?> getNextStep({
    required String stepId,
    required String answer,
  }) async {
    try {
      logger.d('Getting next step after $stepId with answer: $answer');
      
      final response = await dio.get(
        '/assistant/steps/$stepId/next',
        queryParameters: {'answer': answer},
      );
      
      if (response.statusCode == 200) {
        return ConversationStepModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 204) {
        // Fin de la conversation
        return null;
      }
      
      throw Exception('Failed to get next step: ${response.statusCode}');
    } catch (e) {
      logger.e('Error getting next step: $e');
      rethrow;
    }
  }
}

