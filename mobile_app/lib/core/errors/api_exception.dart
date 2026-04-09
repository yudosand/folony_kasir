import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.errors = const {},
    this.statusCode,
  });

  final String message;
  final Map<String, dynamic> errors;
  final int? statusCode;

  factory ApiException.fromDioException(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'] is Map<String, dynamic>
          ? responseData['errors'] as Map<String, dynamic>
          : const <String, dynamic>{};

      final firstError = _extractFirstError(errors);

      return ApiException(
        message: _friendlyMessage(
          firstError ?? responseData['message'] as String? ?? 'Request failed.',
        ),
        errors: errors,
        statusCode: exception.response?.statusCode,
      );
    }

    return ApiException(
      message: _friendlyMessage(
        exception.message ?? 'Network request failed.',
      ),
      statusCode: exception.response?.statusCode,
    );
  }

  static String? _extractFirstError(Map<String, dynamic> errors) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) {
          return first;
        }
      }

      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String _friendlyMessage(String rawMessage) {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      return 'Terjadi kendala. Coba lagi sebentar ya.';
    }

    const exactMatches = <String, String>{
      'Request failed.': 'Permintaan belum berhasil diproses. Coba lagi ya.',
      'Network request failed.':
          'Koneksi ke server lagi bermasalah. Coba sebentar lagi ya.',
      'Response body is empty.':
          'Respons server kosong. Coba lagi sebentar ya.',
      'User payload is missing.':
          'Data pengguna belum tersedia. Coba login lagi ya.',
      'Product payload is missing.':
          'Data produk belum tersedia. Coba lagi ya.',
      'Store setting payload is missing.':
          'Data pengaturan toko belum tersedia. Coba lagi ya.',
      'Transaction payload is missing.':
          'Data transaksi belum tersedia. Coba lagi ya.',
      'Invoice payload is missing.':
          'Data invoice belum tersedia. Coba lagi ya.',
      'The provided credentials are incorrect.':
          'Email atau password belum cocok. Coba cek lagi ya.',
      'The selected payment method is invalid.':
          'Metode pembayaran yang dipilih belum sesuai.',
      'The name field is required.': 'Nama wajib diisi ya.',
      'The email field is required.': 'Email wajib diisi ya.',
      'The phone field is required.': 'Nomor HP wajib diisi ya.',
      'The phone has already been taken.':
          'Nomor HP ini sudah terdaftar. Coba login ya.',
      'The password field is required.': 'Password wajib diisi ya.',
      'The password confirmation field is required.':
          'Konfirmasi password wajib diisi ya.',
      'The password field confirmed does not match.':
          'Konfirmasi password belum cocok, coba cek lagi ya.',
      'The referal field is required.': 'Kode referal wajib diisi ya.',
      'The store name field is required.': 'Nama toko wajib diisi ya.',
      'The stock field is required.': 'Stok wajib diisi ya.',
      'The cost price field is required.': 'Harga modal wajib diisi ya.',
      'The selling price field is required.': 'Harga jual wajib diisi ya.',
      'The stock field must be at least 0.':
          'Stok tidak boleh kurang dari 0 ya.',
      'The cost price field must be at least 0.':
          'Harga modal tidak boleh kurang dari 0 ya.',
      'The selling price field must be at least 0.':
          'Harga jual tidak boleh kurang dari 0 ya.',
      'The password field must be at least 6 characters.':
          'Password minimal 6 karakter ya.',
      'The email field must be a valid email address.':
          'Email-nya belum valid, coba cek lagi ya.',
      'Validation error': 'Data yang diisi belum sesuai. Coba cek lagi ya.',
      'Unauthenticated.': 'Sesi kamu sudah berakhir. Silakan login lagi ya.',
    };

    if (exactMatches.containsKey(message)) {
      return exactMatches[message]!;
    }

    if (message.contains('Failed host lookup') ||
        message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Connection reset by peer') ||
        message.contains('Connection terminated during handshake') ||
        message.contains('Connection closed before full header was received')) {
      return 'Koneksi ke server lagi bermasalah. Coba sebentar lagi ya.';
    }

    if (message.contains('timed out')) {
      return 'Server lagi lambat merespons. Coba lagi sebentar ya.';
    }

    if (message.startsWith('Insufficient stock for')) {
      return 'Stok produk tidak cukup.';
    }

    if (message.contains('The selected')) {
      return 'Pilihan yang dipilih belum sesuai. Coba cek lagi ya.';
    }

    return message;
  }

  @override
  String toString() => message;
}
