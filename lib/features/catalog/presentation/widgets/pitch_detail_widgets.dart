import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/slot_duration.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

class PitchDetailHero extends StatefulWidget {
  const PitchDetailHero({
    super.key,
    required this.photos,
    required this.pitchName,
    required this.onBack,
    required this.onShare,
    this.contentOverlap = StadiumDetailLayout.contentOverlap,
  });

  final List<PitchPhotoItem> photos;
  final String pitchName;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final double contentOverlap;

  static double heightFor(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    if (h < 700) return 260;
    return 310;
  }

  static double totalHeightFor(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return heightFor(context) + topInset * 0.35;
  }

  static double layoutHeightFor(BuildContext context) {
    return totalHeightFor(context) - StadiumDetailLayout.contentOverlap;
  }

  @override
  State<PitchDetailHero> createState() => _PitchDetailHeroState();
}

class _PitchDetailHeroState extends State<PitchDetailHero> {
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
    final heroHeight = PitchDetailHero.totalHeightFor(context);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          multi
              ? PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return Semantics(
                    label: l10n.pitchDetailPhotoSemantic(
                      widget.pitchName,
                      i + 1,
                      photos.length,
                    ),
                    image: true,
                    child: StadiumPhoto(url: photos[i].url),
                  );
                },
              )
              : Semantics(
                label: l10n.pitchDetailPhotoSemantic(widget.pitchName, 1, 1),
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
                  Color(0x33081612),
                  Color(0x00081612),
                  Color(0x66081612),
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
          PositionedDirectional(
            top: topInset + AppSpacing.xs,
            end: AppSpacing.sm,
            child: _HeroCircleButton(
              icon: Icons.share_rounded,
              tooltip: l10n.pitchDetailShareTooltip,
              onPressed: widget.onShare,
            ),
          ),
          if (multi)
            PositionedDirectional(
              bottom: widget.contentOverlap + AppSpacing.md,
              end: AppSpacing.md,
              child: Text(
                l10n.stadiumDetailPhotoCount(_index + 1, photos.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                ),
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

class PitchSummaryBlock extends StatelessWidget {
  const PitchSummaryBlock({
    super.key,
    required this.pitch,
    this.fromPriceSdg,
    required this.localeCode,
  });

  final PitchDetail pitch;
  final int? fromPriceSdg;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dim = _dimensionsLabel(pitch);
    final chips = <_FactChip>[
      _FactChip(icon: Icons.grid_view_rounded, label: pitch.type.label(l10n)),
      if (dim != null) _FactChip(icon: Icons.straighten_rounded, label: dim),
      _FactChip(
        icon: Icons.grass_rounded,
        label: pitch.surfaceType.label(l10n),
      ),
      _FactChip(
        icon: pitch.isIndoor ? Icons.home_outlined : Icons.wb_sunny_outlined,
        label:
            pitch.isIndoor ? l10n.stadiumDetailIndoor : l10n.pitchDetailOutdoor,
      ),
      if (pitch.hasRoof && !pitch.isIndoor)
        _FactChip(icon: Icons.roofing_rounded, label: l10n.stadiumDetailRoofed),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pitch.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pitch.stadium.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: chips,
        ),
        if (fromPriceSdg != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.pitchDetailFromPrice(
              SdgFormatter.format(fromPriceSdg!, locale: localeCode),
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.brandDeep,
            ),
          ),
        ],
      ],
    );
  }

  static String? _dimensionsLabel(PitchDetail pitch) {
    final w = pitch.widthMeters;
    final l = pitch.lengthMeters;
    if (w == null || l == null) return null;
    final wStr = w == w.roundToDouble() ? w.toInt().toString() : w.toString();
    final lStr = l == l.roundToDouble() ? l.toInt().toString() : l.toString();
    return '$wStr × $lStr m';
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

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
          Icon(icon, size: 16, color: AppColors.brandDeep),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PitchDateStrip extends StatelessWidget {
  const PitchDateStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.localeCode,
    required this.onSelect,
    required this.onCalendar,
  });

  final List<String> dates;
  final String selectedDate;
  final String localeCode;
  final ValueChanged<String> onSelect;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.pitchDetailSelectDate,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: l10n.pitchDetailCalendarTooltip,
              onPressed: onCalendar,
              icon: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.brandDeep,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final date = dates[i];
              final selected = date == selectedDate;
              final civil = StadiumTime.parseIsoDate(date);
              final weekday = DateFormat('E', localeCode).format(civil);
              final day = DateFormat('d', localeCode).format(civil);
              return Material(
                color: selected ? AppColors.brandDeep : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  side: BorderSide(
                    color:
                        selected
                            ? AppColors.brandDeep
                            : AppColors.outlineSubtle,
                  ),
                ),
                child: InkWell(
                  onTap: () => onSelect(date),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: SizedBox(
                    width: 58,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekday,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color:
                                selected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                selected ? Colors.white : AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PitchSlotsSection extends StatelessWidget {
  const PitchSlotsSection({
    super.key,
    required this.slots,
    required this.selectedId,
    required this.localeCode,
    required this.onSelect,
    required this.onChooseDate,
    required this.onRefresh,
  });

  final List<AvailabilitySlot> slots;
  final String? selectedId;
  final String localeCode;
  final ValueChanged<AvailabilitySlot> onSelect;
  final VoidCallback onChooseDate;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pitchDetailAvailableTimes,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (slots.isEmpty)
          PitchSlotsEmpty(onChooseDate: onChooseDate, onRefresh: onRefresh)
        else
          ..._groups(context),
      ],
    );
  }

  List<Widget> _groups(BuildContext context) {
    final l10n = context.l10n;
    final groups = <SlotPeriod, List<AvailabilitySlot>>{};
    for (final slot in slots) {
      groups.putIfAbsent(slot.period, () => []).add(slot);
    }

    return [
      for (final period in SlotPeriod.values)
        if (groups[period]?.isNotEmpty ?? false) ...[
          Text(
            _periodLabel(l10n, period),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in groups[period]!)
                _SlotChip(
                  slot: slot,
                  selected: slot.id == selectedId,
                  localeCode: localeCode,
                  onTap: () => onSelect(slot),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
    ];
  }

  static String _periodLabel(AppLocalizations l10n, SlotPeriod period) {
    switch (period) {
      case SlotPeriod.morning:
        return l10n.pitchDetailMorning;
      case SlotPeriod.afternoon:
        return l10n.pitchDetailAfternoon;
      case SlotPeriod.evening:
        return l10n.pitchDetailEvening;
    }
  }
}

class PitchSlotsEmpty extends StatelessWidget {
  const PitchSlotsEmpty({
    super.key,
    required this.onChooseDate,
    required this.onRefresh,
  });

  final VoidCallback onChooseDate;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pitchDetailNoSlots,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            TextButton(
              onPressed: onChooseDate,
              child: Text(l10n.pitchDetailChooseAnotherDate),
            ),
            TextButton(onPressed: onRefresh, child: Text(l10n.retryAction)),
          ],
        ),
      ],
    );
  }
}

