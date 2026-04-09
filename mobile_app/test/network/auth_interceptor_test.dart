import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/core/network/auth_interceptor.dart';
import 'package:folony_kasir_mobile/core/network/session_invalidation_bus.dart';
import 'package:folony_kasir_mobile/core/storage/token_storage.dart';

void main() {
  group('AuthInterceptor', () {
    test('adds bearer token to request headers', () async {
      final adapter = FakeHttpClientAdapter(statusCode: 200);
      final dio = Dio()..httpClientAdapter = adapter;
      final tokenStorage = FakeTokenStorage(token: 'token-123');
      final invalidationBus = SessionInvalidationBus();

      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          sessionInvalidationBus: invalidationBus,
        ),
      );

      await dio.get('https://foloni.test/auth/me');

      expect(adapter.lastAuthorizationHeader, 'Bearer token-123');
    });

    test('dispatches invalidation when response is unauthorized', () async {
      final adapter = FakeHttpClientAdapter(statusCode: 401);
      final dio = Dio()..httpClientAdapter = adapter;
      final tokenStorage = FakeTokenStorage(token: 'expired-token');
      final invalidationBus = SessionInvalidationBus();
      var invalidated = false;
      invalidationBus.register(() async {
        invalidated = true;
      });

      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          sessionInvalidationBus: invalidationBus,
        ),
      );

      await expectLater(
        () => dio.get('https://foloni.test/products'),
        throwsA(isA<DioException>()),
      );

      expect(invalidated, isTrue);
      expect(adapter.lastAuthorizationHeader, 'Bearer expired-token');
    });
  });
}

class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage({this.token}) : super(const FlutterSecureStorage());

  final String? token;

  @override
  Future<String?> readToken() async {
    return token;
  }
}

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter({required this.statusCode});

  final int statusCode;
  String? lastAuthorizationHeader;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastAuthorizationHeader = options.headers['Authorization'] as String?;

    return ResponseBody.fromString(
      '{"message":"ok"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
