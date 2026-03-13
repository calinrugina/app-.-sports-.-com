import 'package:flutter/cupertino.dart';

import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';

class ConfigService {
  Future<Map<String, dynamic>> fetchConfig() async {
    debugPrint('${AppConfig.baseUrl}/config');

    final res = await dio.get('/api/v1/config',);

    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Unexpected config response format');
  }
}
