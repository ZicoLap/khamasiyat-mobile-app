import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khamasiyat_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_detail_models.dart';

/// Loads public stadium detail for `/stadiums/:stadiumId`.
final stadiumDetailProvider = AsyncNotifierProvider.autoDispose
    .family<StadiumDetailNotifier, StadiumDetail, String>(
  StadiumDetailNotifier.new,
);

class StadiumDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<StadiumDetail, String> {
  @override
  Future<StadiumDetail> build(String stadiumId) {
    return ref.read(catalogRepositoryProvider).getStadium(stadiumId);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catalogRepositoryProvider).getStadium(arg),
    );
  }
}
