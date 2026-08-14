import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_validators.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/widgets/auth_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: widget.email,
            otp: _otp.text,
            newPassword: _password.text,
            confirmPassword: _confirm.text,
          );
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.resetPasswordSuccess)),
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
      title: l10n.resetPasswordTitle,
      subtitle: l10n.resetPasswordSubtitle(widget.email),
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
              controller: _otp,
              enabled: !_loading,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(labelText: l10n.otpLabel),
              validator: (value) {
                final otp = value?.trim() ?? '';
                if (otp.length < 4 || otp.length > 8) {
                  return l10n.validationOtpInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            PasswordFormField(
              controller: _password,
              label: l10n.newPasswordLabel,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || !isValidPasswordShape(value)) {
                  return l10n.validationPasswordWeak;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            PasswordFormField(
              controller: _confirm,
              label: l10n.confirmPasswordLabel,
              enabled: !_loading,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if (value != _password.text) {
                  return l10n.validationPasswordMismatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthSubmitButton(
              label: l10n.resetPasswordAction,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
