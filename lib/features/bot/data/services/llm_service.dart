import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

/// Service d'intégration LLM optionnel
/// Permet d'enrichir les réponses du bot avec une IA externe
class LLMService {
  final Dio dio;
  final StorageService storageService;
  final Logger logger;
  
  bool _enabled = false;
  String? _apiKey;
  String _provider = 'huggingface';

  // Endpoints des différents providers
  static const String _huggingfaceEndpoint = 'https://api-inference.huggingface.co/models/';
  static const String _openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  // Modèles par défaut
  static const String _huggingfaceModel = 'mistralai/Mixtral-8x7B-Instruct-v0.1';
  static const String _openaiModel = 'gpt-3.5-turbo';

  LLMService({
    required this.dio,
    required this.storageService,
    required this.logger,
  });

  /// Initialise le service LLM
  Future<void> initialize() async {
    try {
      logger.d('Initializing LLMService...');
      
      // Charge les préférences
      _enabled = await storageService.isLLMEnabled();
      _apiKey = await storageService.getLLMApiKey();
      _provider = await storageService.getLLMProvider();
      
      logger.i('✅ LLMService initialized (enabled: $_enabled, provider: $_provider)');
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing LLMService: $e', stackTrace: stackTrace);
    }
  }

  /// Vérifie si le LLM est activé et configuré
  bool get isEnabled => _enabled && _apiKey != null && _apiKey!.isNotEmpty;

  /// Vérifie si le LLM est disponible
  Future<bool> isAvailable() async {
    if (!isEnabled) return false;
    
    // Vérifie la connectivité (simpliste)
    try {
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.w('LLM not available (no internet): $e');
      return false;
    }
  }

