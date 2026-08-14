import 'package:flutter_test/flutter_test.dart';
import 'package:khamasiyat_mobile_app/core/errors/app_exception.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/catalog_state.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_controller.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

import '../../helpers/fake_catalog_remote.dart';

void main() {
  group('StadiumListItem parsing', () {
    test('parses list page JSON', () {
      final page = StadiumListPage.fromJson({
        'items': [
          {
            'id': 's1',
            'name': 'Arena',
            'description': null,
            'state': 'KHARTOUM',
            'city': 'OMDURMAN',
            'address': 'A',
            'latitude': 15.5,
            'longitude': 32.5,
            'amenities': ['PARKING'],
            'timeZone': 'Africa/Khartoum',
            'primaryPhoto': {'url': 'https://example.com/a.jpg', 'type': 'HERO'},
            'activePitchCount': 3,
          },
        ],
        'total': 1,
        'page': 1,
        'limit': 20,
      });

      expect(page.items.single.name, 'Arena');
      expect(page.items.single.state, SudanState.khartoum);
      expect(page.items.single.city, SudanCity.omdurman);
      expect(page.items.single.primaryPhoto?.url, contains('example.com'));
      expect(page.hasMore, isFalse);
    });
  });

  group('CatalogFilters', () {
    test('resets city when state changes incompatibly', () {
      const filters = CatalogFilters(
        state: SudanState.khartoum,
        city: SudanCity.omdurman,
        pitchType: PitchType.fiveASide,
      );
      final next = filters.withState(SudanState.redSea);
      expect(next.state, SudanState.redSea);
      expect(next.city, isNull);
      expect(next.pitchType, PitchType.fiveASide);
    });

    test('keeps city when still valid', () {
      const filters = CatalogFilters(
        state: SudanState.khartoum,
        city: SudanCity.bahri,
      );
      final next = filters.withState(SudanState.khartoum);
      expect(next.city, SudanCity.bahri);
    });

    test('builds query params with backend enum values', () {
      const filters = CatalogFilters(
        state: SudanState.khartoum,
        city: SudanCity.omdurman,
        pitchType: PitchType.sevenASide,
      );
      expect(
        filters.toQueryParameters(page: 2, limit: 20),
        {
          'page': 2,
          'limit': 20,
          'state': 'KHARTOUM',
          'city': 'OMDURMAN',
          'pitchType': 'SEVEN_A_SIDE',
        },
      );
    });
  });

  group('CatalogController', () {
    late FakeCatalogRemote remote;
    late CatalogController controller;

    setUp(() {
      remote = FakeCatalogRemote(
        pages: {
          1: StadiumListPage(
            items: [sampleStadium(id: 's1'), sampleStadium(id: 's2')],
            total: 3,
            page: 1,
            limit: 2,
          ),
          2: StadiumListPage(
            items: [sampleStadium(id: 's3')],
            total: 3,
            page: 2,
            limit: 2,
          ),
        },
      );
      controller = CatalogController(
        repository: CatalogRepository(remote),
        pageSize: 2,
      );
    });

    test('loadInitial populates items', () async {
      await controller.loadInitial();
      expect(controller.state.status, CatalogStatus.loaded);
      expect(controller.state.items.length, 2);
      expect(controller.state.hasMore, isTrue);
    });

    test('loadMore merges pages and protects duplicates', () async {
      await controller.loadInitial();
      await Future.wait([
        controller.loadMore(),
        controller.loadMore(),
        controller.loadMore(),
      ]);
      expect(controller.state.items.map((e) => e.id), ['s1', 's2', 's3']);
      expect(
        remote.requests.where((r) => r['page'] == 2).length,
        1,
      );
      expect(controller.state.hasMore, isFalse);
    });

    test('filter change resets pagination', () async {
      await controller.loadInitial();
      await controller.setPitchTypeFilter(PitchType.fiveASide);
      expect(controller.state.page, 1);
      expect(controller.state.filters.pitchType, PitchType.fiveASide);
      expect(remote.requests.last['pitchType'], 'FIVE_A_SIDE');
    });

    test('loadMore failure keeps existing items', () async {
      await controller.loadInitial();
      remote.failWith = const NetworkException(message: 'offline');
      await controller.loadMore();
      expect(controller.state.items.length, 2);
      expect(controller.state.loadMoreError, isA<NetworkException>());
      expect(controller.state.status, CatalogStatus.loaded);
    });

    test('refresh failure keeps existing items', () async {
      await controller.loadInitial();
      remote.failWith = const NetworkException(message: 'offline');
      await controller.refresh();
      expect(controller.state.items.length, 2);
      expect(controller.state.error, isA<NetworkException>());
      expect(controller.state.status, CatalogStatus.loaded);
    });

    test('repository receives filter params', () async {
      await controller.setStateFilter(SudanState.khartoum);
      await controller.setCityFilter(SudanCity.omdurman);
      expect(remote.requests.last['state'], 'KHARTOUM');
      expect(remote.requests.last['city'], 'OMDURMAN');
    });
  });
}
