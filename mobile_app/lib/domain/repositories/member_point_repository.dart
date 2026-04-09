import '../entities/member_point_member.dart';

abstract class MemberPointRepository {
  Future<MemberPointMember> getMemberById(int memberId);
}
