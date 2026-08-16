import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Photo on public pitch detail (`GET /pitches/:id`).
class PitchPhotoItem {
  const PitchPhotoItem({
    required this.id,
    required this.url,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String id;
  final String url;
  final int displayOrder;
  final bool isPrimary;

  factory PitchPhotoItem.fromJson(Map<String, dynamic> json) {
    return PitchPhotoItem(
      id: json['id'] as String,
      url: json['url'] as String,
      displayOrder: json['displayOrder'] as int? ?? 0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class PitchStadiumSummary {
  const PitchStadiumSummary({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.timeZone,
  });

  final String id;
  final String name;
  final SudanState state;
  final SudanCity city;
  final String timeZone;

  factory PitchStadiumSummary.fromJson(Map<String, dynamic> json) {
    return PitchStadiumSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      state: SudanState.fromApi(json['state'] as String),
      city: SudanCity.fromApi(json['city'] as String),
      timeZone: json['timeZone'] as String,
    );
  }
}

/// Public pitch detail (`GET /pitches/:id`).
class PitchDetail {
  const PitchDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.surfaceType,
    required this.isIndoor,
    required this.hasRoof,
    required this.photos,
    required this.stadium,
    this.lengthMeters,
    this.widthMeters,
    this.description,
  });

  final String id;
  final String name;
  final PitchType type;
  final SurfaceType surfaceType;
  final bool isIndoor;
  final bool hasRoof;
  final double? lengthMeters;
  final double? widthMeters;
  final String? description;
  final List<PitchPhotoItem> photos;
  final PitchStadiumSummary stadium;

  factory PitchDetail.fromJson(Map<String, dynamic> json) {
    final photosRaw = json['photos'] as List<dynamic>? ?? const [];
    final photos = photosRaw
      .map((e) => PitchPhotoItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(growable: false)..sort((a, b) {
      if (a.isPrimary != b.isPrimary) {
        return a.isPrimary ? -1 : 1;
      }
      return a.displayOrder.compareTo(b.displayOrder);
    });

    return PitchDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PitchType.fromApi(json['type'] as String),
      surfaceType: SurfaceType.fromApi(json['surfaceType'] as String),
      isIndoor: json['isIndoor'] as bool? ?? false,
      hasRoof: json['hasRoof'] as bool? ?? false,
      lengthMeters: (json['lengthMeters'] as num?)?.toDouble(),
      widthMeters: (json['widthMeters'] as num?)?.toDouble(),
      description: json['description'] as String?,
      photos: photos,
      stadium: PitchStadiumSummary.fromJson(
        Map<String, dynamic>.from(json['stadium'] as Map),
      ),
    );
  }
}
