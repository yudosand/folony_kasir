import '../entities/member_point_member.dart';
import '../repositories/member_point_repository.dart';

class GetMemberPointMemberUseCase {
  const GetMemberPointMemberUseCase(this._repository);

  final MemberPointRepository _repository;

  Future<MemberPointMember> call(int memberId) {
    return _repository.getMemberById(memberId);
  }
}
