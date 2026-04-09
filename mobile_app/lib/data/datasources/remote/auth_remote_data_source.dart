import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/auth_session_dto.dart';
import '../../dtos/user_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionDto> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authRegister,
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'referal': referal,
        },
      );

      return AuthSessionDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<AuthSessionDto> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: {
          'phone': phone,
          'password': password,
        },
      );

      return AuthSessionDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<UserDto> getMe() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.authMe);
      final data = _extractData(response);
      final userJson = data['user'];
      if (userJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Data pengguna belum tersedia. Coba login lagi ya.');
      }

      return UserDto.fromJson(userJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<Map<String, dynamic>>(ApiConstants.authLogout);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Map<String, dynamic> _extractData(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) {
      throw ApiException(
        message: 'Respons server kosong. Coba lagi sebentar ya.',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    return data;
  }
}
