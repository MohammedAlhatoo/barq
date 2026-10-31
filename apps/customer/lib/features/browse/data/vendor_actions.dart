import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// What the store page asks the phone to do. Behind a class so tests can
/// replace it, like LocationRepository.
abstract class VendorActions {
  Future<void> share(String text);

  /// False when the phone can't place the call.
  Future<bool> call(String phone);
}

class DeviceVendorActions implements VendorActions {
  @override
  Future<void> share(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Future<bool> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));
}
