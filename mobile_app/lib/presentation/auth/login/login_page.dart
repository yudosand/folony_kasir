import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _submitErrorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitErrorMessage = null;
    });

    try {
      await ref.read(sessionControllerProvider.notifier).login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitErrorMessage = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final isLoading = sessionState.isLoading;

    return AuthScaffold(
      title: 'Masuk',
      subtitle: 'Masuk untuk mulai kelola toko kamu.',
      errorMessage: _submitErrorMessage,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _phoneController,
              label: 'Nomor HP',
              hintText: 'Masukkan nomor HP',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor HP wajib diisi ya.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Masukkan password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi ya.';
                }

                if (value.length < 6) {
                  return 'Password minimal 6 karakter ya.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Masuk',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Belum punya akun?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.go(AppRoutes.register),
                    child: const Text('Daftar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
