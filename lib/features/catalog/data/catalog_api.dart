import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';

abstract class CatalogRemoteSource {
  Future<StadiumListPage> listStadiums({
    required CatalogFilters filters,
    required int page,
    required int limit,
  });

  Future<StadiumDetail> getStadium(String stadiumId);
}

class CatalogApi implements CatalogRemoteSource {
  CatalogApi(this._client);

  final ApiClient _client;

  @override
  Future<StadiumListPage> listStadiums({
    required CatalogFilters filters,
    required int page,
    required int limit,
  }) {
    return _client.get(
      '/stadiums',
      queryParameters: filters.toQueryParameters(page: page, limit: limit),
      fromJson: (json) => StadiumListPage.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }

  @override
  Future<StadiumDetail> getStadium(String stadiumId) {
    return _client.get(
      '/stadiums/$stadiumId',
      fromJson: (json) => StadiumDetail.fromJson(
        Map<String, dynamic>.from(json! as Map),
      ),
    );
  }
}
