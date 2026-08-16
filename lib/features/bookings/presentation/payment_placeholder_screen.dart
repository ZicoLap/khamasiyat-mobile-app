import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_controller.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

/// Payment handoff placeholder. Receives a real booking ID; no payment UX yet.
class PaymentPlaceholderScreen extends ConsumerWidget {
  const PaymentPlaceholderScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final session = ref.watch(pendingBookingSessionProvider);
    final booking =
        session?.booking.id == bookingId ? session!.booking : null;
    final review =
        session?.booking.id == bookingId ? session!.review : null;

    final dateLabel =
        booking == null
            ? '—'
            : DateFormat.yMMMEd(localeCode).format(
              StadiumTime.parseIsoDate(booking.date),
            );
    final timeRange =
        booking == null
            ? '—'
            : '${booking.startTime} → ${booking.endTime}';
    final amount =
        booking == null
            ? '—'
            : SdgFormatter.format(booking.priceSdg, locale: localeCode);
    final holdLabel =
        booking?.holdsUntil == null
            ? null
            : DateFormat.yMMMd(localeCode)
                .add_Hm()
                .format(booking!.holdsUntil!.toLocal());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(l10n.paymentPlaceholderTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.paymentPlaceholderBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Line(text: l10n.paymentBookingIdLabel(bookingId)),
          if (booking != null)
            _Line(text: l10n.paymentStatusPendingLabel(booking.status)),
          if (review != null) ...[
            _Line(text: review.stadiumName),
            _Line(text: review.pitchName),
          ],
          _Line(text: dateLabel),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _Line(text: timeRange),
            ),
          ),
          _Line(text: amount),
          if (holdLabel != null)
            _Line(text: l10n.paymentHoldsUntilLabel(holdLabel)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
