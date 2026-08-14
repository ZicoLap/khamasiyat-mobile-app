import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_validators.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/widgets/auth_widgets.dart';

class RegisterVerifyScreen extends ConsumerStatefulWidget {
  const RegisterVerifyScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<RegisterVerifyScreen> createState() =>
      _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends ConsumerState<RegisterVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  var _resending = false;
  String? _error;
  String? _info;
  Timer? _cooldownTimer;
  var _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = kOtpResendCooldown.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    setState(() {
      _error = null;
      _info = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).registerVerify(
            email: widget.email,
            otp: _otp.text,
            password: _password.text,
            confirmPassword: _confirm.text,
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

  Future<void> _resend() async {
    if (_resending || _cooldownSeconds > 0) {
      return;
    }
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendRegistrationOtp(widget.email);
      if (!mounted) {
        return;
      }
      setState(() => _info = context.l10n.otpResentInfo);
      _startCooldown();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = mapAuthError(error, context.l10n));
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = _loading || _resending;

    return AuthScaffold(
      title: l10n.registerVerifyTitle,
      subtitle: l10n.registerVerifySubtitle(widget.email),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              AuthErrorBanner(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_info != null) ...[
              Text(_info!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
            ],
            TextFormField(
              controller: _otp,
              enabled: !busy,
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
              label: l10n.passwordLabel,
              enabled: !busy,
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
              enabled: !busy,
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
              label: l10n.registerVerifyAction,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: (_cooldownSeconds > 0 || busy) ? null : _resend,
              child: Text(
                _cooldownSeconds > 0
                    ? l10n.otpResendCooldown(_cooldownSeconds)
                    : l10n.otpResendAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
