import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';

class StadiumDetailHero extends StatefulWidget {
  const StadiumDetailHero({
    super.key,
    required this.photos,
    required this.stadiumName,
    required this.locationLine,
    required this.onBack,
    this.contentOverlap = StadiumDetailLayout.contentOverlap,
  });

  final List<StadiumPhotoItem> photos;
  final String stadiumName;
  final String locationLine;
  final VoidCallback onBack;

  /// How far the content sheet will cover the bottom of this hero.
  final double contentOverlap;

  static double heightFor(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    if (h < 700) return 260;
    return 310;
  }

  /// Layout height consumed in the scroll view (hero paints [overlap] past this).
  static double layoutHeightFor(BuildContext context, {double? overlap}) {
    final o = overlap ?? StadiumDetailLayout.contentOverlap;
    return totalHeightFor(context) - o;
  }

  static double totalHeightFor(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return heightFor(context) + topInset * 0.35;
  }

  @override
  State<StadiumDetailHero> createState() => _StadiumDetailHeroState();
}

/// Shared Stadium Detail layout tokens for hero ↔ content transition.
abstract final class StadiumDetailLayout {
  /// How far the content sheet rises into the hero photograph.
  static const double contentOverlap = 28;

  /// Rounded top corners of the foreground content sheet.
  static const double contentTopRadius = 28;

  static const BorderRadius contentTopBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(contentTopRadius),
    topRight: Radius.circular(contentTopRadius),
  );
}

/// Warm canvas sheet that overlaps the hero. Rounded top corners only.
class StadiumDetailContentSheet extends StatelessWidget {
  const StadiumDetailContentSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: StadiumDetailLayout.contentTopBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: StadiumDetailLayout.contentTopBorderRadius,
        child: ColoredBox(color: AppColors.canvas, child: child),
      ),
    );
  }
}

class _StadiumDetailHeroState extends State<StadiumDetailHero> {
  late final PageController _pageController;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final photos = widget.photos;
    final multi = photos.length > 1;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = StadiumDetailHero.totalHeightFor(context);
    // Keep title/location above the overlapping content sheet.
    final titleBottom = widget.contentOverlap + AppSpacing.md;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Square / full-bleed hero — content sheet owns the curved transition.
          multi
              ? PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return Semantics(
                    label: l10n.stadiumDetailPhotoSemantic(
                      widget.stadiumName,
                      i + 1,
                      photos.length,
                    ),
                    image: true,
                    child: StadiumPhoto(url: photos[i].url),
                  );
                },
              )
              : Semantics(
                label: l10n.stadiumDetailPhotoSemantic(
                  widget.stadiumName,
                  1,
                  photos.isEmpty ? 1 : 1,
                ),
                image: true,
                child: StadiumPhoto(
                  url: photos.isEmpty ? null : photos.first.url,
                ),
              ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22081612),
                  Color(0x00081612),
                  Color(0xCC081612),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          PositionedDirectional(
            top: topInset + AppSpacing.xs,
            start: AppSpacing.sm,
            child: _HeroCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: widget.onBack,
            ),
          ),
          if (multi)
            PositionedDirectional(
              bottom: titleBottom + 52,
              end: AppSpacing.md,
              child: Text(
                l10n.stadiumDetailPhotoCount(_index + 1, photos.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PositionedDirectional(
            start: AppSpacing.md,
            end: AppSpacing.md,
            bottom: titleBottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.stadiumName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.locationLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
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
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Semantics(
          button: true,
          label: tooltip,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: AppColors.brandDeep, size: 22),
          ),
        ),
      ),
    );
  }
}

class StadiumSummaryPanel extends StatelessWidget {
  const StadiumSummaryPanel({super.key, required this.stadium});

  final StadiumDetail stadium;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = <Widget>[];

    if (stadium.pitches.isNotEmpty) {
      tiles.add(
        _SummaryTile(
          icon: Icons.sports_soccer_rounded,
          label: l10n.stadiumDetailPitchCount(stadium.pitches.length),
        ),
      );
    }

    final types = stadium.availablePitchTypes;
    if (types.isNotEmpty) {
      tiles.add(
        _SummaryTile(
          icon: Icons.grid_view_rounded,
          label: types.map((t) => t.label(l10n)).join(' / '),
        ),
      );
    }

