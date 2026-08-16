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
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/my_booking_face.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/my_bookings_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/widgets/booking_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_screen.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(myBookingsControllerProvider);
    final controller = ref.read(myBookingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.navBookings,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
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
                child: _FilterRow(
                  selected: state.filter,
                  onSelected: controller.setFilter,
                ),
              ),
              if (state.error != null &&
                  state.status != MyBookingsStatus.failure &&
                  state.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      _errorText(l10n, state.error),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
              ..._bodySlivers(context, l10n, state, controller),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _bodySlivers(
    BuildContext context,
    AppLocalizations l10n,
    MyBookingsState state,
    MyBookingsController controller,
  ) {
    if (state.status == MyBookingsStatus.loading ||
        state.status == MyBookingsStatus.initial) {
      return const [MyBookingsSkeletonList()];
    }
    if (state.status == MyBookingsStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ErrorBody(
            message: _errorText(l10n, state.error),
            onRetry: controller.loadInitial,
          ),
        ),
      ];
    }
    if (state.status == MyBookingsStatus.empty || state.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyBody(filter: state.filter),
        ),
      ];
    }
    final entries = _listEntries(l10n, state);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = entries[index];
              if (entry.header != null) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? AppSpacing.xxs : AppSpacing.md,
                    bottom: AppSpacing.xs,
                  ),
                  child: Text(
                    entry.header!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandDeep,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MyBookingCard(
                  booking: entry.booking!,
                  onOpenDetail:
                      () => _openDetail(context, controller, entry.booking!),
                  onAction:
                      () => _onAction(context, controller, entry.booking!),
                ),
              );
            },
            childCount: entries.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: _PaginationFooter(state: state, controller: controller),
        ),
      ),
    ];
  }

  static List<_ListEntry> _listEntries(
    AppLocalizations l10n,
    MyBookingsState state,
  ) {
    if (state.filter != MyBookingsFilter.all) {
      return [for (final booking in state.items) _ListEntry.item(booking)];
    }
    final upcoming = state.items
        .where(myBookingIsUpcoming)
        .toList(growable: false);
    final past = state.items
        .where((booking) => !myBookingIsUpcoming(booking))
        .toList(growable: false);
    return [
      if (upcoming.isNotEmpty) ...[
        _ListEntry.header(l10n.myBookingsUpcoming),
        for (final booking in upcoming) _ListEntry.item(booking),
      ],
      if (past.isNotEmpty) ...[
        _ListEntry.header(l10n.myBookingsPast),
        for (final booking in past) _ListEntry.item(booking),
      ],
    ];
  }

  Future<void> _openDetail(
    BuildContext context,
    MyBookingsController controller,
    CustomerBooking booking,
  ) async {
    await context.push(AppRoutes.bookingDetail(booking.id));
    if (context.mounted) await controller.refreshQuiet();
  }

  Future<void> _onAction(
    BuildContext context,
    MyBookingsController controller,
    CustomerBooking booking,
  ) async {
    final action = myBookingActionFor(booking);
    switch (action) {
      case MyBookingAction.completePayment:
      case MyBookingAction.retryPayment:
      case MyBookingAction.viewPayment:
        await context.push(AppRoutes.bookingPayment(booking.id));
        if (context.mounted) await controller.refreshQuiet();
      case MyBookingAction.viewBooking:
      case MyBookingAction.none:
        await _openDetail(context, controller, booking);
    }
  }

  static String _errorText(AppLocalizations l10n, Object? error) {
    if (error is AppException) return error.message;
    return l10n.myBookingsLoadFailed;
  }
}

class _ListEntry {
  const _ListEntry.header(this.header) : booking = null;
  const _ListEntry.item(this.booking) : header = null;

