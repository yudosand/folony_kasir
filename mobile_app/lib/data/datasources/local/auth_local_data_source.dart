import '../../../core/storage/token_storage.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> saveToken(String token) {
    return _tokenStorage.saveToken(token);
  }

  Future<String?> readToken() {
    return _tokenStorage.readToken();
  }

  Future<void> clearToken() {
    return _tokenStorage.clearToken();
  }
}
