import 'package:sahabi_guide/core/network/dio_client.dart';
import 'package:sahabi_guide/core/utils/app_logger.dart';

class VideoService {
  final DioClient _dioClient;

  VideoService(this._dioClient);

  Future<List<Map<String, dynamic>>> getActiveVideos({String? category}) async {
    try {
      final queryParams = category != null ? '?category=$category' : '';
      final response = await _dioClient.get('/api/v1/videos/active$queryParams');
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      AppLogger.warning('VideoService.getActiveVideos: réponse non-liste (${response.data.runtimeType})');
      return [];
    } catch (e, st) {
      AppLogger.error('VideoService.getActiveVideos a échoué', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> trackView(String videoId) async {
    try {
      await _dioClient.post('/api/v1/videos/$videoId/view');
    } catch (e) {
      AppLogger.warning('VideoService.trackView($videoId) a échoué', error: e);
    }
  }
}
