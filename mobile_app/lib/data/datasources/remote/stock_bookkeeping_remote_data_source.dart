import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/stock_bookkeeping_report_dto.dart';
import '../../dtos/stock_card_dto.dart';

class StockBookkeepingRemoteDataSource {
  StockBookkeepingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<StockBookkeepingReportDto> getReport({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.stockBookkeepingReport,
        queryParameters: {
          'search': search,
          'status': status,
          'date_from': dateFrom,
          'date_to': dateTo,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      return StockBookkeepingReportDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<StockCardDto> getStockCard(
    int productId, {
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.stockCard(productId),
        queryParameters: {
          'date_from': dateFrom,
          'date_to': dateTo,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      return StockCardDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<StockCardDto> restockProduct({
    required int productId,
    required int quantity,
    double? unitCost,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.stockRestocks(productId),
        data: {
          'quantity': quantity,
          'unit_cost': unitCost,
          'notes': notes,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      final data = _extractData(response);
      final cardJson = data['stock_card'];
      if (cardJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Data kartu stok belum tersedia.');
      }

      return StockCardDto.fromJson(cardJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<StockCardDto> adjustProduct({
    required int productId,
    required String direction,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.stockAdjustments(productId),
        data: {
          'direction': direction,
          'quantity': quantity,
          'notes': notes,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      final data = _extractData(response);
      final cardJson = data['stock_card'];
      if (cardJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Data kartu stok belum tersedia.');
      }

      return StockCardDto.fromJson(cardJson);
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
