import 'package:url_launcher/url_launcher.dart';

/// Opens external maps / phone apps. Injectable for tests.
class ExternalActions {
  const ExternalActions();

  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent('$latitude,$longitude')}',
    );
    if (await canLaunchUrl(mapsUri)) {
      return launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  Future<bool> callPhone(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return false;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
