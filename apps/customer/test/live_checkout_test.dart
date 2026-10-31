// Creates real orders on the sandbox, and cancels them. Needs a pk_test key, so
// it skips without one:
// flutter test test/live_checkout_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/account/data/account_repository.dart';
import 'package:barq_customer/features/account/data/local_session.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/cart/data/cart_models.dart';
import 'package:barq_customer/features/cart/state/cart_cubit.dart';
import 'package:barq_customer/features/checkout/data/checkout_models.dart';
import 'package:barq_customer/features/checkout/data/checkout_repository.dart';
import 'package:barq_customer/features/offer/data/offer_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000473';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test(
    'order, retry, offer and reject against the sandbox',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthStore();
      final api = ApiClient(authStore: auth, appVersion: '1.0.0');
      final authRepository = ApiAuthRepository(api, prefs);
      final browse = ApiBrowseRepository(api);
      final checkout = ApiCheckoutRepository(api);
      final offers = ApiOfferRepository(api);
      final account = ApiAccountRepository(
        api,
        UploadService(api: api),
        LocalSession(
          auth: auth,
          cart: CartCubit(
            prefs: prefs,
            config: ConfigStore(api: api, app: BarqAppKind.customer),
            browse: browse,
          ),
          prefs: prefs,
        ),
      );

      final ticket = await authRepository.sendOtp(
        PhoneNumber.normalize(_testPhone),
      );
      final session = await authRepository.verifyOtp(
        phone: ticket.phone,
        code: _sandboxCode,
      );
      await auth.save(session.token);

      final address =
          await browse.defaultAddress() ??
          await account.saveAddress(
            label: 'البيت',
            lat: 31.45,
            lng: 34.39,
            details: 'تجربة',
            isDefault: true,
          );

      final vendors = await browse.vendors(lat: 31.45, lng: 34.39);
      final vendor = vendors.firstWhere((v) => v.isOpen);
      final product = (await browse.products(vendorId: vendor.id)).items.first;
      final cart = Cart(
        vendorId: vendor.id,
        lines: [
          CartLine(
            productId: product.id,
            name: product.name,
            imageUrl: null,
            categoryIcon: null,
            unitPrice: product.price,
            qty: 1,
          ),
        ],
      );

      final quote = await checkout.quote(
        cart: cart,
        addressId: address.id,
        substitution: Substitution.similar,
      );
      expect(quote.expiresIn, greaterThan(0));
      expect(quote.breakdown, isNotEmpty);

      final key = newIdempotencyKey();
      final id = await checkout.placeOrder(
        quoteToken: quote.token,
        note: 'تجربة من الاختبار',
        substitution: Substitution.similar,
        idempotencyKey: key,
      );
      final again = await checkout.placeOrder(
        quoteToken: quote.token,
        note: 'تجربة من الاختبار',
        substitution: Substitution.similar,
        idempotencyKey: key,
      );
      expect(again, id);

      expect(await offers.offer(id), isNull);
      await offers.advanceInSandbox(id);
      final offer = (await offers.offer(id))!;
      expect(offer.isOpen, isTrue);
      expect(offer.minutesToAnswer, greaterThan(0));
      expect((await offers.order(id)).cancelAction, isNotNull);

      await offers.reject(id);
      final closed = await offers.order(id);
      expect(closed.isTerminal, isTrue);
      expect((await offers.offer(id))!.status, 'rejected');
    },
    skip: _hasSandboxKey ? false : 'needs a pk_test key',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
