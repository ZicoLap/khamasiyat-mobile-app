import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';

/// Home discovery card — photography-first with readable overlay.
class DiscoveryStadiumCard extends StatelessWidget {
  const DiscoveryStadiumCard({super.key, required this.stadium, this.onTap});

  static const double imageAspectRatio = 1.55;

  final StadiumListItem stadium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location =
        '${stadium.city.label(l10n)} · ${stadium.state.label(l10n)}';
    final pitches = l10n.stadiumActivePitches(stadium.activePitchCount);

    return Semantics(
      button: onTap != null,
      label: '${stadium.name}, $location, $pitches',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDeep.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: AspectRatio(
                aspectRatio: imageAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    StadiumPhoto(url: stadium.primaryPhoto?.url),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00052E22),
                            Color(0x66052E22),
                            AppColors.imageScrim,
                          ],
                          stops: [0.35, 0.65, 1],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: AppSpacing.md,
                      end: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stadium.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 15,
                                color: Color(0xFFD7E8DE),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFD7E8DE),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                                child: Text(
                                  pitches,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Back-compat alias used by older tests / imports.
typedef StadiumCard = DiscoveryStadiumCard;
