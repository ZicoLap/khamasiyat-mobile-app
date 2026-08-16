import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/slot_duration.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

(Color, Color) bookingDetailStatusColors(MyBookingFace face) {
  switch (face) {
    case MyBookingFace.paymentRequired:
    case MyBookingFace.paymentRejected:
      return (const Color(0xFFF6EBD4), const Color(0xFF6B4F12));
    case MyBookingFace.waitingConfirmation:
      return (const Color(0xFFE4EEF6), const Color(0xFF2C4A63));
    case MyBookingFace.confirmed:
      return (AppColors.primarySoft, AppColors.onPrimarySoft);
    case MyBookingFace.cancelled:
      return (const Color(0xFFF0E4E2), const Color(0xFF6B3A36));
    case MyBookingFace.completed:
    case MyBookingFace.expired:
      return (AppColors.surfaceMuted, AppColors.onSurfaceMuted);
  }
}

String bookingDetailStatusLabel(AppLocalizations l10n, MyBookingFace face) {
  switch (face) {
    case MyBookingFace.paymentRequired:
      return l10n.myBookingsStatusPaymentRequired;
    case MyBookingFace.waitingConfirmation:
      return l10n.myBookingsStatusWaiting;
    case MyBookingFace.paymentRejected:
      return l10n.myBookingsStatusRejected;
    case MyBookingFace.confirmed:
      return l10n.myBookingsStatusConfirmed;
    case MyBookingFace.cancelled:
      return l10n.myBookingsStatusCancelled;
    case MyBookingFace.completed:
      return l10n.myBookingsStatusCompleted;
    case MyBookingFace.expired:
      return l10n.myBookingsStatusExpired;
  }
}

String? bookingDetailPaymentActionLabel(
  AppLocalizations l10n,
  MyBookingAction action,
) {
  switch (action) {
    case MyBookingAction.completePayment:
      return l10n.myBookingsCompletePayment;
    case MyBookingAction.retryPayment:
      return l10n.myBookingsRetryPayment;
    case MyBookingAction.viewPayment:
      return l10n.myBookingsViewPayment;
    case MyBookingAction.viewBooking:
    case MyBookingAction.none:
      return null;
  }
}

class BookingDetailHero extends StatelessWidget {
  const BookingDetailHero({
    super.key,
    required this.state,
    required this.face,
    required this.onBack,
    this.contentOverlap = StadiumDetailLayout.contentOverlap,
  });

  final BookingDetailState state;
  final MyBookingFace face;
  final VoidCallback onBack;
  final double contentOverlap;

  static double heightFor(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    if (h < 700) return 280;
    return 320;
  }

  static double totalHeightFor(BuildContext context) {
    return heightFor(context) + MediaQuery.paddingOf(context).top;
  }

  static double layoutHeightFor(BuildContext context, {double? overlap}) {
    final o = overlap ?? StadiumDetailLayout.contentOverlap;
    return totalHeightFor(context) - o;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final booking = state.booking!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat.yMMMEd(
      localeCode,
    ).format(StadiumTime.parseIsoDate(booking.date));
    final timeRange = '${booking.startTime} → ${booking.endTime}';
    final location = _locationLine(context, state);
    final statusLabel = bookingDetailStatusLabel(l10n, face);
    final colors = bookingDetailStatusColors(face);
    final confirmed = face == MyBookingFace.confirmed;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = totalHeightFor(context);
    final titleBottom = contentOverlap + AppSpacing.md;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          StadiumPhoto(url: state.heroPhotoUrl),
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
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          PositionedDirectional(
            top: topInset + AppSpacing.xs,
            start: AppSpacing.sm,
            child: _HeroCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
            ),
          ),
          PositionedDirectional(
            top: topInset + AppSpacing.sm,
            end: AppSpacing.md,
            child: BookingStatusBadge(
              label: statusLabel,
              background: colors.$1,
              foreground: colors.$2,
              icon: confirmed ? Icons.check_rounded : null,
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
                  booking.stadiumName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.heroOnBrand,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.pitchName} · ${booking.pitchType.label(l10n)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.heroOnBrandSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.heroOnBrandMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.heroOnBrandSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      timeRange,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppColors.heroOnBrand,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _locationLine(BuildContext context, BookingDetailState state) {
    final l10n = context.l10n;
    final stadium = state.stadium;
    if (stadium != null) {
      return '${stadium.city.label(l10n)} · ${stadium.state.label(l10n)}';
    }
    final pitchStadium = state.pitch?.stadium;
    if (pitchStadium != null) {
      return '${pitchStadium.city.label(l10n)} · ${pitchStadium.state.label(l10n)}';
    }
    return null;
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
      elevation: 0,
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

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingFactChips extends StatelessWidget {
  const BookingFactChips({super.key, required this.state});

  final BookingDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final booking = state.booking!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final duration = SlotDuration.label(
      SlotDuration.minutesBetween(booking.startTime, booking.endTime),
      l10n,
    );
    final price = SdgFormatter.format(booking.priceSdg, locale: localeCode);
    final dimensions = _dimensionsLabel(state);
    final surface = state.pitch?.surfaceType.label(l10n);
    final chips = <String>[
      duration,
      price,
      if (surface != null) surface,
      if (dimensions != null) dimensions,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [for (final chip in chips) _FactChip(label: chip)],
        ),
        if (booking.isCompleted && booking.checkedInAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.bookingDetailCheckedIn} · ${DateFormat.yMMMd(localeCode).add_Hm().format(booking.checkedInAt!.toLocal())}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
          ),
        ],
        if (booking.isCancelled &&
            booking.cancellationReason != null &&
            booking.cancellationReason!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            booking.cancellationReason!.trim(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
          ),
        ],
      ],
    );
  }

  static String? _dimensionsLabel(BookingDetailState state) {
    final pitch = state.pitch;
    if (pitch == null) return null;
    final w = pitch.widthMeters;
    final l = pitch.lengthMeters;
    if (w == null || l == null) return null;
    final wStr = w == w.roundToDouble() ? w.toInt().toString() : w.toString();
    final lStr = l == l.roundToDouble() ? l.toInt().toString() : l.toString();
    return '$wStr × $lStr m';
  }
}

