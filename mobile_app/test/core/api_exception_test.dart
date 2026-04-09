import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folony_kasir_mobile/core/errors/api_exception.dart';

void main() {
  group('ApiException.fromDioException', () {
    test('menerjemahkan kredensial login yang salah', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 422,
          data: const {
            'success': false,
            'message': 'The provided credentials are incorrect.',
          },
        ),
      );

      final result = ApiException.fromDioException(exception);

      expect(
        result.message,
        'Email atau password belum cocok. Coba cek lagi ya.',
      );
    });

    test('memprioritaskan pesan validasi pertama yang lebih ramah', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/products'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/products'),
          statusCode: 422,
          data: const {
            'success': false,
            'message': 'Validation error',
            'errors': {
              'stock': ['The stock field must be at least 0.'],
            },
          },
        ),
      );

      final result = ApiException.fromDioException(exception);

      expect(result.message, 'Stok tidak boleh kurang dari 0 ya.');
    });

    test('menerjemahkan masalah jaringan jadi pesan friendly', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        message: 'Failed host lookup: api.test.local',
      );

      final result = ApiException.fromDioException(exception);

      expect(
        result.message,
        'Koneksi ke server lagi bermasalah. Coba sebentar lagi ya.',
      );
    });

    test('menerjemahkan stok tidak cukup dari backend', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/transactions'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 422,
          data: const {
            'success': false,
            'message': 'Insufficient stock for Kopi Susu.',
          },
        ),
      );

      final result = ApiException.fromDioException(exception);

      expect(result.message, 'Stok produk tidak cukup.');
    });
  });
}
