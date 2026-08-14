import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Backend `StadiumAmenity` enum (public catalog).
enum StadiumAmenity {
  parking('PARKING'),
  changingRooms('CHANGING_ROOMS'),
  toilets('TOILETS'),
  seating('SEATING'),
  cafe('CAFE'),
  prayerArea('PRAYER_AREA'),
  water('WATER'),
  firstAid('FIRST_AID');

  const StadiumAmenity(this.apiValue);

  final String apiValue;

  static StadiumAmenity? tryParse(String value) {
    for (final a in StadiumAmenity.values) {
      if (a.apiValue == value) return a;
    }
    return null;
  }
}

/// Backend `SurfaceType` enum.
enum SurfaceType {
  naturalGrass('NATURAL_GRASS'),
  artificialTurf('ARTIFICIAL_TURF'),
  futsal('FUTSAL'),
  other('OTHER');

  const SurfaceType(this.apiValue);

  final String apiValue;

  static SurfaceType fromApi(String value) {
    return SurfaceType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => SurfaceType.other,
    );
  }
}

/// Backend `StadiumPhotoType` (detail photos).
enum StadiumPhotoType {
  hero('HERO'),
  gallery('GALLERY'),
  other('OTHER');

  const StadiumPhotoType(this.apiValue);

  final String apiValue;

  static StadiumPhotoType fromApi(String value) {
    return StadiumPhotoType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => StadiumPhotoType.other,
    );
  }
}

class StadiumPhotoItem {
  const StadiumPhotoItem({
    required this.id,
    required this.url,
    required this.type,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String id;
  final String url;
  final StadiumPhotoType type;
  final int displayOrder;
  final bool isPrimary;

  factory StadiumPhotoItem.fromJson(Map<String, dynamic> json) {
    return StadiumPhotoItem(
      id: json['id'] as String,
      url: json['url'] as String,
      type: StadiumPhotoType.fromApi(json['type'] as String? ?? 'OTHER'),
      displayOrder: json['displayOrder'] as int? ?? 0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

/// ACTIVE pitch nested in stadium detail (`GET /stadiums/:id`).
class StadiumPitchSummary {
  const StadiumPitchSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.surfaceType,
    required this.isIndoor,
    required this.hasRoof,
    this.lengthMeters,
    this.widthMeters,
  });

  final String id;
  final String name;
  final PitchType type;
  final SurfaceType surfaceType;
  final bool isIndoor;
  final bool hasRoof;
  final double? lengthMeters;
  final double? widthMeters;

  factory StadiumPitchSummary.fromJson(Map<String, dynamic> json) {
    return StadiumPitchSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PitchType.fromApi(json['type'] as String),
      surfaceType: SurfaceType.fromApi(json['surfaceType'] as String),
      isIndoor: json['isIndoor'] as bool? ?? false,
      hasRoof: json['hasRoof'] as bool? ?? false,
      lengthMeters: (json['lengthMeters'] as num?)?.toDouble(),
      widthMeters: (json['widthMeters'] as num?)?.toDouble(),
    );
  }
}

/// Public stadium detail (`GET /stadiums/:id`).
class StadiumDetail {
  const StadiumDetail({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.address,
    required this.contactPhone,
    required this.amenities,
    required this.timeZone,
    required this.photos,
    required this.pitches,
    this.description,
    this.latitude,
    this.longitude,
    this.rules,
  });

  final String id;
  final String name;
  final String? description;
  final SudanState state;
  final SudanCity city;
  final String address;
  final double? latitude;
  final double? longitude;
  final String contactPhone;
  final List<StadiumAmenity> amenities;
  final String? rules;
  final String timeZone;
  final List<StadiumPhotoItem> photos;
  final List<StadiumPitchSummary> pitches;

  bool get hasCoordinates => latitude != null && longitude != null;

  List<PitchType> get availablePitchTypes {
    final seen = <PitchType>{};
    for (final p in pitches) {
      seen.add(p.type);
    }
    return seen.toList(growable: false);
  }

  factory StadiumDetail.fromJson(Map<String, dynamic> json) {
    final amenityRaw = json['amenities'] as List<dynamic>? ?? const [];
    final photosRaw = json['photos'] as List<dynamic>? ?? const [];
    final pitchesRaw = json['pitches'] as List<dynamic>? ?? const [];

    final amenities = amenityRaw
        .map((e) => StadiumAmenity.tryParse(e.toString()))
        .whereType<StadiumAmenity>()
        .toList(growable: false);

    final photos = photosRaw
        .map(
          (e) => StadiumPhotoItem.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false)
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) {
          return a.isPrimary ? -1 : 1;
        }
        return a.displayOrder.compareTo(b.displayOrder);
      });

    return StadiumDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: SudanState.fromApi(json['state'] as String),
      city: SudanCity.fromApi(json['city'] as String),
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactPhone: json['contactPhone'] as String? ?? '',
      amenities: amenities,
      rules: json['rules'] as String?,
      timeZone: json['timeZone'] as String,
      photos: photos,
      pitches: pitchesRaw
          .map(
            (e) => StadiumPitchSummary.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
