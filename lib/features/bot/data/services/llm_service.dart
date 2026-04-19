import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

/// Service d'IA locale (wrapper).
///
/// Historique : ce service appelait des API externes (HuggingFace / OpenAI)
/// pour enrichir les reponses, ce qui exigeait une cle API et echouait sans.
/// Depuis que le backend `/api/v1/assistant/chat` integre Ollama (qwen2.5:7b)
/// + RAG + enrichissement arabe + disclaimer, cet appel externe est
/// redondant et source d'erreurs.
///
/// Cette version no-op :
/// - Conserve l'API publique pour ne pas casser les appelants.
/// - Retourne toujours la reponse d'origine (pas d'enrichissement local).
/// - N'effectue AUCUN appel HTTP externe.
/// - Le toggle "IA enrichie" dans les parametres reste fonctionnel mais
///   agit uniquement comme preference d'affichage / telemetrie.
class LLMService {
  final Dio dio;
  final StorageService storageService;
  final Logger logger;

  bool _enabled = false;
  String? _apiKey;
  String _provider = 'backend';

  LLMService({
    required this.dio,
    required this.storageService,
    required this.logger,
  });

  Future<void> initialize() async {
    try {
      _enabled = storageService.isLLMEnabled();
      _apiKey = storageService.getLLMApiKey();
      _provider = storageService.getLLMProvider();
      logger.i('LLMService initialized (no-op wrapper, enabled: $_enabled)');
    } catch (e) {
      logger.w('LLMService init warning: $e');
    }
  }

  /// L'IA "enrichie" cote app est delegue au backend.
  /// Ce getter reste pour compatibilite ; ne reflete pas la disponibilite reelle.
  bool get isEnabled => _enabled;

  /// Toujours disponible (le backend gere la connectivite cote serveur).
  /// Retourne false uniquement si l'utilisateur a explicitement desactive.
  Future<bool> isAvailable() async => _enabled;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    try {
      await storageService.setLLMEnabled(enabled);
    } catch (e) {
      logger.w('Persist toggle failed (non-fatal): $e');
    }
    logger.d('LLM toggle: $enabled');
  }

  Future<void> setApiKey(String? apiKey) async {
    _apiKey = apiKey;
    try {
      await storageService.setLLMApiKey(apiKey ?? '');
    } catch (_) {}
  }

  Future<void> setProvider(String provider) async {
    _provider = provider;
    try {
      await storageService.setLLMProvider(provider);
    } catch (_) {}
  }

  /// L'enrichissement est assure par le backend. Ici on retourne la reponse
  /// d'origine sans appel reseau : pas d'erreur possible.
  Future<String?> enrichResponse({
    required String originalResponse,
    required String userQuestion,
    String? context,
  }) async {
    return originalResponse;
  }

  /// La generation est assuree par le backend. On retourne null pour laisser
  /// l'appelant utiliser son message par defaut.
  Future<String?> generateResponse({
    required String question,
    String? context,
  }) async {
    return null;
  }

  Map<String, dynamic> getInfo() => {
        'enabled': _enabled,
        'provider': _provider,
        'backend_ai': true,
        'external_calls': false,
      };

  void dispose() {
    logger.d('LLMService disposed');
  }
}
