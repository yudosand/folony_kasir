class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.externalMemberId,
    this.accountType,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? externalMemberId;
  final String? accountType;
  final DateTime? createdAt;
}
