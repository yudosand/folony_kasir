import '../../domain/entities/member_point_member.dart';
import '../../domain/repositories/member_point_repository.dart';
import '../datasources/remote/member_point_remote_data_source.dart';

class MemberPointRepositoryImpl implements MemberPointRepository {
  MemberPointRepositoryImpl(this._remoteDataSource);

  final MemberPointRemoteDataSource _remoteDataSource;

  @override
  Future<MemberPointMember> getMemberById(int memberId) async {
    final response = await _remoteDataSource.getMemberById(memberId);
    return response.toEntity();
  }
}
