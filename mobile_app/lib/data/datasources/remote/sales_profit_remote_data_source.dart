import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/sales_profit_report_dto.dart';

class SalesProfitRemoteDataSource {
  SalesProfitRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SalesProfitReportDto> getReport({
    String? search,
    String? paymentMethod,
    String? profitStatus,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.salesProfitReport,
        queryParameters: {
          'search': search,
          'payment_method': paymentMethod,
          'profit_status': profitStatus,
          'date_from': dateFrom,
          'date_to': dateTo,
        }..removeWhere((key, value) => value == null || value == ''),
      );

      return SalesProfitReportDto.fromJson(_extractData(response));
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
