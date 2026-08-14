import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_api.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';

class CatalogRepository {
  CatalogRepository(this._remote);

  final CatalogRemoteSource _remote;

  Future<StadiumListPage> listStadiums({
    CatalogFilters filters = CatalogFilters.empty,
    int page = 1,
    int limit = 20,
  }) {
    return _remote.listStadiums(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  Future<StadiumDetail> getStadium(String stadiumId) {
    return _remote.getStadium(stadiumId);
  }
}

final catalogApiProvider = Provider<CatalogApi>((ref) {
  return CatalogApi(ref.watch(apiClientProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(catalogApiProvider));
});
