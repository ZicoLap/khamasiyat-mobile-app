import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/slot_duration.dart';
import 'package:khamasiyat_mobile_app/features/bookings/data/bookings_repository.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_attempt_keys.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_models.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/pending_booking_session.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_photo.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

const _bookingNotAvailable = 'BOOKING_NOT_AVAILABLE';

/// Result returned to Pitch Detail when leaving Booking Summary.
enum BookingReviewPopResult {
  /// Cancel / system back — selection may be preserved.
  cancelled,

  /// 409 BOOKING_NOT_AVAILABLE — clear selection and refetch.
  slotUnavailable,
}

class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key, this.bookingAttemptKeys});

  final BookingAttemptKeys? bookingAttemptKeys;

  @override
  ConsumerState<BookingReviewScreen> createState() =>
      _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  late final BookingAttemptKeys _attemptKeys;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _attemptKeys = widget.bookingAttemptKeys ?? BookingAttemptKeys();
  }

  void _pop(BookingReviewPopResult result) {
    if (GoRouter.maybeOf(context) != null) {
      context.pop(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _cancel() async {
    if (_busy) return;
    _pop(BookingReviewPopResult.cancelled);
  }

  Future<void> _bookSlot(BookingReviewDraft draft) async {
    if (_busy) return;
    setState(() => _busy = true);
    final key = _attemptKeys.keyFor(draft.slotOccurrenceId);
    try {
      final booking = await ref
          .read(bookingsRepositoryProvider)
          .createBooking(
            slotOccurrenceId: draft.slotOccurrenceId,
            idempotencyKey: key,
          );
      if (!mounted) return;
      setState(() => _busy = false);
      await _showReservedSheet(booking, draft);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (error.code == _bookingNotAvailable) {
        await _showConflictDialog();
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  Future<void> _showConflictDialog() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(l10n.bookingConflictTitle),
          content: Text(l10n.bookingConflictBody),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _pop(BookingReviewPopResult.slotUnavailable);
              },
              child: Text(l10n.bookingConflictChooseAnother),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReservedSheet(
    CreatedBooking booking,
    BookingReviewDraft draft,
  ) async {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final holdLabel = _formatHoldsUntil(booking.holdsUntil, localeCode);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Icon(
                  Icons.schedule_rounded,
                  size: 40,
                  color: AppColors.brandDeep,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.bookingReservedTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandDeep,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.bookingReservedBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                if (holdLabel != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.bookingReservedHoldUntil(holdLabel),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _goToPayment(booking, draft);
                  },
                  child: Text(l10n.bookingReservedContinuePayment),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToPayment(CreatedBooking booking, BookingReviewDraft draft) {
    ref
        .read(pendingBookingSessionProvider.notifier)
        .state = PendingBookingSession(booking: booking, review: draft);

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push(AppRoutes.bookingPayment(booking.id));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(bookingId: booking.id),
      ),
    );
  }

  static String? _formatHoldsUntil(DateTime? holdsUntil, String localeCode) {
    if (holdsUntil == null) return null;
    final local = holdsUntil.toLocal();
    return DateFormat.yMMMd(localeCode).add_Hm().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingReviewDraftProvider);
    final auth = ref.watch(authControllerProvider);
    final customer = auth is AuthAuthenticated ? auth.user : null;
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;

    if (draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pop(BookingReviewPopResult.cancelled);
      });
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final civil = StadiumTime.parseIsoDate(draft.date);
    final dateLabel = DateFormat.yMMMEd(localeCode).format(civil);
    final duration = SlotDuration.label(
      SlotDuration.minutesBetween(draft.startTime, draft.endTime),
      l10n,
    );
    final price = SdgFormatter.format(draft.priceSdg, locale: localeCode);
    final location =
        '${draft.stadiumCity.label(l10n)} · ${draft.stadiumState.label(l10n)}';
    final timeRange = '${draft.startTime} → ${draft.endTime}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: _busy ? null : _cancel,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          l10n.bookingReviewTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: _BookingReviewBar(
        totalLabel: l10n.bookingReviewTotalLabel,
        price: price,
        bookLabel: l10n.bookingReviewBookSlot,
        busy: _busy,
        onBook: () => _bookSlot(draft),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          _VenueHeroCard(
            photoUrl: draft.photoUrl,
            stadiumName: draft.stadiumName,
            location: location,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (customer != null) ...[
            _CustomerCard(
              l10n: l10n,
              name: customer.name,
              phone: customer.phone,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _YourBookingCard(
            l10n: l10n,
            pitchName: draft.pitchName,
            pitchType: draft.pitchType.label(l10n),
            dateLabel: dateLabel,
            timeRange: timeRange,
            duration: duration,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PriceDetailsCard(l10n: l10n, price: price),
          const SizedBox(height: AppSpacing.sm),
          _NotReservedYetBanner(message: l10n.bookingReviewNotReservedYet),
        ],
      ),
    );
  }
}

class _VenueHeroCard extends StatelessWidget {
  const _VenueHeroCard({
    required this.photoUrl,
    required this.stadiumName,
    required this.location,
  });

  final String? photoUrl;
  final String stadiumName;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                StadiumPhoto(url: photoUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.imageScrim],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: AppSpacing.md,
                  end: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stadiumName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.heroOnBrand,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.heroOnBrandSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.l10n,
    required this.name,
    required this.phone,
  });

  final AppLocalizations l10n;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bookingReviewCustomer,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.brandDeep,
              ),
            ),
            const SizedBox(height: 4),
            _DetailLine(
              icon: Icons.person_outline_rounded,
              label: l10n.bookingReviewNameLabel,
              value: name,
            ),
            const Divider(height: 1, color: AppColors.outlineSubtle),
            _DetailLine(
              icon: Icons.phone_outlined,
              label: l10n.phoneLabel,
              value: phone,
              ltrValue: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _YourBookingCard extends StatelessWidget {
  const _YourBookingCard({
    required this.l10n,
    required this.pitchName,
    required this.pitchType,
    required this.dateLabel,
    required this.timeRange,
    required this.duration,
  });

  final AppLocalizations l10n;
  final String pitchName;
  final String pitchType;
  final String dateLabel;
  final String timeRange;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bookingReviewYourBooking,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.brandDeep,
              ),
            ),
            const SizedBox(height: 4),
            _DetailLine(
              icon: Icons.sports_soccer_rounded,
              label: l10n.bookingReviewPitchLabel,
              value: pitchName,
            ),
            const Divider(height: 1, color: AppColors.outlineSubtle),
            _DetailLine(
              icon: Icons.grid_view_rounded,
              label: l10n.bookingReviewTypeLabel,
              value: pitchType,
            ),
            const Divider(height: 1, color: AppColors.outlineSubtle),
            _DetailLine(
              icon: Icons.calendar_today_rounded,
              label: l10n.bookingReviewDateLabel,
              value: dateLabel,
            ),
            const Divider(height: 1, color: AppColors.outlineSubtle),
            _DetailLine(
              icon: Icons.schedule_rounded,
              label: l10n.bookingReviewTimeLabel,
              value: timeRange,
              ltrValue: true,
            ),
            const Divider(height: 1, color: AppColors.outlineSubtle),
            _DetailLine(
              icon: Icons.timelapse_rounded,
              label: l10n.bookingReviewDurationLabel,
              value: duration,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
    this.ltrValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ltrValue;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brandDeep),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child:
                ltrValue
                    ? Directionality(
                      textDirection: TextDirection.ltr,
                      child: valueText,
                    )
                    : valueText,
          ),
        ],
      ),
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  const _PriceDetailsCard({required this.l10n, required this.price});

  final AppLocalizations l10n;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bookingReviewPriceDetails,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.brandDeep,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.bookingReviewPitchReservation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: AppColors.outline),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.bookingReviewTotalLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotReservedYetBanner extends StatelessWidget {
  const _NotReservedYetBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.onPrimarySoft,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimarySoft,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingReviewBar extends StatelessWidget {
  const _BookingReviewBar({
    required this.totalLabel,
    required this.price,
    required this.bookLabel,
    required this.busy,
    required this.onBook,
  });

  final String totalLabel;
  final String price;
  final String bookLabel;
  final bool busy;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 12,
      shadowColor: Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
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
                    Text(
                      totalLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandDeep,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: busy ? null : onBook,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(168, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                child:
                    busy
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(bookLabel),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