class PitchAvailabilityRefreshBanner extends StatelessWidget {
  const PitchAvailabilityRefreshBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.pitchDetailRefreshFailed,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.localeCode,
    required this.onTap,
  });

  final AvailabilitySlot slot;
  final bool selected;
  final String localeCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = slot.isAvailable;
    final bg =
        selected
            ? AppColors.brandDeep
            : enabled
            ? AppColors.primarySoft
            : AppColors.surfaceMuted;
    final fg = selected ? AppColors.onPrimary : AppColors.brandDeep;
    final muted =
        selected
            ? AppColors.onPrimary.withValues(alpha: 0.85)
            : AppColors.onSurfaceMuted;
    final border =
        selected
            ? AppColors.brandDeep
            : enabled
            ? AppColors.primary.withValues(alpha: 0.35)
            : AppColors.outlineSubtle;
    final duration = SlotDuration.label(slot.durationMinutes, l10n);
    final price = SdgFormatter.format(slot.priceSdg, locale: localeCode);
    final range = '${slot.startTime} → ${slot.endTime}';

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Semantics(
            button: true,
            selected: selected,
            enabled: enabled,
            label: l10n.pitchDetailSlotSemantic(slot.startTime, slot.endTime),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      range,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            enabled || selected ? fg : AppColors.onSurfaceMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$duration · $price',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  Text(
                    l10n.pitchDetailSlotAvailable,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PitchTimezoneNote extends StatelessWidget {
  const PitchTimezoneNote({super.key, required this.timeZone});

  final String timeZone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 16,
          color: AppColors.onSurfaceMuted.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.pitchDetailTimezoneNote(timeZone),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
          ),
        ),
      ],
    );
  }
}

class PitchBookingBar extends StatelessWidget {
  const PitchBookingBar({
    super.key,
    required this.slot,
    required this.localeCode,
    required this.busy,
    required this.onContinue,
  });

  final AvailabilitySlot slot;
  final String localeCode;
  final bool busy;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final civil = StadiumTime.parseIsoDate(slot.date);
    final dateLabel = DateFormat.MMMd(localeCode).format(civil);
    final price = SdgFormatter.format(slot.priceSdg, locale: localeCode);
    final duration = SlotDuration.label(slot.durationMinutes, l10n);
    final range = '${slot.startTime} → ${slot.endTime}';

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        range,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateLabel · $duration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.brandDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: busy ? null : onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(120, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child:
                    busy
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(l10n.pitchDetailContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PitchDetailSkeleton extends StatelessWidget {
  const PitchDetailSkeleton({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final totalHero = PitchDetailHero.totalHeightFor(context);
    final sheetTop = PitchDetailHero.layoutHeightFor(context);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          height: totalHero,
          width: double.infinity,
          child: ColoredBox(
            color: AppColors.imageFallback,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  top: topInset + AppSpacing.xs,
                  start: AppSpacing.sm,
                ),
                child: _HeroCircleButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBack,
                ),
              ),
            ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 180,
                    height: 22,
                    color: AppColors.surfaceMuted,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 14,
                    color: AppColors.surfaceMuted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    height: 72,
                    color: AppColors.surfaceMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PitchDetailErrorBody extends StatelessWidget {
  const PitchDetailErrorBody({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.pitchDetailErrorTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandDeep,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      child: Text(l10n.retryAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
