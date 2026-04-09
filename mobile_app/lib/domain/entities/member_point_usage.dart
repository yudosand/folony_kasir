class MemberPointUsage {
  const MemberPointUsage({
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
}
