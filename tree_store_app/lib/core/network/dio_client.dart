import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({String? baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? 'http://10.0.2.2:8080', // Android emulator localhost
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}