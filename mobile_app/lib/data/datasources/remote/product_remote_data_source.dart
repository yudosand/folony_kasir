import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/product_dto.dart';
import '../../dtos/product_list_response_dto.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductListResponseDto> getProducts({
    String? search,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.products,
        queryParameters: {
          'search': search,
          'per_page': perPage,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      return ProductListResponseDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<ProductDto> createProduct({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.products,
        data: await _buildFormData(
          name: name,
          stock: stock,
          costPrice: costPrice,
          sellingPrice: sellingPrice,
          imageFilePath: imageFilePath,
        ),
      );

      return _extractProduct(response);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<ProductDto> updateProduct({
    required int productId,
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
    required bool removeImage,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConstants.products}/$productId',
        data: await _buildFormData(
          name: name,
          stock: stock,
          costPrice: costPrice,
          sellingPrice: sellingPrice,
          imageFilePath: imageFilePath,
          removeImage: removeImage,
          methodOverride: 'PUT',
        ),
      );

      return _extractProduct(response);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _dio
          .delete<Map<String, dynamic>>('${ApiConstants.products}/$productId');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<FormData> _buildFormData({
    required String name,
    required int stock,
    required double costPrice,
    required double sellingPrice,
    String? imageFilePath,
    bool removeImage = false,
    String? methodOverride,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'stock': stock.toString(),
      'cost_price': costPrice.toString(),
      'selling_price': sellingPrice.toString(),
      'remove_image': removeImage ? '1' : '0',
      if (methodOverride != null) '_method': methodOverride,
    });

    if (imageFilePath != null && imageFilePath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(imageFilePath),
        ),
      );
    }

    return formData;
  }

  ProductDto _extractProduct(Response<Map<String, dynamic>> response) {
    final data = _extractData(response);
    final productJson = data['product'];
    if (productJson is! Map<String, dynamic>) {
      throw ApiException(message: 'Data produk belum tersedia. Coba lagi ya.');
    }

    return ProductDto.fromJson(productJson);
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
