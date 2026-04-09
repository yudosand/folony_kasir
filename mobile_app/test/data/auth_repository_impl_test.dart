import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/core/storage/token_storage.dart';
import 'package:folony_kasir_mobile/data/datasources/local/auth_local_data_source.dart';
import 'package:folony_kasir_mobile/data/datasources/remote/auth_remote_data_source.dart';
import 'package:folony_kasir_mobile/data/dtos/auth_session_dto.dart';
import 'package:folony_kasir_mobile/data/dtos/user_dto.dart';
import 'package:folony_kasir_mobile/data/repositories/auth_repository_impl.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late FakeAuthRemoteDataSource remoteDataSource;
    late FakeAuthLocalDataSource localDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      remoteDataSource = FakeAuthRemoteDataSource();
      localDataSource = FakeAuthLocalDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );
    });

    test('login saves token and returns session', () async {
      final session = await repository.login(
        phone: '085891585422',
        password: '123456',
      );

      expect(session.token, 'token-login');
      expect(session.user.phone, '085891585422');
      expect(localDataSource.savedToken, 'token-login');
    });

    test('register saves token and returns session', () async {
      remoteDataSource.sessionDto = AuthSessionDto(
        token: 'token-register',
        tokenType: 'Bearer',
        user: UserDto(
          id: 2,
          name: 'Register User',
          email: 'register@foloni.com',
          phone: '08123456789',
          createdAt: DateTime.parse('2026-03-27T10:00:00Z'),
        ),
      );

      final session = await repository.register(
        name: 'Register User',
        phone: '08123456789',
        password: '123456',
        passwordConfirmation: '123456',
        referal: 'FOLONI_ADM01',
      );

      expect(session.token, 'token-register');
      expect(session.user.name, 'Register User');
      expect(localDataSource.savedToken, 'token-register');
    });

    test('logout clears token and notifies remote endpoint', () async {
      await repository.logout();

      expect(remoteDataSource.logoutCalled, isTrue);
      expect(localDataSource.clearTokenCalled, isTrue);
    });
  });
}

class FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  FakeAuthRemoteDataSource() : super(Dio());

  AuthSessionDto sessionDto = AuthSessionDto(
    token: 'token-login',
    tokenType: 'Bearer',
    user: UserDto(
      id: 1,
      name: 'Demo User',
      email: 'demo@foloni.com',
      phone: '085891585422',
      createdAt: DateTime.parse('2026-03-27T10:00:00Z'),
    ),
  );

  bool logoutCalled = false;

  @override
  Future<AuthSessionDto> login({
    required String phone,
    required String password,
  }) async {
    return sessionDto;
  }

  @override
  Future<AuthSessionDto> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) async {
    return sessionDto;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

class FakeAuthLocalDataSource extends AuthLocalDataSource {
  FakeAuthLocalDataSource() : super(FakeTokenStorage());

  String? savedToken;
  bool clearTokenCalled = false;

  @override
  Future<void> saveToken(String token) async {
    savedToken = token;
  }

  @override
  Future<void> clearToken() async {
    clearTokenCalled = true;
    savedToken = null;
  }
}

class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage() : super(const FlutterSecureStorage());
}