class BookingPaymentBanner extends StatelessWidget {
  const BookingPaymentBanner({
    super.key,
    required this.booking,
    required this.face,
  });

  final CustomerBooking booking;
  final MyBookingFace face;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = booking.paymentSummary;
    final remaining =
        myBookingShowsHoldCountdown(booking)
            ? myBookingRemainingHold(booking)
            : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (face == MyBookingFace.waitingConfirmation)
              Text(
                l10n.bookingDetailWaitingBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                  height: 1.35,
                ),
              ),
            if (face == MyBookingFace.paymentRejected)
              Text(
                summary?.rejectionReason?.trim().isNotEmpty == true
                    ? summary!.rejectionReason!.trim()
                    : l10n.myBookingsRejectedHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                  height: 1.35,
                ),
              ),
            if (remaining != null) ...[
              if (face == MyBookingFace.waitingConfirmation ||
                  face == MyBookingFace.paymentRejected)
                const SizedBox(height: AppSpacing.sm),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.paymentHoldRemaining(formatHoldCountdown(remaining)),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandDeep,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BookingPinCard extends StatelessWidget {
  const BookingPinCard({
    super.key,
    required this.state,
    required this.onShow,
    required this.onHide,
    required this.onRetry,
    required this.onCopy,
  });

  final BookingDetailState state;
  final VoidCallback onShow;
  final VoidCallback onHide;
  final VoidCallback onRetry;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final revealed = state.pinVisible && state.pin != null;
    final pin = state.pin;

    return DecoratedBox(
      key: const ValueKey('booking-detail-pin-card'),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Text(
              l10n.bookingDetailEntryPin,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.brandDeep,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (state.pinError != null && !revealed) ...[
              KeyedSubtree(
                key: const ValueKey('booking-detail-pin-error'),
                child: Column(
                  children: [
                    Text(
                      l10n.bookingDetailPinLoadFailed,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: state.pinLoading ? null : onRetry,
                      child: Text(l10n.myBookingsTryAgain),
                    ),
                  ],
                ),
              ),
            ] else ...[
              BookingPinDigits(pin: revealed ? pin : null),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.bookingDetailPinHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.pinLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child:
                          revealed
                              ? OutlinedButton(
                                onPressed: onHide,
                                child: Text(l10n.bookingDetailHidePin),
                              )
                              : FilledButton(
                                onPressed: onShow,
                                child: Text(l10n.bookingDetailShowPin),
                              ),
                    ),
                    if (revealed) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: onCopy,
                          child: Text(l10n.bookingDetailCopyPin),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class BookingPinDigits extends StatelessWidget {
  const BookingPinDigits({super.key, this.pin});

  final String? pin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final revealed = pin != null && pin!.isNotEmpty;
    final glyphs = revealed ? pin!.split('') : List.filled(6, '•');
    return Semantics(
      key: ValueKey(
        revealed ? 'booking-detail-pin-revealed' : 'booking-detail-pin-hidden',
      ),
      label:
          revealed
              ? '${l10n.bookingDetailEntryPin} ${glyphs.join(' ')}'
              : l10n.bookingDetailPinHiddenSemantic,
      child: ExcludeSemantics(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              for (var i = 0; i < glyphs.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            revealed
                                ? AppColors.brandDeep
                                : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            glyphs[i],
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  revealed
                                      ? AppColors.heroOnBrand
                                      : AppColors.onSurfaceMuted,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BookingLocationActions extends StatelessWidget {
  const BookingLocationActions({
    super.key,
    required this.state,
    this.onDirections,
    this.onContact,
  });

  final BookingDetailState state;
  final VoidCallback? onDirections;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stadium = state.stadium;
    if (stadium == null) return const SizedBox.shrink();
    final address = stadium.address.trim();
    if (address.isEmpty && onDirections == null && onContact == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.isNotEmpty)
          Text(
            address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
              height: 1.35,
            ),
          ),
        if (onDirections != null || onContact != null)
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              if (onDirections != null)
                TextButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: Text(l10n.stadiumDetailGetDirections),
                ),
              if (onContact != null)
                TextButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: Text(l10n.bookingDetailContactStadium),
                ),
            ],
          ),
      ],
    );
  }
}

class BookingDetailSkeleton extends StatelessWidget {
  const BookingDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('booking-detail-skeleton'),
      label: 'Loading',
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _SkelBox(height: 280, radius: 0),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  _SkelBox(height: 40, radius: AppRadii.pill),
                  SizedBox(height: AppSpacing.sm),
                  _SkelBox(height: 180, radius: AppRadii.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailErrorBody extends StatelessWidget {
  const BookingDetailErrorBody({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      key: const ValueKey('booking-detail-error'),
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.bookingDetailLoadFailed,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onRetry,
            child: Text(l10n.myBookingsTryAgain),
          ),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _SkelBox extends StatelessWidget {
  const _SkelBox({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
    );
  }
}

Future<void> copyBookingPin(BuildContext context, String pin) async {
  await Clipboard.setData(ClipboardData(text: pin));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.bookingDetailPinCopied)));
}
