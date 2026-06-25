import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';

/// Client pour l'endpoint de traduction batch de l'assistant.
///
/// `POST /api/v1/assistant/translate`
///   body : { "texts": [..], "targetLang": "ha", "sourceLang": "fr" }
///   ->     { "translations": [..], "targetLang": "ha" }
///
/// Endpoint `permitAll` (pas de token requis). Graceful côté backend : si la
/// traduction échoue il renvoie les originaux (même ordre / même longueur).
/// Côté client on est aussi tolérant : en cas d'erreur réseau on renvoie les
/// textes d'origine pour ne jamais casser le chat.
class TranslateApi {
  final DioClient _dioClient;
  final Logger _logger;

  TranslateApi(this._dioClient, {Logger? logger})
      : _logger = logger ?? Logger();

  /// Traduit [texts] de [sourceLang] vers [targetLang] en UN SEUL appel.
  /// Retourne une liste de même longueur/ordre. En cas d'échec, retourne
  /// [texts] inchangés (fallback gracieux).
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLang,
    String? sourceLang,
  }) async {
    if (texts.isEmpty) return texts;
    try {
      final response = await _dioClient.post(
        '/api/v1/assistant/translate',
        data: {
          'texts': texts,
          'targetLang': targetLang,
          if (sourceLang != null) 'sourceLang': sourceLang,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['translations'] is List) {
        final translations = (data['translations'] as List)
            .map((e) => e?.toString() ?? '')
            .toList();
        // Garde l'invariant ordre/longueur : si le backend renvoie une taille
        // différente (ne devrait pas), on retombe sur les originaux.
        if (translations.length == texts.length) {
          return translations;
        }
        _logger.w('translateBatch length mismatch '
            '(${translations.length} != ${texts.length}), keeping originals');
      }
    } catch (e) {
      if (e is DioException) {
        _logger.w('translateBatch failed: ${e.type} '
            '(status=${e.response?.statusCode})');
      } else {
        _logger.w('translateBatch failed: $e');
      }
    }
    return texts;
  }
}
