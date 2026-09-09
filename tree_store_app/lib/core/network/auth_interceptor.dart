import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _queue = [];

  AuthInterceptor(this._dio, this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || err.requestOptions.path == ApiEndpoints.refreshToken) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add(_QueuedRequest(err, handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final res = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final newAccess = res.data['token'] as String?;
      final newRefresh = res.data['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) throw Exception('Invalid refresh response');

      await _tokenStorage.saveTokens(newAccess, newRefresh);

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      for (final q in _queue) {
        q.err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final r = await _dio.fetch(q.err.requestOptions);
          q.handler.resolve(r);
        } catch (e) {
          q.handler.reject(q.err);
        }
      }
      _queue.clear();
    } catch (e) {
      await _tokenStorage.clear();
      handler.next(err);
      for (final q in _queue) {
        q.handler.reject(q.err);
      }
      _queue.clear();
    } finally {
      _isRefreshing = false;
    }
  }
}

class _QueuedRequest {
  final DioException err;
  final ErrorInterceptorHandler handler;
  _QueuedRequest(this.err, this.handler);
}