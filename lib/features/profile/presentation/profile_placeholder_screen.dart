import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';

/// Profile tab placeholder (F8 later). Includes logout access.
class ProfilePlaceholderScreen extends ConsumerStatefulWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  ConsumerState<ProfilePlaceholderScreen> createState() =>
      _ProfilePlaceholderScreenState();
}

class _ProfilePlaceholderScreenState
    extends ConsumerState<ProfilePlaceholderScreen> {
  var _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) {
      return;
    }
    setState(() => _loggingOut = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
        actions: [
          IconButton(
            tooltip: l10n.languageLabel,
            onPressed: () {
              ref.read(localeControllerProvider.notifier).toggleArabicEnglish();
            },
            icon: Text(locale.languageCode == 'ar' ? 'EN' : 'ع'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.profilePlaceholderTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.profilePlaceholderBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (user != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.homeSignedInAs(user.name, user.email),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const Spacer(),
              if (user?.mustChangePassword ?? false)
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.changePassword),
                  child: Text(l10n.changePasswordTitle),
                ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _loggingOut ? null : _logout,
                child: _loggingOut
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.logoutAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
