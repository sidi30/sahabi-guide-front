import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';

/// Client HTTP du microservice voix (SeamlessM4T v2) exposé par le backend
/// sous `/api/v1/assistant/voice`.
///
/// Endpoints :
/// - POST /tts        json {"text","lang"}                 -> audio/wav bytes
/// - POST /asr        multipart file=audio, form lang      -> {"text"}
/// - POST /s2s        multipart file=audio, form src, tgt  -> audio/wav bytes
/// - POST /translate  json {"text","src","tgt"}            -> {"text"}
///
/// Codes de langue canoniques : en, fr, ar, ha, dje, yo, sw, wo, bm.
///
/// Toutes les méthodes échouent proprement : elles retournent `null`
/// (ou propagent une erreur déjà loggée) plutôt que de lever silencieusement.
class VoiceRemoteApi {
  final DioClient _dioClient;
  final Logger logger;

  static const String _base = '/api/v1/assistant/voice';

  VoiceRemoteApi(this._dioClient, {required this.logger});

  /// Synthèse vocale : renvoie les octets WAV ou `null` en cas d'échec.
  Future<Uint8List?> tts(String text, String lang) async {
    try {
      final response = await _dioClient.post(
        '$_base/tts',
        data: {'text': text, 'lang': lang},
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data is List<int>) {
        return Uint8List.fromList(data);
      }
      if (data is Uint8List) return data;
      logger.w('VoiceRemoteApi.tts: unexpected payload type ${data.runtimeType}');
      return null;
    } catch (e) {
      logger.w('VoiceRemoteApi.tts failed: $e');
      return null;
    }
  }

  /// Reconnaissance vocale : envoie les octets audio et renvoie le texte
  /// transcrit, ou `null` en cas d'échec.
  Future<String?> asr(
    Uint8List audioBytes,
    String lang, {
    String filename = 'audio.wav',
  }) async {
    try {
      final formData = FormData.fromMap({
        'lang': lang,
        'file': MultipartFile.fromBytes(audioBytes, filename: filename),
      });
      final response = await _dioClient.post(
        '$_base/asr',
        data: formData,
      );
      final data = response.data;
      if (data is Map) {
        return data['text']?.toString();
      }
      logger.w('VoiceRemoteApi.asr: unexpected payload type ${data.runtimeType}');
      return null;
    } catch (e) {
      logger.w('VoiceRemoteApi.asr failed: $e');
      return null;
    }
  }

  /// Speech-to-speech : transforme un audio source (src) en audio cible (tgt).
  /// Renvoie les octets WAV ou `null` en cas d'échec.
  Future<Uint8List?> s2s(
    Uint8List audioBytes,
    String src,
    String tgt, {
    String filename = 'audio.wav',
  }) async {
    try {
      final formData = FormData.fromMap({
        'src': src,
        'tgt': tgt,
        'file': MultipartFile.fromBytes(audioBytes, filename: filename),
      });
      final response = await _dioClient.post(
        '$_base/s2s',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data is List<int>) {
        return Uint8List.fromList(data);
      }
      if (data is Uint8List) return data;
      logger.w('VoiceRemoteApi.s2s: unexpected payload type ${data.runtimeType}');
      return null;
    } catch (e) {
      logger.w('VoiceRemoteApi.s2s failed: $e');
      return null;
    }
  }

  /// Traduction texte->texte. Renvoie le texte traduit ou `null`.
  Future<String?> translate(String text, String src, String tgt) async {
    try {
      final response = await _dioClient.post(
        '$_base/translate',
        data: {'text': text, 'src': src, 'tgt': tgt},
      );
      final data = response.data;
      if (data is Map) {
        return data['text']?.toString();
      }
      logger.w(
          'VoiceRemoteApi.translate: unexpected payload type ${data.runtimeType}');
      return null;
    } catch (e) {
      logger.w('VoiceRemoteApi.translate failed: $e');
      return null;
    }
  }
}
