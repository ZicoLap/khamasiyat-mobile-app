import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

class StadiumPrimaryPhoto {
  const StadiumPrimaryPhoto({
    required this.url,
    required this.type,
  });

  final String url;
  final String type;

  factory StadiumPrimaryPhoto.fromJson(Map<String, dynamic> json) {
    return StadiumPrimaryPhoto(
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }
}

/// Public stadium list item (`GET /stadiums` item).
class StadiumListItem {
  const StadiumListItem({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.address,
    required this.amenities,
    required this.timeZone,
    required this.activePitchCount,
    this.description,
    this.latitude,
    this.longitude,
    this.primaryPhoto,
  });

  final String id;
  final String name;
  final String? description;
  final SudanState state;
  final SudanCity city;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> amenities;
  final String timeZone;
  final StadiumPrimaryPhoto? primaryPhoto;
  final int activePitchCount;

  factory StadiumListItem.fromJson(Map<String, dynamic> json) {
    final photoRaw = json['primaryPhoto'];
    return StadiumListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: SudanState.fromApi(json['state'] as String),
      city: SudanCity.fromApi(json['city'] as String),
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      timeZone: json['timeZone'] as String,
      primaryPhoto: photoRaw is Map
          ? StadiumPrimaryPhoto.fromJson(Map<String, dynamic>.from(photoRaw))
          : null,
      activePitchCount: json['activePitchCount'] as int? ?? 0,
    );
  }
}

class StadiumListPage {
  const StadiumListPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<StadiumListItem> items;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;

  factory StadiumListPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return StadiumListPage(
      items: rawItems
          .map(
            (e) => StadiumListItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
    );
  }
}

class CatalogFilters {
  const CatalogFilters({
    this.state,
    this.city,
    this.pitchType,
  });

  final SudanState? state;
  final SudanCity? city;
  final PitchType? pitchType;

  static const empty = CatalogFilters();

  bool get hasAny => state != null || city != null || pitchType != null;

  CatalogFilters copyWith({
    SudanState? state,
    SudanCity? city,
    PitchType? pitchType,
    bool clearState = false,
    bool clearCity = false,
    bool clearPitchType = false,
  }) {
    return CatalogFilters(
      state: clearState ? null : (state ?? this.state),
      city: clearCity ? null : (city ?? this.city),
      pitchType: clearPitchType ? null : (pitchType ?? this.pitchType),
    );
  }

  /// When state changes, drop city if it no longer belongs to that state.
  CatalogFilters withState(SudanState? nextState) {
    if (nextState == null) {
      return copyWith(clearState: true, clearCity: true);
    }
    final keepCity =
        city != null && SudanLocations.isCityInState(nextState, city!);
    return CatalogFilters(
      state: nextState,
      city: keepCity ? city : null,
      pitchType: pitchType,
    );
  }

  Map<String, dynamic> toQueryParameters({
    required int page,
    required int limit,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (state != null) 'state': state!.apiValue,
      if (city != null) 'city': city!.apiValue,
      if (pitchType != null) 'pitchType': pitchType!.apiValue,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogFilters &&
        other.state == state &&
        other.city == city &&
        other.pitchType == pitchType;
  }

  @override
  int get hashCode => Object.hash(state, city, pitchType);
}
