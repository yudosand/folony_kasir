import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/auth_session.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, AuthSession?>(
        SessionController.new);

class SessionController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    ref.read(sessionInvalidationBusProvider).register(handleUnauthorized);

    final repository = ref.read(authRepositoryProvider);
    final cachedSession = await repository.readCachedSession();
    if (cachedSession != null) {
      unawaited(_refreshSessionInBackground());
      return cachedSession;
    }

    return ref.read(restoreSessionUseCaseProvider).call();
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final previousState = state;
    state = const AsyncLoading();

    try {
      final session = await ref.read(loginUseCaseProvider).call(
            phone: phone,
            password: password,
          );
      state = AsyncData(session);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String referal,
  }) async {
    final previousState = state;
    state = const AsyncLoading();

    try {
      final session = await ref.read(registerUseCaseProvider).call(
            name: name,
            phone: phone,
            password: password,
            passwordConfirmation: passwordConfirmation,
            referal: referal,
          );
      state = AsyncData(session);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> logout() async {
    final previousState = state;
    state = const AsyncLoading();

    try {
      await ref.read(logoutUseCaseProvider).call();
      state = const AsyncData(null);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> handleUnauthorized() async {
    await ref.read(logoutUseCaseProvider).call(notifyServer: false);
    state = const AsyncData(null);
  }

  Future<void> _refreshSessionInBackground() async {
    try {
      final restoredSession = await ref.read(restoreSessionUseCaseProvider).call();
      state = AsyncData(restoredSession);
    } catch (_) {
      // Keep cached session on screen if the refresh endpoint is temporarily slow.
    }
  }
}
