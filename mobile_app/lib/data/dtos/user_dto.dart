import '../../domain/entities/app_user.dart';

class UserDto {
  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.externalMemberId,
    this.accountType,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? externalMemberId;
  final String? accountType;
  final DateTime? createdAt;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      externalMemberId: json['external_member_id'] as String?,
      accountType: json['account_type'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      externalMemberId: externalMemberId,
      accountType: accountType,
      createdAt: createdAt,
    );
  }
}
