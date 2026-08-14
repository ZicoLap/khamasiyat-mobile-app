import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';

/// Search result row — compact horizontal scan layout.
class CompactStadiumCard extends StatelessWidget {
  const CompactStadiumCard({super.key, required this.stadium, this.onTap});

  static const double thumbSize = 84;

  final StadiumListItem stadium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final location =
        '${stadium.city.label(l10n)} · ${stadium.state.label(l10n)}';
    final pitches = l10n.stadiumActivePitches(stadium.activePitchCount);

    return Semantics(
      button: onTap != null,
      label: '${stadium.name}, $location, $pitches',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    width: thumbSize,
                    height: thumbSize,
                    child: StadiumPhoto(
                      url: stadium.primaryPhoto?.url,
                      compactFallback: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stadium.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pitches,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: AppColors.onSurfaceMuted.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