    if (stadium.amenities.isNotEmpty) {
      tiles.add(
        _SummaryTile(
          icon: Icons.apartment_rounded,
          label: l10n.stadiumDetailFacilityCount(stadium.amenities.length),
        ),
      );
    }

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: l10n.stadiumDetailSummarySemantic,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: tiles,
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.brandDeep),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.42,
            ),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableTextSection extends StatefulWidget {
  const ExpandableTextSection({
    super.key,
    required this.title,
    required this.body,
    required this.showMoreLabel,
    required this.showLessLabel,
    this.collapsedLines = 4,
  });

  final String title;
  final String body;
  final String showMoreLabel;
  final String showLessLabel;
  final int collapsedLines;

  @override
  State<ExpandableTextSection> createState() => _ExpandableTextSectionState();
}

class _ExpandableTextSectionState extends State<ExpandableTextSection> {
  var _expanded = false;
  var _needsToggle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final painter = TextPainter(
      text: TextSpan(
        text: widget.body,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      maxLines: widget.collapsedLines,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: MediaQuery.sizeOf(context).width - AppSpacing.md * 2);
    final needs = painter.didExceedMaxLines;
    if (needs != _needsToggle && mounted) {
      setState(() => _needsToggle = needs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (_needsToggle)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandDeep,
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? widget.showLessLabel : widget.showMoreLabel,
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.body,
          maxLines: _expanded || !_needsToggle ? null : widget.collapsedLines,
          overflow:
              _expanded || !_needsToggle
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class StadiumPitchesSection extends StatelessWidget {
  const StadiumPitchesSection({
    super.key,
    required this.pitches,
    required this.onPitchTap,
  });

  final List<StadiumPitchSummary> pitches;
  final ValueChanged<String> onPitchTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.stadiumDetailPitches,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (pitches.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(
              l10n.stadiumDetailNoPitches,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
            ),
          )
        else
          ...pitches.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StadiumPitchCard(pitch: p, onTap: () => onPitchTap(p.id)),
            ),
          ),
      ],
    );
  }
}

class StadiumPitchCard extends StatelessWidget {
  const StadiumPitchCard({super.key, required this.pitch, required this.onTap});

  final StadiumPitchSummary pitch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dim = _dimensionsLabel(pitch);
    final meta = <String>[
      pitch.type.label(l10n),
      if (dim != null) dim,
      pitch.surfaceType.label(l10n),
      if (pitch.isIndoor) l10n.stadiumDetailIndoor,
      if (pitch.hasRoof && !pitch.isIndoor) l10n.stadiumDetailRoofed,
    ];

