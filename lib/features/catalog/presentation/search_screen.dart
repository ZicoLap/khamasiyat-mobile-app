import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_error_mapper.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/catalog_state.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_controller.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_widgets.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogControllerProvider(CatalogScope.search));
    final controller = ref.read(
      catalogControllerProvider(CatalogScope.search).notifier,
    );
    final showCount =
        catalog.status == CatalogStatus.loaded ||
        catalog.status == CatalogStatus.refreshing ||
        catalog.status == CatalogStatus.loadingMore ||
        catalog.status == CatalogStatus.empty;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
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
                          l10n.searchTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.searchSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CatalogFilterControls(
                          filters: catalog.filters,
                          dense: true,
                          onApplied: controller.applyFilters,
                          onClearAll:
                              catalog.filters.hasAny
                                  ? controller.clearFilters
                                  : null,
                        ),
                        if (showCount) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.searchResultsCount(catalog.total),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.onSurfaceMuted),
                          ),
                        ],
                        if (catalog.error != null &&
                            catalog.status != CatalogStatus.failure) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            mapAuthError(catalog.error!, l10n),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (catalog.status == CatalogStatus.initial ||
                    catalog.status == CatalogStatus.loading)
                  const CatalogSkeletonList(compact: true, itemCount: 5)
                else if (catalog.status == CatalogStatus.failure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CatalogErrorView(
                      message: mapAuthError(catalog.error!, l10n),
                      onRetry: controller.loadInitial,
                    ),
                  )
                else if (catalog.status == CatalogStatus.empty ||
                    catalog.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CatalogEmptyView(
                      onClearFilters:
                          catalog.filters.hasAny
                              ? controller.clearFilters
                              : null,
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    sliver: SliverList.separated(
                      itemCount: catalog.items.length,
                      separatorBuilder:
                          (_, __) => const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final stadium = catalog.items[index];
                        return CompactStadiumCard(
                          stadium: stadium,
                          onTap:
                              () => context.push(
                                AppRoutes.stadiumDetail(stadium.id),
                              ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: _SearchFooter(
                        catalog: catalog,
                        controller: controller,
                      ),
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
}

class _SearchFooter extends StatelessWidget {
  const _SearchFooter({required this.catalog, required this.controller});

  final CatalogState catalog;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (catalog.status == CatalogStatus.loadingMore) {
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
    if (catalog.loadMoreError != null) {
      return Center(
        child: TextButton(
          onPressed: controller.retryLoadMore,
          child: Text(l10n.catalogLoadMoreRetry),
        ),
      );
    }
    if (!catalog.hasMore) {
      return Center(
        child: Text(
          l10n.catalogEndOfList,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
