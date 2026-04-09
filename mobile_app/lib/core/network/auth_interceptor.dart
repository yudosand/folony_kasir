import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'session_invalidation_bus.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required SessionInvalidationBus sessionInvalidationBus,
  })  : _tokenStorage = tokenStorage,
        _sessionInvalidationBus = sessionInvalidationBus;

  final TokenStorage _tokenStorage;
  final SessionInvalidationBus _sessionInvalidationBus;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    final statusCode = err.response?.statusCode;

    if (token != null && statusCode == 401) {
      await _sessionInvalidationBus.dispatch();
    }

    handler.next(err);
  }
}
