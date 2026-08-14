import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/discovery_stadium_card.dart';

export 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_filter_controls.dart';
export 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_filter_sheet.dart';
export 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/compact_stadium_card.dart';
export 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/discovery_stadium_card.dart';
export 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';

class CatalogEmptyView extends StatelessWidget {
  const CatalogEmptyView({super.key, this.onClearFilters});

  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.onSurfaceMuted,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.catalogEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.catalogEmptyBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onClearFilters != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: onClearFilters,
                child: Text(l10n.catalogClearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CatalogErrorView extends StatelessWidget {
  const CatalogErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.catalogErrorTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      ),
    );
  }
}

/// Lightweight catalog skeleton (no external package).
class CatalogSkeletonList extends StatelessWidget {
  const CatalogSkeletonList({
    super.key,
    this.itemCount = 3,
    this.compact = false,
  });

  final int itemCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SliverPadding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder:
            (context, index) =>
                _SkeletonItem(animate: !reduceMotion, compact: compact),
      ),
    );
  }
}

class _SkeletonItem extends StatefulWidget {
  const _SkeletonItem({required this.animate, required this.compact});

  final bool animate;
  final bool compact;

  @override
  State<_SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<_SkeletonItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = AppColors.surfaceMuted;
    const highlight = AppColors.outlineSubtle;

    Widget body(Color color) {
      if (widget.compact) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(color, width: double.infinity, height: 12),
                    const SizedBox(height: 8),
                    _bar(color, width: 140, height: 10),
                    const SizedBox(height: 8),
                    _bar(color, width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AspectRatio(
          aspectRatio: DiscoveryStadiumCard.imageAspectRatio,
          child: ColoredBox(color: color),
        ),
      );
    }

    final child =
        widget.animate && _controller != null
            ? AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) {
                final color = Color.lerp(base, highlight, _controller!.value)!;
                return body(color);
              },
            )
            : body(base);

    return Semantics(label: 'Loading', child: ExcludeSemantics(child: child));
  }

  Widget _bar(Color color, {required double width, required double height}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
