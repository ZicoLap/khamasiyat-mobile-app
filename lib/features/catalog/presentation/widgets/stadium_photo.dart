import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';

/// Shared stadium photography treatment for discovery + compact cards.
class StadiumPhoto extends StatelessWidget {
  const StadiumPhoto({
    super.key,
    this.url,
    this.fit = BoxFit.cover,
    this.compactFallback = false,
  });

  /// Test hook — when set, used instead of [Image.network] for any URL.
  @visibleForTesting
  static ImageProvider Function(String url)? debugImageProviderForUrl;

  final String? url;
  final BoxFit fit;
  final bool compactFallback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (url == null || url!.isEmpty) {
      return StadiumPhotoFallback(
        label: l10n.stadiumPhotoPlaceholder,
        compact: compactFallback,
      );
    }

    final debugProvider = debugImageProviderForUrl?.call(url!);
    if (debugProvider != null) {
      return Image(
        image: debugProvider,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image.network(
      url!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder:
          (_, __, ___) => StadiumPhotoFallback(
            label: l10n.stadiumPhotoUnavailable,
            compact: compactFallback,
          ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const ColoredBox(color: AppColors.imageFallback);
      },
    );
  }
}

class StadiumPhotoFallback extends StatelessWidget {
  const StadiumPhotoFallback({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imageFallback,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stadium_outlined,
                size: compact ? 22 : 32,
                color: AppColors.onImageFallback.withValues(alpha: 0.85),
              ),
              SizedBox(height: compact ? 2 : 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onImageFallback.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
