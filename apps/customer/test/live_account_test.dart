// Calls the real sandbox. Needs a pk_test key, so it skips without one:
// flutter test test/live_account_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/account/data/account_repository.dart';
import 'package:barq_customer/features/account/data/local_session.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/cart/state/cart_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000472';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test('the real currency config formats a saving', () async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final api = ApiClient(authStore: AuthStore(), appVersion: '1.0.0');
    final store = ConfigStore(api: api, app: BarqAppKind.customer);
    await store.load();

    const cart = Money(amount: 2650, formatted: '26.50 ₪');
    const cheaper = Money(amount: 2250, formatted: '22.50 ₪');
    final saved = cheaper.savedAgainst(
      cart,
      symbol: store.config.currencySymbol,
      minorUnits: store.config.currencyMinorUnits,
    );
    expect(store.config.currencyMinorUnits, 100);
    expect(saved.formatted, '4.00 ${store.config.currencySymbol}');
  }, skip: _hasSandboxKey ? false : 'needs a pk_test key');

  test(
    'profile and addresses against the sandbox',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthStore();
      final api = ApiClient(authStore: auth, appVersion: '1.0.0');
      final authRepository = ApiAuthRepository(api, prefs);
      final config = ConfigStore(api: api, app: BarqAppKind.customer);
      final cart = CartCubit(
        prefs: prefs,
        config: config,
        browse: ApiBrowseRepository(api),
      );
      final account = ApiAccountRepository(
        api,
        UploadService(api: api),
        LocalSession(auth: auth, cart: cart, prefs: prefs),
      );

      final ticket = await authRepository.sendOtp(
        PhoneNumber.normalize(_testPhone),
      );
      final session = await authRepository.verifyOtp(
        phone: ticket.phone,
        code: _sandboxCode,
      );
      await auth.save(session.token);

      await account.updateProfile(name: 'حساب تجربة', locale: 'ar');
      expect((await account.profile()).name, 'حساب تجربة');

      for (final old in await account.addresses()) {
        await account.deleteAddress(old.id);
      }

      final first = await account.saveAddress(
        label: 'البيت',
        lat: 31.45,
        lng: 34.39,
        details: 'تفاصيل أولى',
        isDefault: true,
      );
      final second = await account.saveAddress(
        label: 'العمل',
        lat: 31.45,
        lng: 34.39,
        details: null,
        isDefault: false,
      );
      var list = await account.addresses();
      debugPrint('Default first: ${list.map((a) => a.isDefault).toList()}');
      expect(list.first.id, first.id);

      await account.makeDefault(second);
      list = await account.addresses();
      expect(list.first.id, second.id);
      expect(list.where((address) => address.isDefault), hasLength(1));
      expect(
        list.firstWhere((address) => address.id == first.id).details,
        'تفاصيل أولى',
      );

      await expectLater(
        account.saveAddress(
          label: 'بعيد',
          lat: 10,
          lng: 10,
          details: null,
          isDefault: false,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'out_of_zone'),
        ),
      );

      debugPrint('Orders: ${await account.ordersCount()}');
      debugPrint('Unread: ${await account.unreadNotifications()}');

      await account.deleteAddress(second.id);
      list = await account.addresses();
      debugPrint('After deleting the default: ${list.map((a) => a.isDefault)}');
      await account.deleteAddress(first.id);

      await account.logout();
      expect(auth.isLoggedIn, isFalse);
    },
    skip: _hasSandboxKey ? false : 'needs a pk_test key',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
