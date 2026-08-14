import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_validators.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/widgets/auth_widgets.dart';

/// Change-password screen for `mustChangePassword` and profile infrastructure.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
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
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
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
      title: l10n.changePasswordTitle,
      subtitle: l10n.changePasswordSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              AuthErrorBanner(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            PasswordFormField(
              controller: _current,
              label: l10n.currentPasswordLabel,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationPasswordRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            PasswordFormField(
              controller: _next,
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
                if (value != _next.text) {
                  return l10n.validationPasswordMismatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthSubmitButton(
              label: l10n.changePasswordAction,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
