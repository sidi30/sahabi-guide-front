import 'package:sahabi_guide/core/network/dio_client.dart';

class HajjChatApi {
  final DioClient _dioClient;

  HajjChatApi(this._dioClient);

  Future<Map<String, dynamic>> chat(String question, String language) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/assistant/chat',
        data: {'question': question, 'language': language},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'answer': null, 'source': 'error', 'language': language};
    }
  }
}
