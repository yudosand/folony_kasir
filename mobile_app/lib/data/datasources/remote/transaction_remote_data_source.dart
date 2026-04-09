import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/invoice_dto.dart';
import '../../dtos/transaction_dto.dart';
import '../../dtos/transaction_list_response_dto.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<TransactionDto> createTransaction({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required double cashAmount,
    required double nonCashAmount,
    int? memberId,
    int? pointsUsed,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.transactions,
        data: {
          'items': items,
          if (memberId != null) 'member_id': memberId,
          if (pointsUsed != null && pointsUsed > 0) 'points_used': pointsUsed,
          'payment_method': paymentMethod,
          'cash_amount': cashAmount,
          'non_cash_amount': nonCashAmount,
        },
      );

      final data = _extractData(response);
      final transactionJson = data['transaction'];
      if (transactionJson is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Data transaksi belum tersedia. Coba lagi ya.',
        );
      }

      return TransactionDto.fromJson(transactionJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<TransactionListResponseDto> getTransactions({
    int perPage = 100,
    int page = 1,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.transactions,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        },
      );

      return TransactionListResponseDto.fromJson(_extractData(response));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<InvoiceDto> getInvoice(int transactionId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.transactions}/$transactionId/invoice',
      );

      final data = _extractData(response);
      final invoiceJson = data['invoice'];
      if (invoiceJson is! Map<String, dynamic>) {
        throw ApiException(message: 'Data invoice belum tersedia. Coba lagi ya.');
      }

      return InvoiceDto.fromJson(invoiceJson);
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
