import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/localization/locale_controller.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/app_clock.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/catalog_state.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_greeting.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_hero_artwork.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final firstName =
        auth is AuthAuthenticated ? auth.user.name.split(' ').first : '';
    final catalog = ref.watch(catalogControllerProvider(CatalogScope.home));
    final controller = ref.read(
      catalogControllerProvider(CatalogScope.home).notifier,
    );
    final locale = ref.watch(localeControllerProvider);
    final clock = ref.watch(appClockProvider);
    final greeting = homeGreeting(
      l10n: l10n,
      clock: clock,
      firstName: firstName,
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 240) {
              controller.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHero(
                  brand: l10n.brandName,
                  greeting: greeting,
                  headline: l10n.homeHeadline,
                  support: l10n.homeHeroSupport,
                  localeCode: locale.languageCode,
                  decorativeArtwork: HomeHeroArtwork.productionProvider,
                  onToggleLocale: () {
                    ref
                        .read(localeControllerProvider.notifier)
                        .toggleArabicEnglish();
                  },
                  languageTooltip: l10n.languageLabel,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  // Hero → Explore: ~16–20px total breathing room.
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.homeStadiumsSection,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.search),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              foregroundColor: AppColors.primary,
                            ),
                            child: Text(l10n.homeSeeAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      CatalogFilterControls(
                        filters: catalog.filters,
                        dense: true,
                        onApplied: controller.applyFilters,
                        onClearAll:
                            catalog.filters.hasAny
                                ? controller.clearFilters
                                : null,
                      ),
                      if (catalog.error != null &&
                          catalog.status != CatalogStatus.failure) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          mapAuthError(catalog.error!, l10n),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ..._catalogSlivers(context, catalog, controller),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact welcoming brand hero — no Search CTA.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.brand,
    required this.greeting,
    required this.headline,
    required this.support,
    required this.localeCode,
    required this.onToggleLocale,
    required this.languageTooltip,
    this.decorativeArtwork,
  });

  final String brand;
  final String greeting;
  final String headline;
  final String support;
  final String localeCode;
  final VoidCallback onToggleLocale;
  final String languageTooltip;

  /// Optional decorative sports art (LTR trailing / RTL leading).
  final ImageProvider? decorativeArtwork;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final hasArt = decorativeArtwork != null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.xl),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandDeep,
              AppColors.brandDeepLift,
              AppColors.brandDeepGlow,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _HeroPitchPainter()),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                top + AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          brand,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppColors.heroOnBrand,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                      _LanguageChip(
                        label: localeCode == 'ar' ? 'EN' : 'ع',
                        tooltip: languageTooltip,
                        onPressed: onToggleLocale,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.heroOnBrandSoft,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headline,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: AppColors.heroOnBrand,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              support,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppColors.heroOnBrandMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasArt) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _HeroArtwork(provider: decorativeArtwork!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.provider});

  final ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Cap art so it stays ~20–30% on narrow phones.
    final size =
        width < 360
            ? HomeHeroArtwork.displaySize * 0.85
            : HomeHeroArtwork.displaySize;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Image(
          image: provider,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.heroOnBrand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: AppColors.heroOnBrand.withValues(alpha: 0.18),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.heroOnBrand,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Near-invisible pitch geometry (~5–8% opacity).
class _HeroPitchPainter extends CustomPainter {
  const _HeroPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.heroPitchLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final inset = size.width * 0.08;
    final field = Rect.fromLTWH(
      inset,
      size.height * 0.18,
      size.width - inset * 2,
      size.height * 0.72,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(4)),
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(field.center.dx, field.bottom - field.height * 0.08),
        radius: field.width * 0.18,
      ),
      -3.0,
      2.2,
      false,
      paint,
    );

    final boxW = field.width * 0.28;
    final boxH = field.height * 0.22;
    final box = Rect.fromLTWH(field.left, field.bottom - boxH, boxW, boxH);
    canvas.drawLine(box.topLeft, box.topRight, paint);
    canvas.drawLine(box.topRight, box.bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

List<Widget> _catalogSlivers(
  BuildContext context,
  CatalogState catalog,
  CatalogController controller,
) {
  final l10n = context.l10n;

  if (catalog.status == CatalogStatus.initial ||
      catalog.status == CatalogStatus.loading) {
    return [const CatalogSkeletonList()];
  }

  if (catalog.status == CatalogStatus.failure) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: CatalogErrorView(
          message: mapAuthError(catalog.error!, l10n),
          onRetry: controller.loadInitial,
        ),
      ),
    ];
  }

  if (catalog.status == CatalogStatus.empty || catalog.items.isEmpty) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: CatalogEmptyView(
          onClearFilters:
              catalog.filters.hasAny ? controller.clearFilters : null,
        ),
      ),
    ];
  }

  return [
    // Tighter gap from filters → first photography card.
    SliverPadding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverList.separated(
        itemCount: catalog.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final stadium = catalog.items[index];
          return DiscoveryStadiumCard(
            stadium: stadium,
            onTap: () => context.push(AppRoutes.stadiumDetail(stadium.id)),
          );
        },
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: _PaginationFooter(catalog: catalog, controller: controller),
      ),
    ),
  ];
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.catalog, required this.controller});

  final CatalogState catalog;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (catalog.status == CatalogStatus.loadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (catalog.loadMoreError != null) {
      return Center(
        child: TextButton(
          onPressed: controller.retryLoadMore,
          child: Text(l10n.catalogLoadMoreRetry),
        ),
      );
    }
    if (!catalog.hasMore) {
      return Center(
        child: Text(
          l10n.catalogEndOfList,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
