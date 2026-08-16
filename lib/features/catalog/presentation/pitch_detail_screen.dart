import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';
import 'package:khamasiyat_mobile_app/features/availability/presentation/availability_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/booking_review_draft.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_controller.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/booking_review_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/pitch_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/pitch_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';
import 'package:khamasiyat_mobile_app/features/realtime/presentation/pitch_realtime_controller.dart';
import 'package:khamasiyat_mobile_app/shared/platform/pitch_share_actions.dart';

const _visibleDays = 14;

class PitchDetailScreen extends ConsumerStatefulWidget {
  const PitchDetailScreen({
    super.key,
    required this.pitchId,
    this.shareActions = const PitchShareActions(),
  });

  final String pitchId;
  final PitchShareActions shareActions;

  @override
  ConsumerState<PitchDetailScreen> createState() => _PitchDetailScreenState();
}

class _PitchDetailScreenState extends ConsumerState<PitchDetailScreen>
    with WidgetsBindingObserver {
  late String _rangeFrom;
  late String _rangeTo;
  String? _selectedDate;
  AvailabilitySlot? _selectedSlot;
  var _appForeground = true;
  Timer? _realtimeRefreshDebounce;

  @override
  void initState() {
    super.initState();
    _rangeFrom = StadiumTime.todayIsoDate(utcNow: clock.now().toUtc());
    _rangeTo = StadiumTime.addIsoDateDays(_rangeFrom, _visibleDays - 1);
    _selectedDate = _rangeFrom;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _realtimeRefreshDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    _appForeground = foreground;
    if (!foreground) {
      _realtimeRefreshDebounce?.cancel();
      _realtimeRefreshDebounce = null;
    }
    if (ref.exists(pitchRealtimeProvider(widget.pitchId))) {
      ref
          .read(pitchRealtimeProvider(widget.pitchId).notifier)
          .setForeground(foreground);
    }
    if (!ref.exists(pitchAvailabilityProvider(_query))) return;
    ref
        .read(pitchAvailabilityProvider(_query).notifier)
        .setForeground(foreground);
  }

  List<String> get _dates {
    return [
      for (var i = 0; i < _visibleDays; i++)
        StadiumTime.addIsoDateDays(_rangeFrom, i),
    ];
  }

  AvailabilityQuery get _query => AvailabilityQuery(
    pitchId: widget.pitchId,
    from: _rangeFrom,
    to: _rangeTo,
  );

  Future<void> _openCalendar() async {
    final first = StadiumTime.parseIsoDate(_rangeFrom);
    final picked = await showDatePicker(
      context: context,
      initialDate: StadiumTime.parseIsoDate(_selectedDate ?? _rangeFrom),
      firstDate: first,
      lastDate: first.add(const Duration(days: 61)),
    );
    if (picked == null) return;
    final iso = StadiumTime.toIsoDate(picked);
    setState(() {
      if (iso.compareTo(_rangeFrom) < 0 || iso.compareTo(_rangeTo) > 0) {
        _rangeFrom = iso;
        _rangeTo = StadiumTime.addIsoDateDays(iso, _visibleDays - 1);
      }
      _selectedDate = iso;
      _selectedSlot = null;
    });
  }

  Future<void> _refreshAvailability() {
    return ref.read(pitchAvailabilityProvider(_query).notifier).refreshQuiet();
  }

  void _scheduleRealtimeAvailabilityRefresh() {
    if (!_appForeground) return;
    _realtimeRefreshDebounce?.cancel();
    final window = ref.read(availabilityRealtimeDebounceProvider);
    _realtimeRefreshDebounce = Timer(window, () {
      if (!mounted || !_appForeground) return;
      unawaited(
        ref.read(pitchAvailabilityProvider(_query).notifier).refreshQuiet(
          queueIfBusy: true,
        ),
      );
    });
  }

  void _syncSelection(PitchAvailability? availability) {
    final selected = _selectedSlot;
    if (selected == null || availability == null) return;
    AvailabilitySlot? found;
    for (final slot in availability.items) {
      if (slot.id == selected.id) {
        found = slot;
        break;
      }
    }
    if (found == null) {
      setState(() => _selectedSlot = null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pitchDetailSlotUnavailable)),
      );
      return;
    }
    if (found.startTime != selected.startTime ||
        found.endTime != selected.endTime ||
        found.priceSdg != selected.priceSdg ||
        found.date != selected.date) {
      setState(() => _selectedSlot = found);
    }
  }

  /// Continue navigates to Booking Summary only — never calls POST /bookings.
  Future<void> _continueToReview(
    PitchDetail pitch,
    AvailabilitySlot slot,
  ) async {
    final draft = BookingReviewDraft.fromPitchAndSlot(
      pitch: pitch,
      slot: slot,
    );
    ref.read(bookingReviewDraftProvider.notifier).state = draft;

    final BookingReviewPopResult? result;
    if (GoRouter.maybeOf(context) != null) {
      result = await context.push<BookingReviewPopResult>(
        AppRoutes.bookingReview,
      );
    } else {
      result = await Navigator.of(context).push<BookingReviewPopResult>(
        MaterialPageRoute(
          builder: (_) => const BookingReviewScreen(),
        ),
      );
    }
    if (!mounted) return;
    if (result == BookingReviewPopResult.slotUnavailable) {
      setState(() => _selectedSlot = null);
      await _refreshAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pitchRealtimeProvider(widget.pitchId).select((_) => true));
    ref.listen<PitchRealtimeState>(pitchRealtimeProvider(widget.pitchId), (
      previous,
      next,
    ) {
      if (previous == null || next.generation <= previous.generation) return;
      _scheduleRealtimeAvailabilityRefresh();
    });
    final async = ref.watch(pitchDetailProvider(widget.pitchId));
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final pitch = async.valueOrNull;

    ref.listen<AsyncValue<PitchAvailability>>(
      pitchAvailabilityProvider(_query),
      (previous, next) {
        _syncSelection(next.valueOrNull);
      },
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      bottomNavigationBar:
          _selectedSlot == null || pitch == null
              ? null
              : PitchBookingBar(
                slot: _selectedSlot!,
                localeCode: localeCode,
                busy: false,
                onContinue: () {
                  unawaited(_continueToReview(pitch, _selectedSlot!));
                },
              ),
      body: async.when(
        loading:
            () => PitchDetailSkeleton(
              onBack: () => Navigator.of(context).maybePop(),
            ),
        error:
            (error, _) => PitchDetailErrorBody(
              message: l10n.pitchDetailErrorBody,
              onRetry:
                  () =>
                      ref
                          .read(pitchDetailProvider(widget.pitchId).notifier)
                          .retry(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
        data:
            (pitch) => _PitchDetailBody(
              pitch: pitch,
              dates: _dates,
              selectedDate: _selectedDate ?? _rangeFrom,
              selectedSlot: _selectedSlot,
              query: _query,
              appForeground: _appForeground,
              shareActions: widget.shareActions,
              onSelectDate: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedSlot = null;
                });
              },
              onSelectSlot: (slot) {
                setState(() => _selectedSlot = slot);
              },
              onCalendar: _openCalendar,
              onRefresh: _refreshAvailability,
            ),
      ),
    );
  }
}