  /// Active/désactive le LLM
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await storageService.setLLMEnabled(enabled);
    logger.d('LLM enabled: $enabled');
  }

  /// Configure l'API key
  Future<void> setApiKey(String? apiKey) async {
    _apiKey = apiKey;
    await storageService.setLLMApiKey(apiKey ?? '');
    logger.d('LLM API key ${apiKey != null ? 'set' : 'cleared'}');
  }

  /// Configure le provider
  Future<void> setProvider(String provider) async {
    _provider = provider;
    await storageService.setLLMProvider(provider);
    logger.d('LLM provider set to: $provider');
  }

  /// Enrichit une réponse avec l'IA
  Future<String?> enrichResponse({
    required String originalResponse,
    required String userQuestion,
    String? context,
  }) async {
    if (!isEnabled) {
      logger.d('LLM not enabled, returning original response');
      return originalResponse;
    }

    if (!await isAvailable()) {
      logger.w('LLM not available, returning original response');
      return originalResponse;
    }

    try {
      logger.d('Enriching response with LLM ($_provider)...');
      
      switch (_provider) {
        case 'huggingface':
          return await _enrichWithHuggingFace(
            originalResponse,
            userQuestion,
            context,
          );
        
        case 'openai':
          return await _enrichWithOpenAI(
            originalResponse,
            userQuestion,
            context,
          );
        
        default:
          logger.w('Unknown LLM provider: $_provider');
          return originalResponse;
      }
    } catch (e) {
      logger.e('Error enriching response with LLM: $e');
      return originalResponse; // Fallback vers la réponse originale
    }
  }

  /// Enrichissement avec HuggingFace
  Future<String?> _enrichWithHuggingFace(
    String originalResponse,
    String userQuestion,
    String? context,
  ) async {
    try {
      final prompt = _buildPrompt(originalResponse, userQuestion, context);
      
      final response = await dio.post(
        '$_huggingfaceEndpoint$_huggingfaceModel',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 200,
            'temperature': 0.7,
            'top_p': 0.9,
            'return_full_text': false,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List && data.isNotEmpty) {
          final generatedText = data[0]['generated_text'] as String?;
          logger.d('HuggingFace response received');
          return generatedText?.trim() ?? originalResponse;
        }
      }

      return originalResponse;
    } catch (e) {
      logger.e('Error with HuggingFace: $e');
      return originalResponse;
    }
  }

  /// Enrichissement avec OpenAI
  Future<String?> _enrichWithOpenAI(
    String originalResponse,
    String userQuestion,
    String? context,
  ) async {
    try {
      const systemPrompt = '''Tu es un assistant expert du Hajj. 
Enrichis et améliore les réponses existantes avec plus de détails, de context islamique et de sagesse.
Réponds en français de manière claire et concise (maximum 200 mots).''';

      final userPrompt = _buildPrompt(originalResponse, userQuestion, context);
      
      final response = await dio.post(
        _openaiEndpoint,
        data: {
          'model': _openaiModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          logger.d('OpenAI response received');
          return content?.trim() ?? originalResponse;
        }
      }

      return originalResponse;
    } catch (e) {
      logger.e('Error with OpenAI: $e');
      return originalResponse;
    }
  }

  /// Construit le prompt pour l'IA
  String _buildPrompt(
    String originalResponse,
    String userQuestion,
    String? context,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Question de l\'utilisateur: $userQuestion');
    
    if (context != null && context.isNotEmpty) {
      buffer.writeln('\nContexte: $context');
    }
    
    buffer.writeln('\nRéponse de base: $originalResponse');
    buffer.writeln('\nEnrichis cette réponse avec plus de détails islamiques, '
                  'des hadiths pertinents si possible, et des conseils pratiques. '
                  'Réponds en français, de manière claire et concise (max 200 mots).');
    
    return buffer.toString();
  }

  /// Génère une réponse complète avec l'IA (pour les questions libres)
  Future<String?> generateResponse({
    required String question,
    String? context,
  }) async {
    if (!isEnabled) {
      logger.d('LLM not enabled');
      return null;
    }

    if (!await isAvailable()) {
      logger.w('LLM not available');
      return null;
    }

    try {
      logger.d('Generating response with LLM ($_provider)...');
      
      final prompt = '''Question sur le Hajj: $question

${context != null ? 'Contexte: $context\n' : ''}
Réponds de manière claire, précise et complète en français. 
Base-toi sur les sources islamiques authentiques.''';

      switch (_provider) {
        case 'huggingface':
          return await _generateWithHuggingFace(prompt);
        
        case 'openai':
          return await _generateWithOpenAI(prompt);
        
        default:
          return null;
      }
    } catch (e) {
      logger.e('Error generating response with LLM: $e');
      return null;
    }
  }

  /// Génération avec HuggingFace
  Future<String?> _generateWithHuggingFace(String prompt) async {
    try {
      final response = await dio.post(
        '$_huggingfaceEndpoint$_huggingfaceModel',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 300,
            'temperature': 0.7,
            'top_p': 0.9,
            'return_full_text': false,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List && data.isNotEmpty) {
          final generatedText = data[0]['generated_text'] as String?;
          logger.d('HuggingFace generation successful');
          return generatedText?.trim();
        }
      }

      return null;
    } catch (e) {
      logger.e('Error generating with HuggingFace: $e');
      return null;
    }
  }

  /// Génération avec OpenAI
  Future<String?> _generateWithOpenAI(String prompt) async {
    try {
      const systemPrompt = '''Tu es un assistant expert du Hajj avec une connaissance approfondie 
de l'islam et des rituels. Réponds aux questions avec précision, clarté et bienveillance.
Base-toi sur les sources islamiques authentiques (Coran, Sunnah).''';

      final response = await dio.post(
        _openaiEndpoint,
        data: {
          'model': _openaiModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          logger.d('OpenAI generation successful');
          return content?.trim();
        }
      }

      return null;
    } catch (e) {
      logger.e('Error generating with OpenAI: $e');
      return null;
    }
  }

  /// Récupère les informations du service
  Map<String, dynamic> getInfo() {
    return {
      'enabled': _enabled,
      'has_api_key': _apiKey != null && _apiKey!.isNotEmpty,
      'provider': _provider,
      'is_configured': isEnabled,
    };
  }

  /// Dispose
  void dispose() {
    logger.d('LLMService disposed');
  }
}

