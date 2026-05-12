import 'dart:convert';

import '../../../core/storage/token_storage.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/auth_session.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> saveSession(AuthSession session) async {
    await _tokenStorage.saveToken(session.token);
    await _tokenStorage.saveTokenType(session.tokenType);
    await _tokenStorage.saveUserJson(
      jsonEncode(_serializeUser(session.user)),
    );
  }

  Future<void> saveToken(String token) {
    return _tokenStorage.saveToken(token);
  }

  Future<String?> readToken() {
    return _tokenStorage.readToken();
  }

  Future<AuthSession?> readCachedSession() async {
    final token = await _tokenStorage.readToken();
    final userJson = await _tokenStorage.readUserJson();
    if (token == null || token.isEmpty || userJson == null || userJson.isEmpty) {
      return null;
    }

    final tokenType = await _tokenStorage.readTokenType() ?? 'Bearer';
    final decodedUser = jsonDecode(userJson);
    if (decodedUser is! Map<String, dynamic>) {
      return null;
    }

    return AuthSession(
      token: token,
      tokenType: tokenType,
      user: _deserializeUser(decodedUser),
    );
  }

  Future<void> clearToken() {
    return _tokenStorage.clearSession();
  }

  Future<void> clearSession() {
    return _tokenStorage.clearSession();
  }

  Map<String, dynamic> _serializeUser(AppUser user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'external_member_id': user.externalMemberId,
      'account_type': user.accountType,
      'created_at': user.createdAt?.toIso8601String(),
    };
  }

  AppUser _deserializeUser(Map<String, dynamic> json) {
    return AppUser(
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
}
