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
import 'package:khamasiyat_mobile_app/shared/validation/sudan_phone.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
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
    final phone = SudanPhone.normalizeToE164(_phone.text) ?? _phone.text.trim();

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).registerStart(
            name: _name.text,
            email: email,
            phone: phone,
          );
      if (!mounted) {
        return;
      }
      await context.push(
        AppRoutes.registerVerify,
        extra: email,
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
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
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
              controller: _name,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.nameLabel),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return l10n.validationNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _email,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
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
            TextFormField(
              controller: _phone,
              enabled: !_loading,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.phoneLabel,
                hintText: l10n.phoneHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationPhoneRequired;
                }
                if (!SudanPhone.isValidMobile(value)) {
                  return l10n.validationPhoneInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthSubmitButton(
              label: l10n.registerContinueAction,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _loading ? null : () => context.go(AppRoutes.login),
              child: Text(l10n.haveAccountLink),
            ),
          ],
        ),
      ),
    );
  }
}
