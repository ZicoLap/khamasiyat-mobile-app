import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_validators.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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

    final email = _email.text.trim();
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(email);
      if (!mounted) {
        return;
      }
      await context.push(AppRoutes.resetPassword, extra: email);
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
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
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
            const SizedBox(height: AppSpacing.lg),
            AuthSubmitButton(
              label: l10n.forgotPasswordAction,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
