import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/store_setting_dto.dart';

class StoreSettingRemoteDataSource {
  StoreSettingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<StoreSettingDto?> getStoreSetting() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.storeSetting,
      );

      final data = _extractData(response);
      final storeSettingJson = data['store_setting'];
      if (storeSettingJson is! Map<String, dynamic>) {
        return null;
      }

      return StoreSettingDto.fromJson(storeSettingJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<StoreSettingDto> updateStoreSetting({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    bool removeLogo = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.storeSetting,
        data: await _buildFormData(
          storeName: storeName,
          storeAddress: storeAddress,
          phoneNumber: phoneNumber,
          invoiceFooter: invoiceFooter,
          logoFilePath: logoFilePath,
          removeLogo: removeLogo,
        ),
      );

      final data = _extractData(response);
      final storeSettingJson = data['store_setting'];
      if (storeSettingJson is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Data pengaturan toko belum tersedia. Coba lagi ya.',
        );
      }

      return StoreSettingDto.fromJson(storeSettingJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<FormData> _buildFormData({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String invoiceFooter,
    String? logoFilePath,
    required bool removeLogo,
  }) async {
    final formData = FormData.fromMap({
      '_method': 'PUT',
      'store_name': storeName,
      'store_address': storeAddress,
      'phone_number': phoneNumber,
      'invoice_footer': invoiceFooter,
      'remove_logo': removeLogo ? '1' : '0',
    });

    if (logoFilePath != null && logoFilePath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'logo',
          await MultipartFile.fromFile(logoFilePath),
        ),
      );
    }

    return formData;
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
