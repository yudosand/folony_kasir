import '../../domain/entities/auth_session.dart';
import 'user_dto.dart';

class AuthSessionDto {
  AuthSessionDto({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final UserDto user;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw ArgumentError('Missing user payload.');
    }

    return AuthSessionDto(
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserDto.fromJson(userJson),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      tokenType: tokenType,
      user: user.toEntity(),
    );
  }
}
