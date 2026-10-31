// Calls the real sandbox. Needs a pk_test key, so it skips without one:
// flutter test test/live_auth_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000271';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test('login, name and address against the sandbox', () async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthStore();
    final api = ApiClient(authStore: auth, appVersion: '1.0.0');
    final repository = ApiAuthRepository(api, prefs);

    final ticket = await repository.sendOtp(PhoneNumber.normalize(_testPhone));
    expect(ticket.length, 4);
    expect(ticket.expiresIn, greaterThan(0));
    // Shows the wait the OTP screen uses, without printing anything secret.
    debugPrint('expires_in=${ticket.expiresIn} phone=${ticket.phone}');

    final session = await repository.verifyOtp(
      phone: ticket.phone,
      code: _sandboxCode,
    );
    await auth.save(session.token);
    debugPrint('needsProfile=${session.needsProfile}');

    await repository.updateProfile(name: 'تجربة برق', locale: 'ar');
    expect(await repository.currentName(), 'تجربة برق');

    try {
      final address = await repository.addAddress(
        label: 'موقعي',
        lat: 31.4500,
        lng: 34.3900,
      );
      debugPrint('address saved id=${address.id} label=${address.label}');
    } on ApiException catch (e) {
      debugPrint('address refused: ${e.status} ${e.code}');
      expect(e.code, 'out_of_zone');
    }
  }, skip: _hasSandboxKey ? false : 'needs a pk_test key');
}
