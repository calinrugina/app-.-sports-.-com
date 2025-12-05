import 'package:dio/dio.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'https://sports.com/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);
