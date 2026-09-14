import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';
import 'auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (failure == null) {
      context.go('/home');
    } else {
      setState(() => _errorMessage = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LoginHeader(),
                  const SizedBox(height: 32),
                  _buildFields(isLoading),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    AuthErrorBanner(message: _errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  AuthSubmitButton(
                    label: 'Entrar',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  _buildSignupLink(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'E-mail',
          controller: _emailController,
          hint: 'voce@exemplo.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.email],
          validator: AuthValidators.email,
        ),
        const SizedBox(height: 16),
        AuthPasswordField(
          label: 'Senha',
          controller: _passwordController,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.password],
          validator: AuthValidators.password,
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  Widget _buildSignupLink(bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => context.go('/signup'),
      child: Text(
        'Ainda não tem conta? Criar conta',
        style: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.primaryStrong,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.shopping_basket_rounded,
          size: 64,
          color: AppColors.primaryStrong,
        ),
        const SizedBox(height: 16),
        Text('Entrar', style: AppTextStyles.heading1),
        const SizedBox(height: 8),
        Text(
          'Acesse sua despensa em qualquer aparelho',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
