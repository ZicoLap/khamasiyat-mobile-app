import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/stadium_detail_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/stadium_detail_widgets.dart';
import 'package:khamasiyat_mobile_app/shared/platform/external_actions.dart';

/// Public stadium detail (`GET /stadiums/:id`) — F3A.
class StadiumDetailScreen extends ConsumerStatefulWidget {
  const StadiumDetailScreen({
    super.key,
    required this.stadiumId,
    this.externalActions = const ExternalActions(),
  });

  final String stadiumId;
  final ExternalActions externalActions;

  @override
  ConsumerState<StadiumDetailScreen> createState() =>
      _StadiumDetailScreenState();
}

class _StadiumDetailScreenState extends ConsumerState<StadiumDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(stadiumDetailProvider(widget.stadiumId));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: async.when(
        loading:
            () => StadiumDetailSkeleton(
              onBack: () => Navigator.of(context).maybePop(),
            ),
        error:
            (error, _) => StadiumDetailErrorBody(
              message: l10n.stadiumDetailErrorBody,
              onRetry:
                  () =>
                      ref
                          .read(
                            stadiumDetailProvider(widget.stadiumId).notifier,
                          )
                          .retry(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
        data:
            (stadium) => _StadiumDetailBody(
              stadium: stadium,
              scrollController: _scrollController,
              externalActions: widget.externalActions,
            ),
      ),
    );
  }
}

class _StadiumDetailBody extends StatelessWidget {
  const _StadiumDetailBody({
    required this.stadium,
    required this.scrollController,
    required this.externalActions,
  });

  final StadiumDetail stadium;
  final ScrollController scrollController;
  final ExternalActions externalActions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = stadium.description?.trim();
    final rules = stadium.rules?.trim();
    final hasAbout = description != null && description.isNotEmpty;
    final hasRules = rules != null && rules.isNotEmpty;
    final showSummary =
        stadium.pitches.isNotEmpty ||
        stadium.amenities.isNotEmpty ||
        stadium.availablePitchTypes.isNotEmpty;

    final heroHeight = StadiumDetailHero.totalHeightFor(context);
    final sheetTop = StadiumDetailHero.layoutHeightFor(context);

    return CustomScrollView(
      controller: scrollController,
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
                child: StadiumDetailHero(
                  photos: stadium.photos,
                  stadiumName: stadium.name,
                  locationLine:
                      '${stadium.city.label(l10n)} · ${stadium.state.label(l10n)}',
                  onBack: () => Navigator.of(context).maybePop(),
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
                        if (showSummary) ...[
                          StadiumSummaryPanel(stadium: stadium),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (hasAbout) ...[
                          ExpandableTextSection(
                            title: l10n.stadiumDetailAbout,
                            body: description,
                            showMoreLabel: l10n.stadiumDetailShowMore,
                            showLessLabel: l10n.stadiumDetailShowLess,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        StadiumPitchesSection(
                          pitches: stadium.pitches,
                          onPitchTap: (pitchId) {
                            context.push(AppRoutes.pitchDetail(pitchId));
                          },
                        ),
                        if (stadium.amenities.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          StadiumFacilitiesSection(
                            amenities: stadium.amenities,
                          ),
                        ],
                        if (hasRules) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ExpandableTextSection(
                            title: l10n.stadiumDetailRules,
                            body: rules,
                            showMoreLabel: l10n.stadiumDetailShowMore,
                            showLessLabel: l10n.stadiumDetailShowLess,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        StadiumLocationSection(
                          stadium: stadium,
                          onDirections:
                              stadium.hasCoordinates
                                  ? () => externalActions.openDirections(
                                    latitude: stadium.latitude!,
                                    longitude: stadium.longitude!,
                                  )
                                  : null,
                          onCall:
                              stadium.contactPhone.trim().isNotEmpty
                                  ? () => externalActions.callPhone(
                                    stadium.contactPhone,
                                  )
                                  : null,
                        ),
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
}

class StadiumDetailErrorBody extends StatelessWidget {
  const StadiumDetailErrorBody({
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.stadiumDetailErrorTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
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
