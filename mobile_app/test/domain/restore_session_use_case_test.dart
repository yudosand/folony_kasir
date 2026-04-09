import 'package:flutter_test/flutter_test.dart';

import 'package:folony_kasir_mobile/core/errors/api_exception.dart';
import 'package:folony_kasir_mobile/domain/entities/app_user.dart';
import 'package:folony_kasir_mobile/domain/entities/auth_session.dart';
import 'package:folony_kasir_mobile/domain/repositories/auth_repository.dart';
import 'package:folony_kasir_mobile/domain/usecases/restore_session_use_case.dart';

void main() {
  group('RestoreSessionUseCase', () {
    test('returns null when token is missing', () async {
      final repository = FakeAuthRepository();
      final useCase = RestoreSessionUseCase(repository);

      final result = await useCase.call();

      expect(result, isNull);
    });

    test('restores session using stored token and me endpoint', () async {
      final repository = FakeAuthRepository(
        storedToken: 'token-active',
      );
      final useCase = RestoreSessionUseCase(repository);

      final result = await useCase.call();

      expect(result, isA<AuthSession>());
      expect(result?.token, 'token-active');
      expect(result?.user.email, 'demo@foloni.com');
      expect(repository.getMeCalled, isTrue);
    });

    test('clears token and returns null on unauthorized me response', () async {
      final repository = FakeAuthRepository(
        storedToken: 'expired-token',
        meException: ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        ),
      );
      final useCase = RestoreSessionUseCase(repository);

      final result = await useCase.call();

      expect(result, isNull);
      expect(repository.clearSessionCalled, isTrue);
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.storedToken,
    this.meException,
  });

  final String? storedToken;
  final ApiException? meException;
  bool getMeCalled = false;
  bool clearSessionCalled = false;

  @override
  Future<void> clearSession() async {
    clearSessionCalled = true;
  }

  @override
  Future<AppUser> getMe() async {
    getMeCalled = true;

    if (meException != null) {
      throw meException!;
    }

    return const AppUser(
      id: 1,
      name: 'Demo User',
      email: 'demo@foloni.com',
      phone: '085891585422',
    );
  }

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<String?> readToken() async {
    return storedToken;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) {
    throw UnimplementedError();
  }
}
