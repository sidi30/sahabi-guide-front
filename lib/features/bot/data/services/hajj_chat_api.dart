import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';

class HajjChatApi {
  final DioClient _dioClient;
  final Logger _logger = Logger();

  HajjChatApi(this._dioClient);

  /// Appel chat RAG + LLM.
  ///
  /// [history] : derniers tours de conversation (mémoire multi-tours), du plus
  /// ancien au plus récent, chaque élément `{role: "user"|"assistant", text}`.
  /// Optionnel et rétro-compatible : si vide, on n'envoie pas le champ.
  Future<Map<String, dynamic>> chat(
    String question,
    String language, {
    List<Map<String, String>>? history,
  }) async {
    try {
      final data = <String, dynamic>{
        'question': question,
        'language': language,
      };
      if (history != null && history.isNotEmpty) {
        data['history'] = history;
      }
      final response = await _dioClient.post(
        '/api/v1/assistant/chat',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // On distingue une vraie panne (réseau/timeout/5xx) d'une réponse vide :
      // dans les deux cas source = 'error', mais on logue le type de Dio pour
      // le diagnostic et pour que le consommateur affiche un message dédié.
      if (e is DioException) {
        _logger.w('HajjChatApi.chat failed: ${e.type} '
            '(status=${e.response?.statusCode})');
      } else {
        _logger.w('HajjChatApi.chat failed: $e');
      }
      return {'answer': null, 'source': 'error', 'language': language};
    }
  }
}
