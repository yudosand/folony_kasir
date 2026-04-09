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
    await _localDataSource.saveToken(session.token);

    return session.toEntity();
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
    await _localDataSource.saveToken(session.token);

    return session.toEntity();
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearToken();
  }

  @override
  Future<void> clearSession() {
    return _localDataSource.clearToken();
  }

  @override
  Future<String?> readToken() {
    return _localDataSource.readToken();
  }

  @override
  Future<AppUser> getMe() async {
    final user = await _remoteDataSource.getMe();
    return user.toEntity();
  }
}
