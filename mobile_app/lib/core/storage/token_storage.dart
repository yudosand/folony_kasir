import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'auth_token_type';
  static const String _userJsonKey = 'auth_user_json';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveTokenType(String tokenType) {
    return _storage.write(key: _tokenTypeKey, value: tokenType);
  }

  Future<void> saveUserJson(String userJson) {
    return _storage.write(key: _userJsonKey, value: userJson);
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> readTokenType() {
    return _storage.read(key: _tokenTypeKey);
  }

  Future<String?> readUserJson() {
    return _storage.read(key: _userJsonKey);
  }

  Future<void> clearToken() {
    return clearSession();
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _userJsonKey);
  }
}
