import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';

/// Catalog list presentation status.
enum CatalogStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  empty,
  failure,
}

class CatalogState {
  const CatalogState({
    required this.status,
    required this.filters,
    this.items = const [],
    this.page = 0,
    this.limit = 20,
    this.total = 0,
    this.error,
    this.loadMoreError,
  });

  final CatalogStatus status;
  final CatalogFilters filters;
  final List<StadiumListItem> items;
  final int page;
  final int limit;
  final int total;
  final Object? error;
  final Object? loadMoreError;

  static const initial = CatalogState(
    status: CatalogStatus.initial,
    filters: CatalogFilters.empty,
  );

  bool get hasMore => items.length < total;

  bool get isBusy =>
      status == CatalogStatus.loading ||
      status == CatalogStatus.refreshing ||
      status == CatalogStatus.loadingMore;

  CatalogState copyWith({
    CatalogStatus? status,
    CatalogFilters? filters,
    List<StadiumListItem>? items,
    int? page,
    int? limit,
    int? total,
    Object? error,
    Object? loadMoreError,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      error: clearError ? null : (error ?? this.error),
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}
