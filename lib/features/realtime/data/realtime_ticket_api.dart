import 'package:khamasiyat_mobile_app/core/network/api_client.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';

abstract class RealtimeTicketRemote {
  Future<RealtimeStreamTicket> issueCustomerTicket({required String pitchId});
}

class RealtimeTicketApi implements RealtimeTicketRemote {
  RealtimeTicketApi(this._client);

  final ApiClient _client;

  @override
  Future<RealtimeStreamTicket> issueCustomerTicket({required String pitchId}) {
    return _client.post(
      '/customer/realtime/tickets',
      data: {'pitchId': pitchId},
      fromJson:
          (json) => RealtimeStreamTicket.fromJson(
            Map<String, dynamic>.from(json! as Map),
          ),
    );
  }
}
