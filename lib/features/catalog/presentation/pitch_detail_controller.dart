import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/pitch_detail_models.dart';

final pitchDetailProvider = AsyncNotifierProvider.autoDispose
    .family<PitchDetailNotifier, PitchDetail, String>(PitchDetailNotifier.new);

class PitchDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<PitchDetail, String> {
  @override
  Future<PitchDetail> build(String pitchId) {
    return ref.read(catalogRepositoryProvider).getPitch(pitchId);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catalogRepositoryProvider).getPitch(arg),
    );
  }
}