    return Material(
      color: AppColors.surface,
      elevation: 0.5,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Semantics(
          button: true,
          label: '${pitch.name}, ${pitch.type.label(l10n)}',
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const StadiumPhoto(compactFallback: true),
                        PositionedDirectional(
                          start: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandDeep.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pitch.type.label(l10n),
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pitch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final rtl = Directionality.of(context) == TextDirection.rtl;
                    return Icon(
                      rtl
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.brandDeep.withValues(alpha: 0.7),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _dimensionsLabel(StadiumPitchSummary pitch) {
    final w = pitch.widthMeters;
    final l = pitch.lengthMeters;
    if (w == null || l == null) return null;
    final wStr = w == w.roundToDouble() ? w.toInt().toString() : w.toString();
    final lStr = l == l.roundToDouble() ? l.toInt().toString() : l.toString();
    return '$wStr × $lStr m';
  }
}

class StadiumFacilitiesSection extends StatelessWidget {
  const StadiumFacilitiesSection({super.key, required this.amenities});

  final List<StadiumAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.stadiumDetailFacilities,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < amenities.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                _FacilityTile(
                  icon: amenities[i].icon,
                  label: amenities[i].label(l10n),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FacilityTile extends StatelessWidget {
  const _FacilityTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandDeep, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.1,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StadiumLocationSection extends StatelessWidget {
  const StadiumLocationSection({
    super.key,
    required this.stadium,
    this.onDirections,
    this.onCall,
  });

  final StadiumDetail stadium;
  final VoidCallback? onDirections;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cityState =
        '${stadium.city.label(l10n)} · ${stadium.state.label(l10n)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.stadiumDetailLocation,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (stadium.hasCoordinates)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              height: 140,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _SoftMapPainter()),
                  ),
                  const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: AppColors.brandDeep,
                    ),
                  ),
                  PositionedDirectional(
                    start: AppSpacing.sm,
                    end: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: _AddressCard(
                      name: stadium.name,
                      address: stadium.address,
                      cityState: cityState,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _AddressCard(
            name: stadium.name,
            address: stadium.address,
            cityState: cityState,
          ),
        if (onDirections != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: onDirections,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandDeep,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            icon: const Icon(Icons.near_me_rounded, size: 18),
            label: Text(l10n.stadiumDetailGetDirections),
          ),
        ],
        if (onCall != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: Text(l10n.stadiumDetailCallStadium),
            style: TextButton.styleFrom(foregroundColor: AppColors.brandDeep),
          ),
        ],
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.name,
    required this.address,
    required this.cityState,
  });

  final String name;
  final String address;
  final String cityState;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
            Text(
              cityState,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftMapPainter extends CustomPainter {
  const _SoftMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primarySoft.withValues(alpha: 0.55)
          ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final wash =
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.primarySoft.withValues(alpha: 0.35),
              AppColors.surfaceMuted,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StadiumDetailSkeleton extends StatelessWidget {
  const StadiumDetailSkeleton({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final totalHero = StadiumDetailHero.totalHeightFor(context);
    final sheetTop = StadiumDetailHero.layoutHeightFor(context);

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: totalHero,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.imageFallback),
              PositionedDirectional(
                top: topInset + AppSpacing.xs,
                start: AppSpacing.sm,
                child: _HeroCircleButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBack,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: sheetTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: StadiumDetailContentSheet(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _SkeletonPulse(
                animate: !reduceMotion,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _skelBox(width: 100, height: 36),
                          const SizedBox(width: 8),
                          _skelBox(width: 120, height: 36),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _skelBox(width: 80, height: 18),
                      const SizedBox(height: 8),
                      _skelBox(width: double.infinity, height: 12),
                      const SizedBox(height: 6),
                      _skelBox(width: double.infinity, height: 12),
                      const SizedBox(height: 6),
                      _skelBox(width: 200, height: 12),
                      const SizedBox(height: AppSpacing.lg),
                      _skelBox(width: 90, height: 18),
                      const SizedBox(height: 10),
                      _skelBox(width: double.infinity, height: 84),
                      const SizedBox(height: 10),
                      _skelBox(width: double.infinity, height: 84),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _skelBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SkeletonPulse extends StatefulWidget {
  const _SkeletonPulse({required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
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
    if (!widget.animate || _controller == null) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return Opacity(
          opacity: 0.55 + (_controller!.value * 0.35),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

extension StadiumAmenityUi on StadiumAmenity {
  IconData get icon {
    switch (this) {
      case StadiumAmenity.parking:
        return Icons.local_parking_rounded;
      case StadiumAmenity.changingRooms:
        return Icons.checkroom_rounded;
      case StadiumAmenity.toilets:
        return Icons.wc_rounded;
      case StadiumAmenity.seating:
        return Icons.event_seat_rounded;
      case StadiumAmenity.cafe:
        return Icons.local_cafe_outlined;
      case StadiumAmenity.prayerArea:
        return Icons.mosque_outlined;
      case StadiumAmenity.water:
        return Icons.water_drop_outlined;
      case StadiumAmenity.firstAid:
        return Icons.medical_services_outlined;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case StadiumAmenity.parking:
        return l10n.amenityParking;
      case StadiumAmenity.changingRooms:
        return l10n.amenityChangingRooms;
      case StadiumAmenity.toilets:
        return l10n.amenityToilets;
      case StadiumAmenity.seating:
        return l10n.amenitySeating;
      case StadiumAmenity.cafe:
        return l10n.amenityCafe;
      case StadiumAmenity.prayerArea:
        return l10n.amenityPrayerArea;
      case StadiumAmenity.water:
        return l10n.amenityWater;
      case StadiumAmenity.firstAid:
        return l10n.amenityFirstAid;
    }
  }
}

extension SurfaceTypeL10n on SurfaceType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SurfaceType.naturalGrass:
        return l10n.surfaceNaturalGrass;
      case SurfaceType.artificialTurf:
        return l10n.surfaceArtificialTurf;
      case SurfaceType.futsal:
        return l10n.surfaceFutsal;
      case SurfaceType.other:
        return l10n.surfaceOther;
    }
  }
}
