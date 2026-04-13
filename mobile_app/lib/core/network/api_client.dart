import 'package:dio/dio.dart';

import 'network_config.dart';

class ApiClient {
  const ApiClient._();

  static Dio create({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(seconds: NetworkConfig.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: NetworkConfig.receiveTimeoutSeconds),
        sendTimeout:
            const Duration(seconds: NetworkConfig.sendTimeoutSeconds),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll(interceptors);

    return dio;
  }
}
