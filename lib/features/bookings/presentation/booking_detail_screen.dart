import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/widgets/booking_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/shared/platform/external_actions.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    this.externalActions = const ExternalActions(),
  });

  final String bookingId;
  final ExternalActions externalActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailControllerProvider(bookingId));
    final controller = ref.read(
      bookingDetailControllerProvider(bookingId).notifier,
    );
    final loaded =
        state.status != BookingDetailStatus.loading &&
        state.status != BookingDetailStatus.initial &&
        state.status != BookingDetailStatus.failure &&
        state.booking != null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBodyBehindAppBar: loaded,
      appBar:
          loaded
              ? null
              : AppBar(
                backgroundColor: AppColors.canvas,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => _goBack(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
      bottomNavigationBar: _PaymentActionBar(
        state: state,
        onPayment: () => _openPayment(context),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: _body(context, state, controller),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.bookings);
    }
  }

  Widget _body(
    BuildContext context,
    BookingDetailState state,
    BookingDetailController controller,
  ) {
    if (state.status == BookingDetailStatus.loading ||
        state.status == BookingDetailStatus.initial) {
      return const BookingDetailSkeleton();
    }
    if (state.status == BookingDetailStatus.failure || state.booking == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: BookingDetailErrorBody(onRetry: controller.load),
          ),
        ],
      );
    }

    final booking = state.booking!;
    final face = mapMyBookingFace(booking);
    final stadium = state.stadium;
    final showPayment = bookingDetailShowsPaymentBanner(booking);
    final heroHeight = BookingDetailHero.totalHeightFor(context);
    final sheetTop = BookingDetailHero.layoutHeightFor(context);

    return CustomScrollView(
      key: const ValueKey('booking-detail-root'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: BookingDetailHero(
                  state: state,
                  face: face,
                  onBack: () => _goBack(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: sheetTop),
                child: StadiumDetailContentSheet(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BookingFactChips(state: state),
                        if (state.offersPin) ...[
                          const SizedBox(height: AppSpacing.md),
                          BookingPinCard(
                            state: state,
                            onShow: controller.showPin,
                            onHide: controller.hidePin,
                            onRetry: controller.retryPin,
                            onCopy: () {
                              final pin = state.pin;
                              if (pin == null) return;
                              unawaited(copyBookingPin(context, pin));
                            },
                          ),
                        ],
                        if (showPayment) ...[
                          const SizedBox(height: AppSpacing.md),
                          BookingPaymentBanner(booking: booking, face: face),
                        ],
                        if (stadium != null &&
                            (stadium.address.trim().isNotEmpty ||
                                stadium.hasCoordinates ||
                                stadium.contactPhone.trim().isNotEmpty)) ...[
                          const SizedBox(height: AppSpacing.sm),
                          BookingLocationActions(
                            state: state,
                            onDirections:
                                stadium.hasCoordinates
                                    ? () {
                                      unawaited(
                                        externalActions.openDirections(
                                          latitude: stadium.latitude!,
                                          longitude: stadium.longitude!,
                                        ),
                                      );
                                    }
                                    : null,
                            onContact:
                                stadium.contactPhone.trim().isNotEmpty
                                    ? () {
                                      unawaited(
                                        externalActions.callPhone(
                                          stadium.contactPhone,
                                        ),
                                      );
                                    }
                                    : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openPayment(BuildContext context) async {
    await context.push(AppRoutes.bookingPayment(bookingId));
  }
}

class _PaymentActionBar extends StatelessWidget {
  const _PaymentActionBar({required this.state, required this.onPayment});

  final BookingDetailState state;
  final VoidCallback onPayment;

  @override
  Widget build(BuildContext context) {
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();
    final action = bookingDetailPaymentAction(booking);
    final label = bookingDetailPaymentActionLabel(context.l10n, action);
    if (label == null) return const SizedBox.shrink();

    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outlineSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(onPressed: onPayment, child: Text(label)),
            ),
          ),
        ),
      ),
    );
  }
}
