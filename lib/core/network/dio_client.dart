import 'package:dio/dio.dart';
import 'package:sports_config_app/core/app_config.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: '${AppConfig.baseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);
