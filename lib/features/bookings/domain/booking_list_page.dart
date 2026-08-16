import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';

/// Paginated `GET /bookings` payload: `{ items, total, page, limit }`.
class CustomerBookingListPage {
  const CustomerBookingListPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<CustomerBooking> items;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;

  factory CustomerBookingListPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return CustomerBookingListPage(
      items: rawItems
          .map(
            (e) =>
                CustomerBooking.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );
  }
}
