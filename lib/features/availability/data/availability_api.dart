import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';

abstract class AvailabilityRemoteSource {
  Future<PitchAvailability> getAvailability(AvailabilityQuery query);
}

class AvailabilityApi implements AvailabilityRemoteSource {
  AvailabilityApi(this._client);

  final ApiClient _client;

  @override
  Future<PitchAvailability> getAvailability(AvailabilityQuery query) {
    return _client.get(
      '/pitches/${query.pitchId}/availability',
      queryParameters: {'from': query.from, 'to': query.to},
      fromJson:
          (json) => PitchAvailability.fromJson(
            Map<String, dynamic>.from(json! as Map),
          ),
    );
  }
}
