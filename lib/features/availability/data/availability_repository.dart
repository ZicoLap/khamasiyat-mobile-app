import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/availability/data/availability_api.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._remote);

  final AvailabilityRemoteSource _remote;

  Future<PitchAvailability> getAvailability(AvailabilityQuery query) {
    return _remote.getAvailability(query);
  }
}

final availabilityApiProvider = Provider<AvailabilityApi>((ref) {
  return AvailabilityApi(ref.watch(apiClientProvider));
});

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.watch(availabilityApiProvider));
});