  final String? header;
  final CustomerBooking? booking;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final MyBookingsFilter selected;
  final ValueChanged<MyBookingsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        itemCount: MyBookingsFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final filter = MyBookingsFilter.values[index];
          final selectedChip = selected == filter;
          return FilterChip(
            label: Text(_filterLabel(l10n, filter)),
            selected: selectedChip,
            onSelected: (_) => onSelected(filter),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            selectedColor: AppColors.primarySoft,
            backgroundColor: AppColors.surfaceMuted,
            side: BorderSide(
              color: selectedChip ? AppColors.primary : Colors.transparent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            labelStyle: TextStyle(
              fontWeight: selectedChip ? FontWeight.w700 : FontWeight.w500,
              color:
                  selectedChip ? AppColors.onPrimarySoft : AppColors.onSurface,
            ),
          );
        },
      ),
    );
  }

  static String _filterLabel(AppLocalizations l10n, MyBookingsFilter filter) {
    switch (filter) {
      case MyBookingsFilter.all:
        return l10n.myBookingsFilterAll;
      case MyBookingsFilter.pending:
        return l10n.myBookingsFilterPending;
      case MyBookingsFilter.confirmed:
        return l10n.myBookingsFilterConfirmed;
      case MyBookingsFilter.completed:
        return l10n.myBookingsFilterCompleted;
    }
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.filter});

  final MyBookingsFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (filter) {
      MyBookingsFilter.all => l10n.myBookingsEmptyTitle,
      MyBookingsFilter.pending => l10n.myBookingsEmptyPending,
      MyBookingsFilter.confirmed => l10n.myBookingsEmptyConfirmed,
      MyBookingsFilter.completed => l10n.myBookingsEmptyCompleted,
    };
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            size: 40,
            color: AppColors.brandDeep.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.myBookingsEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => context.go(AppRoutes.search),
            child: Text(l10n.myBookingsFindPitch),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.myBookingsLoadFailed,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (message != l10n.myBookingsLoadFailed) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.controller});

  final MyBookingsState state;
  final MyBookingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.status == MyBookingsStatus.loadingMore) {
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
    if (state.loadMoreError != null) {
      return Center(
        child: TextButton(
          onPressed: controller.retryLoadMore,
          child: Text(l10n.catalogLoadMoreRetry),
        ),
      );
    }
    if (!state.hasMore) {
      return const SizedBox(height: AppSpacing.md);
    }
    return const SizedBox.shrink();
  }
}

class MyBookingCard extends StatelessWidget {
  const MyBookingCard({
    super.key,
    required this.booking,
    required this.onOpenDetail,
    required this.onAction,
  });

  final CustomerBooking booking;
  final VoidCallback onOpenDetail;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final face = mapMyBookingFace(booking);
    final action = myBookingActionFor(booking);
    final statusLabel = bookingDetailStatusLabel(l10n, face);
    final actionLabel = _actionLabel(l10n, action);
    final remaining =
        myBookingShowsHoldCountdown(booking)
            ? myBookingRemainingHold(booking)
            : null;
    final dateLabel = DateFormat.yMMMEd(
      localeCode,
    ).format(StadiumTime.parseIsoDate(booking.date));
    final timeRange = '${booking.startTime} → ${booking.endTime}';
    final price = SdgFormatter.format(booking.priceSdg, locale: localeCode);
    final statusColors = bookingDetailStatusColors(face);
    final showPaymentCta = actionLabel != null;

    return Semantics(
      button: true,
      label:
          '${booking.stadiumName}. ${booking.pitchName}. $statusLabel. '
          '$dateLabel. ${booking.startTime} ${booking.endTime}. $price'
          '${actionLabel != null ? '. $actionLabel' : ''}',
      child: Material(
        color: AppColors.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onOpenDetail,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.outlineSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PassThumb(),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                timeRange,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppColors.brandDeep,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.stadiumName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${booking.pitchName} · ${booking.pitchType.label(l10n)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceMuted),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: BookingStatusBadge(
                              label: statusLabel,
                              background: statusColors.$1,
                              foreground: statusColors.$2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!showPaymentCta)
                      const Padding(
                        padding: EdgeInsets.only(top: 2, left: 2),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                  ],
                ),
                if (remaining != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.paymentHoldRemaining(
                          formatHoldCountdown(remaining),
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDeep,
                        ),
                      ),
                    ),
                  ),
                ],
                if (face == MyBookingFace.paymentRejected) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.myBookingsRejectedHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
                if (showPaymentCta) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child:
                        action == MyBookingAction.viewPayment
                            ? FilledButton.tonal(
                              onPressed: onAction,
                              child: FittedBox(child: Text(actionLabel)),
                            )
                            : FilledButton(
                              onPressed: onAction,
                              child: FittedBox(child: Text(actionLabel)),
                            ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _actionLabel(AppLocalizations l10n, MyBookingAction action) {
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
}

class _PassThumb extends StatelessWidget {
  const _PassThumb();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: const SizedBox(
        width: 72,
        height: 72,
        child: ColoredBox(
          color: AppColors.imageFallback,
          child: Icon(
            Icons.sports_soccer_rounded,
            color: AppColors.onImageFallback,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class MyBookingsSkeletonList extends StatelessWidget {
  const MyBookingsSkeletonList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const _BookingSkeletonCard(),
      ),
    );
  }
}

class _BookingSkeletonCard extends StatelessWidget {
  const _BookingSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.outlineSubtle),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      color: AppColors.surfaceMuted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 10,
                      width: 160,
                      color: AppColors.surfaceMuted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 10,
                      width: 90,
                      color: AppColors.surfaceMuted,
                    ),
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
