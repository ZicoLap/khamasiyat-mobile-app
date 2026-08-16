import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/profile/presentation/widgets/profile_widgets.dart';

/// Customer profile hub: identity, name edit, password, language, sign out.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var _loggingOut = false;

  Future<void> _refresh() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshMe();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapAuthError(error, context.l10n))),
      );
    }
  }

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
    final languageValue = locale.languageCode == 'ar'
        ? l10n.profileLanguageArabic
        : l10n.profileLanguageEnglish;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.profileTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
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
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            children: [
              if (user != null) ...[
                ProfileHeader(name: user.name, email: user.email),
                const SizedBox(height: AppSpacing.md),
                ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileInfoRow(
                        label: l10n.phoneLabel,
                        value: user.phone,
                      ),
                      ProfileInfoRow(
                        label: l10n.profileEmailStatusLabel,
                        value: user.emailVerified
                            ? l10n.profileEmailVerified
                            : l10n.profileEmailUnverified,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.profileImmutableHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProfileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileSettingsTile(
                        icon: Icons.badge_outlined,
                        label: l10n.profileEditName,
                        onTap: () => context.push(AppRoutes.editName),
                      ),
                      const Divider(height: 1),
                      ProfileSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: l10n.changePasswordTitle,
                        onTap: () => context.push(AppRoutes.changePassword),
                      ),
                      const Divider(height: 1),
                      ProfileSettingsTile(
                        icon: Icons.language_rounded,
                        label: l10n.languageLabel,
                        value: languageValue,
                        onTap: () {
                          ref
                              .read(localeControllerProvider.notifier)
                              .toggleArabicEnglish();
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
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
