import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../dtos/member_point_dto.dart';

class MemberPointRemoteDataSource {
  MemberPointRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MemberPointMemberDto> getMemberById(int memberId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.memberPointMembers,
        queryParameters: {
          'member_id': memberId,
        },
      );

      final data = _extractData(response);
      final members = data['members'];
      if (members is! List) {
        throw ApiException(
          message: 'Data member belum tersedia. Coba lagi ya.',
        );
      }

      final firstMember = members.whereType<Map<String, dynamic>>().firstOrNull;
      if (firstMember == null) {
        throw ApiException(
          message: 'Member belum ditemukan. Coba cek lagi ya.',
        );
      }

      return MemberPointMemberDto.fromJson(firstMember);
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
