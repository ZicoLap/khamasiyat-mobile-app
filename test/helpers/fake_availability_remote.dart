import 'package:khamasiyat_mobile_app/features/availability/data/availability_api.dart';
import 'package:khamasiyat_mobile_app/features/availability/domain/availability_models.dart';

class FakeAvailabilityRemote implements AvailabilityRemoteSource {
  FakeAvailabilityRemote({
    this.byQuery = const {},
    this.fallback,
    this.failWith,
    this.failAfterSuccessCount,
    this.delay = Duration.zero,
  });

  Map<AvailabilityQuery, PitchAvailability> byQuery;
  PitchAvailability? fallback;
  Object? failWith;
  int? failAfterSuccessCount;
  Duration delay;
  final List<AvailabilityQuery> requests = [];
  var _successes = 0;

  @override
  Future<PitchAvailability> getAvailability(AvailabilityQuery query) async {
    requests.add(query);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final failAfter = failAfterSuccessCount;
    if (failWith != null && (failAfter == null || _successes >= failAfter)) {
      throw failWith!;
    }
    _successes++;
    return byQuery[query] ??
        fallback ??
        const PitchAvailability(currency: 'SDG', items: []);
  }
}

AvailabilitySlot sampleSlot({
  String id = 'occ1',
  String date = '2026-08-14',
  String startTime = '08:00',
  String endTime = '09:00',
  int priceSdg = 15000,
  String status = 'AVAILABLE',
}) {
  return AvailabilitySlot(
    id: id,
    date: date,
    startTime: startTime,
    endTime: endTime,
    priceSdg: priceSdg,
    currency: 'SDG',
    status: status,
  );
}

PitchAvailability sampleAvailability({
  String currency = 'SDG',
  List<AvailabilitySlot>? items,
}) {
  return PitchAvailability(
    currency: currency,
    items:
        items ??
        [
          sampleSlot(id: 'm1', startTime: '08:00', endTime: '09:00'),
          sampleSlot(id: 'm2', startTime: '10:00', endTime: '11:00'),
          sampleSlot(
            id: 'a1',
            startTime: '15:00',
            endTime: '16:00',
            priceSdg: 18000,
          ),
          sampleSlot(
            id: 'e1',
            startTime: '20:00',
            endTime: '21:30',
            priceSdg: 20000,
          ),
          sampleSlot(
            id: 'n1',
            date: '2026-08-15',
            startTime: '09:00',
            endTime: '10:00',
          ),
          sampleSlot(
            id: 'n2',
            date: '2026-08-15',
            startTime: '18:00',
            endTime: '19:00',
            priceSdg: 18000,
          ),
        ],
  );
}
