import 'package:dio/dio.dart';
import 'package:sports_config_app/core/app_config.dart';

import 'media_headers.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: '${AppConfig.baseUrl}',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: mediaHeaders
  ),
);
