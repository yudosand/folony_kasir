import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) async {
    final session = await _remoteDataSource.register(
      name: name,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      referal: referal,
    );
    final entity = session.toEntity();
    await _localDataSource.saveSession(entity);

    return entity;
  }

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      phone: phone,
      password: password,
    );
    final entity = session.toEntity();
    await _localDataSource.saveSession(entity);

    return entity;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearToken();
  }

  @override
  Future<void> clearSession() {
    return _localDataSource.clearSession();
  }

  @override
  Future<String?> readToken() {
    return _localDataSource.readToken();
  }

  @override
  Future<AuthSession?> readCachedSession() {
    return _localDataSource.readCachedSession();
  }

  @override
  Future<AppUser> getMe() async {
    final user = await _remoteDataSource.getMe();
    final token = await _localDataSource.readToken();
    if (token != null && token.isNotEmpty) {
      await _localDataSource.saveSession(
        AuthSession(
          token: token,
          tokenType: 'Bearer',
          user: user.toEntity(),
        ),
      );
    }

    return user.toEntity();
  }
}
