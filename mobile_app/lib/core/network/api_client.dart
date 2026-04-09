import 'package:dio/dio.dart';

class ApiClient {
  const ApiClient._();

  static Dio create({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll(interceptors);

    return dio;
  }
}
