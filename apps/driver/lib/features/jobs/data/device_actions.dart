import 'package:url_launcher/url_launcher.dart';

/// Things another app does for us: the phone dialer and the maps app.
abstract class DeviceActions {
  Future<void> call(String phone);
  Future<void> navigate(double lat, double lng);
}

class UrlDeviceActions implements DeviceActions {
  @override
  Future<void> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));

  /// Google Maps when installed, otherwise its web page.
  @override
  Future<void> navigate(double lat, double lng) async {
    final app = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(app)) {
      await launchUrl(app);
      return;
    }
    await launchUrl(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
      mode: LaunchMode.externalApplication,
    );
  }
}