class _PitchDetailBody extends ConsumerWidget {
  const _PitchDetailBody({
    required this.pitch,
    required this.dates,
    required this.selectedDate,
    required this.selectedSlot,
    required this.query,
    required this.appForeground,
    required this.shareActions,
    required this.onSelectDate,
    required this.onSelectSlot,
    required this.onCalendar,
    required this.onRefresh,
  });

  final PitchDetail pitch;
  final List<String> dates;
  final String selectedDate;
  final AvailabilitySlot? selectedSlot;
  final AvailabilityQuery query;
  final bool appForeground;
  final PitchShareActions shareActions;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<AvailabilitySlot> onSelectSlot;
  final VoidCallback onCalendar;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final availabilityAsync = ref.watch(pitchAvailabilityProvider(query));
    ref
        .read(pitchAvailabilityProvider(query).notifier)
        .alignForeground(appForeground);
    ref
        .read(pitchRealtimeProvider(query.pitchId).notifier)
        .alignForeground(appForeground);
    final heroHeight = PitchDetailHero.totalHeightFor(context);
    final sheetTop = PitchDetailHero.layoutHeightFor(context);
    final availability = availabilityAsync.valueOrNull;
    final quietRefreshFailed =
        availabilityAsync.hasError && availability != null;

    return RefreshIndicator(
      key: const ValueKey('pitch-availability-refresh'),
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: PitchDetailHero(
                    photos: pitch.photos,
                    pitchName: pitch.name,
                    onBack: () => Navigator.of(context).maybePop(),
                    onShare: () {
                      unawaited(
                        shareActions.shareText(
                          l10n.pitchDetailShareText(
                            pitch.name,
                            pitch.stadium.name,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: sheetTop),
                  child: StadiumDetailContentSheet(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PitchSummaryBlock(
                            pitch: pitch,
                            fromPriceSdg:
                                availability?.minPriceForDate(selectedDate) ??
                                availability?.minPriceSdg,
                            localeCode: localeCode,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PitchDateStrip(
                            dates: dates,
                            selectedDate: selectedDate,
                            localeCode: localeCode,
                            onSelect: onSelectDate,
                            onCalendar: onCalendar,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (quietRefreshFailed) ...[
                            PitchAvailabilityRefreshBanner(
                              onRetry: () {
                                unawaited(
                                  ref
                                      .read(
                                        pitchAvailabilityProvider(
                                          query,
                                        ).notifier,
                                      )
                                      .refreshQuiet(),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (availabilityAsync.isLoading &&
                              availability == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (availabilityAsync.hasError &&
                              availability == null)
                            Column(
                              children: [
                                Text(
                                  l10n.pitchDetailErrorBody,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceMuted,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      () =>
                                          ref
                                              .read(
                                                pitchAvailabilityProvider(
                                                  query,
                                                ).notifier,
                                              )
                                              .retry(),
                                  child: Text(l10n.retryAction),
                                ),
                              ],
                            )
                          else
                            PitchSlotsSection(
                              slots:
                                  availability?.forDate(selectedDate) ??
                                  const [],
                              selectedId: selectedSlot?.id,
                              localeCode: localeCode,
                              onSelect: onSelectSlot,
                              onChooseDate: onCalendar,
                              onRefresh: () {
                                unawaited(onRefresh());
                              },
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          PitchTimezoneNote(timeZone: pitch.stadium.timeZone),
                        ],
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
}
