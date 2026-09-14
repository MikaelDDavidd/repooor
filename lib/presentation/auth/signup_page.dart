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

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          name: _nameController.text.trim(),
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seus produtos, compras e despensa deste aparelho continuam aqui e passam a ficar salvos na sua conta.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                _buildFields(isLoading),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  AuthErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Criar conta',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                _buildLoginLink(isLoading),
              ],
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
          label: 'Nome',
          controller: _nameController,
          hint: 'Como quer ser chamado',
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.name],
          validator: AuthValidators.name,
        ),
        const SizedBox(height: 16),
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
          hint: 'Pelo menos 8 caracteres',
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.newPassword],
          validator: AuthValidators.newPassword,
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  Widget _buildLoginLink(bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => context.go('/login'),
      child: Text(
        'Já tenho conta. Entrar',
        style: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.primaryStrong,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
