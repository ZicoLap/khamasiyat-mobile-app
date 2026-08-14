import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/catalog_state.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

enum CatalogScope { home, search }

/// In-memory catalog cache policy (F2):
/// - Each [CatalogScope] keeps its own list + filters while the app process lives.
/// - Stateful shell + [ref.keepAlive] retain state across tab switches.
/// - Pull-to-refresh / filter changes always hit the network.
/// - Never treat cached rows as authoritative availability.
final catalogControllerProvider = StateNotifierProvider.family<
    CatalogController, CatalogState, CatalogScope>((ref, scope) {
  ref.keepAlive();
  final controller = CatalogController(
    repository: ref.watch(catalogRepositoryProvider),
  );
  // Auto-load once for each scope.
  controller.loadInitial();
  return controller;
});

class CatalogController extends StateNotifier<CatalogState> {
  CatalogController({
    required CatalogRepository repository,
    this.pageSize = 20,
  })  : _repository = repository,
        super(CatalogState.initial);

  final CatalogRepository _repository;
  final int pageSize;

  var _loadMoreInFlight = false;

  Future<void> loadInitial() async {
    if (state.status == CatalogStatus.loading) {
      return;
    }
    state = state.copyWith(
      status: CatalogStatus.loading,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> refresh() async {
    if (state.status == CatalogStatus.refreshing ||
        state.status == CatalogStatus.loading) {
      return;
    }
    state = state.copyWith(
      status: CatalogStatus.refreshing,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true, isRefresh: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        _loadMoreInFlight ||
        state.status == CatalogStatus.loading ||
        state.status == CatalogStatus.loadingMore ||
        state.status == CatalogStatus.refreshing) {
      return;
    }
    _loadMoreInFlight = true;
    state = state.copyWith(
      status: CatalogStatus.loadingMore,
      clearLoadMoreError: true,
    );
    try {
      await _fetchPage(page: state.page + 1, replace: false);
    } finally {
      _loadMoreInFlight = false;
    }
  }

  Future<void> retryLoadMore() => loadMore();

  Future<void> applyFilters(CatalogFilters filters) async {
    state = state.copyWith(
      filters: filters,
      status: CatalogStatus.loading,
      items: const [],
      page: 0,
      total: 0,
      clearError: true,
      clearLoadMoreError: true,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> setStateFilter(SudanState? next) {
    return applyFilters(state.filters.withState(next));
  }

  Future<void> setCityFilter(SudanCity? next) {
    final filters = state.filters;
    if (next != null &&
        filters.state != null &&
        !SudanLocations.isCityInState(filters.state!, next)) {
      return applyFilters(
        CatalogFilters(
          state: SudanLocations.cityToState[next],
          city: next,
          pitchType: filters.pitchType,
        ),
      );
    }
    if (next != null && filters.state == null) {
      return applyFilters(
        CatalogFilters(
          state: SudanLocations.cityToState[next],
          city: next,
          pitchType: filters.pitchType,
        ),
      );
    }
    return applyFilters(
      next == null ? filters.copyWith(clearCity: true) : filters.copyWith(city: next),
    );
  }

  Future<void> setPitchTypeFilter(PitchType? next) {
    return applyFilters(
      next == null
          ? state.filters.copyWith(clearPitchType: true)
          : state.filters.copyWith(pitchType: next),
    );
  }

  Future<void> clearFilters() => applyFilters(CatalogFilters.empty);

  Future<void> _fetchPage({
    required int page,
    required bool replace,
    bool isRefresh = false,
  }) async {
    try {
      final result = await _repository.listStadiums(
        filters: state.filters,
        page: page,
        limit: pageSize,
      );

      final merged = replace
          ? result.items
          : [...state.items, ...result.items];

      state = state.copyWith(
        status: merged.isEmpty ? CatalogStatus.empty : CatalogStatus.loaded,
        items: merged,
        page: result.page,
        limit: result.limit,
        total: result.total,
        clearError: true,
        clearLoadMoreError: true,
      );
    } catch (error) {
      if (replace && state.items.isEmpty) {
        state = state.copyWith(
          status: CatalogStatus.failure,
          error: error,
        );
      } else if (replace && isRefresh) {
        // Keep existing items; surface refresh failure via error banner.
        state = state.copyWith(
          status: CatalogStatus.loaded,
          error: error,
        );
      } else {
        state = state.copyWith(
          status: CatalogStatus.loaded,
          loadMoreError: error,
        );
      }
    }
  }
}
