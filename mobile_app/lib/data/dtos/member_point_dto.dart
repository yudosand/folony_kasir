import '../../domain/entities/member_point_member.dart';
import '../../domain/entities/member_point_usage.dart';

class MemberPointMemberDto {
  const MemberPointMemberDto({
    required this.id,
    required this.name,
    required this.points,
  });

  final int id;
  final String name;
  final int points;

  factory MemberPointMemberDto.fromJson(Map<String, dynamic> json) {
    return MemberPointMemberDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }

  MemberPointMember toEntity() {
    return MemberPointMember(
      id: id,
      name: name,
      points: points,
    );
  }
}

class MemberPointUsageDto {
  const MemberPointUsageDto({
    required this.memberId,
    required this.memberName,
    required this.pointsBefore,
    required this.pointsUsed,
    required this.pointsAfter,
    required this.valueAmount,
    required this.status,
    this.description,
  });

  final int? memberId;
  final String? memberName;
  final int? pointsBefore;
  final int pointsUsed;
  final int? pointsAfter;
  final double valueAmount;
  final String status;
  final String? description;

  factory MemberPointUsageDto.fromJson(Map<String, dynamic> json) {
    return MemberPointUsageDto(
      memberId: (json['member_id'] as num?)?.toInt(),
      memberName: json['member_name'] as String?,
      pointsBefore: (json['points_before'] as num?)?.toInt(),
      pointsUsed: (json['points_used'] as num?)?.toInt() ?? 0,
      pointsAfter: (json['points_after'] as num?)?.toInt(),
      valueAmount: (json['value_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'none',
      description: json['description'] as String?,
    );
  }

  MemberPointUsage toEntity() {
    return MemberPointUsage(
      memberId: memberId,
      memberName: memberName,
      pointsBefore: pointsBefore,
      pointsUsed: pointsUsed,
      pointsAfter: pointsAfter,
      valueAmount: valueAmount,
      status: status,
      description: description,
    );
  }
}
