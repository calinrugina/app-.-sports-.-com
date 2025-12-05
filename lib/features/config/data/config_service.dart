import '../../../core/network/dio_client.dart';

class ConfigService {
  Future<Map<String, dynamic>> fetchConfig() async {
    final res = await dio.get('/config');
    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Unexpected config response format');
  }
}
