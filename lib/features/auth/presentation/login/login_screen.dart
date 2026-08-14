import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_validators.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      if (auth is AuthUnauthenticated) {
        final mapped = mapAuthMessageCode(auth.messageCode, context.l10n);
        if (mapped != null) {
          setState(() => _error = mapped);
          ref.read(authControllerProvider.notifier).clearTransientMessage();
        }
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text,
            password: _password.text,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = mapAuthError(error, context.l10n));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              TextFormField(
                controller: _email,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationEmailRequired;
                  }
                  if (!isValidEmail(value)) {
                    return l10n.validationEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordFormField(
                controller: _password,
                label: l10n.passwordLabel,
                enabled: !_loading,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => context.push(AppRoutes.forgotPassword),
                  child: Text(l10n.forgotPasswordLink),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AuthSubmitButton(
                label: l10n.loginAction,
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed:
                    _loading ? null : () => context.push(AppRoutes.register),
                child: Text(l10n.createAccountLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
