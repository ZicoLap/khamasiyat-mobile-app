import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_api.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

class FakeCatalogRemote implements CatalogRemoteSource {
  FakeCatalogRemote({
    this.pages = const {},
    this.stadiumById = const {},
    this.failWith,
    this.failDetailWith,
    this.delay = Duration.zero,
  });

  /// page number → response
  Map<int, StadiumListPage> pages;

  /// stadiumId → detail
  Map<String, StadiumDetail> stadiumById;

  Object? failWith;
  Object? failDetailWith;
  Duration delay;
  final List<Map<String, dynamic>> requests = [];
  final List<String> detailRequests = [];
  var inFlight = 0;

  @override
  Future<StadiumListPage> listStadiums({
    required CatalogFilters filters,
    required int page,
    required int limit,
  }) async {
    inFlight += 1;
    requests.add({
      'page': page,
      'limit': limit,
      'state': filters.state?.apiValue,
      'city': filters.city?.apiValue,
      'pitchType': filters.pitchType?.apiValue,
    });
    try {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      if (failWith != null) {
        throw failWith!;
      }
      return pages[page] ??
          StadiumListPage(items: const [], total: 0, page: page, limit: limit);
    } finally {
      inFlight -= 1;
    }
  }

  @override
  Future<StadiumDetail> getStadium(String stadiumId) async {
    detailRequests.add(stadiumId);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failDetailWith != null) {
      throw failDetailWith!;
    }
    final detail = stadiumById[stadiumId];
    if (detail == null) {
      throw Exception('Stadium not found: $stadiumId');
    }
    return detail;
  }
}

/// Fixture stadium for tests / visual review.
/// Prefer real `photoUrl` values from the API in app runtime; fixtures only.
StadiumListItem sampleStadium({
  String id = 's1',
  String name = 'Nile Arena',
  SudanState state = SudanState.khartoum,
  SudanCity city = SudanCity.omdurman,
  String? photoUrl,
  int activePitchCount = 2,
}) {
  return StadiumListItem(
    id: id,
    name: name,
    state: state,
    city: city,
    address: 'Street 1',
    amenities: const ['PARKING'],
    timeZone: 'Africa/Khartoum',
    activePitchCount: activePitchCount,
    primaryPhoto: photoUrl == null
        ? null
        : StadiumPrimaryPhoto(url: photoUrl, type: 'HERO'),
  );
}

StadiumDetail sampleStadiumDetail({
  String id = 's1',
  String name = 'Al-Nile Stadium',
  String? description =
      'Al-Nile Stadium is a premium football venue with high-quality artificial turf, perfect for friendly matches, training sessions, and tournaments.',
  String? rules,
  List<String>? photoUrls,
  List<StadiumPitchSummary>? pitches,
  List<StadiumAmenity> amenities = const [
    StadiumAmenity.parking,
    StadiumAmenity.toilets,
    StadiumAmenity.changingRooms,
  ],
  double? latitude = 15.5007,
  double? longitude = 32.5599,
  String contactPhone = '+249123456789',
  SudanCity city = SudanCity.khartoumCity,
  SudanState state = SudanState.khartoum,
  String address = 'Nile Avenue, Khartoum',
}) {
  final urls = photoUrls;
  return StadiumDetail(
    id: id,
    name: name,
    description: description,
    state: state,
    city: city,
    address: address,
    latitude: latitude,
    longitude: longitude,
    contactPhone: contactPhone,
    amenities: amenities,
    rules: rules,
    timeZone: 'Africa/Khartoum',
    photos: [
      for (var i = 0; i < (urls?.length ?? 0); i++)
        StadiumPhotoItem(
          id: 'ph$i',
          url: urls![i],
          type: i == 0 ? StadiumPhotoType.hero : StadiumPhotoType.gallery,
          displayOrder: i,
          isPrimary: i == 0,
        ),
    ],
    pitches: pitches ??
        [
          const StadiumPitchSummary(
            id: 'p1',
            name: 'Pitch A',
            type: PitchType.fiveASide,
            surfaceType: SurfaceType.artificialTurf,
            isIndoor: false,
            hasRoof: false,
            lengthMeters: 40,
            widthMeters: 20,
          ),
          const StadiumPitchSummary(
            id: 'p2',
            name: 'Pitch B',
            type: PitchType.sevenASide,
            surfaceType: SurfaceType.artificialTurf,
            isIndoor: false,
            hasRoof: true,
            lengthMeters: 50,
            widthMeters: 30,
          ),
        ],
  );
}
