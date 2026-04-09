import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referalController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _submitErrorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _referalController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      await ref.read(sessionControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            referal: _referalController.text.trim(),
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
      title: 'Daftar',
      subtitle: 'Buat akun untuk mulai pakai Folony Kasir.',
      errorMessage: _submitErrorMessage,
      leading: IconButton.filledTonal(
        onPressed: isLoading ? null : () => context.go(AppRoutes.login),
        icon: const Icon(Icons.arrow_back),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama lengkap',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi ya.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
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
              controller: _referalController,
              label: 'Kode Referal',
              hintText: 'Masukkan kode referal',
              prefixIcon: Icons.verified_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kode referal wajib diisi ya.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Minimal 6 karakter',
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
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              hintText: 'Ulangi password',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password wajib diisi ya.';
                }

                if (value != _passwordController.text) {
                  return 'Konfirmasi password belum cocok, coba cek lagi ya.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Daftar',
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
                    'Sudah punya akun?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.go(AppRoutes.login),
                    child: const Text('Masuk'),
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
