// Follows a real order on the sandbox, and cancels it. Needs a pk_test key, so
// it skips without one:
// flutter test test/live_orders_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/cart/data/cart_models.dart';
import 'package:barq_customer/features/checkout/data/checkout_models.dart';
import 'package:barq_customer/features/checkout/data/checkout_repository.dart';
import 'package:barq_customer/features/offer/data/offer_repository.dart';
import 'package:barq_customer/features/orders/data/orders_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000473';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test(
    'order, events, tracking, offer approval, lists and cancel',
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
      final orders = ApiOrdersRepository(api);

      final ticket = await authRepository.sendOtp(
        PhoneNumber.normalize(_testPhone),
      );
      final session = await authRepository.verifyOtp(
        phone: ticket.phone,
        code: _sandboxCode,
      );
      await auth.save(session.token);

      final address = (await browse.defaultAddress())!;
      final vendors = await browse.vendors(lat: address.lat, lng: address.lng);
      final vendor = vendors.firstWhere((v) => v.isOpen);
      final product = (await browse.products(vendorId: vendor.id)).items.first;
      final quote = await checkout.quote(
        cart: Cart(
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
        ),
        addressId: address.id,
        substitution: Substitution.similar,
      );
      final id = await checkout.placeOrder(
        quoteToken: quote.token,
        note: '',
        substitution: Substitution.similar,
        idempotencyKey: newIdempotencyKey(),
      );

      final order = await orders.order(id);
      expect(order.action('cancel'), isNotNull);
      final first = await orders.events(id, since: 0);
      expect(first.hasNews, isTrue);
      expect(first.nextSince, greaterThan(0));
      expect(
        (await orders.events(id, since: first.nextSince)).hasNews,
        isFalse,
      );

      final tracking = await orders.tracking(id);
      expect(tracking.nextPollSeconds, greaterThanOrEqualTo(Poller.minSeconds));
      final active = await orders.orders(scope: 'active');
      expect(active.items.map((o) => o.id), contains(id));
      expect((await orders.cancelReasons()), isNotEmpty);
      expect((await orders.receipt(id)).lines, isNotEmpty);
      await orders.unreadNotifications();
      await orders.notifications();

      final link = await orders.createShareLink(id);
      expect(link.url, startsWith('https://'));
      await orders.stopShareLink(id);

      await offers.advanceInSandbox(id);
      final offer = (await offers.offer(id))!;
      await offers.approve(
        id,
        offerId: offer.id,
        idempotencyKey: newIdempotencyKey(),
      );
      final approved = await orders.order(id);
      expect(approved.isTerminal, isFalse);
      expect(approved.statusKey, isNot(order.statusKey));

      await orders.cancel(id, reason: 'changed_mind');
      expect((await orders.order(id)).isTerminal, isTrue);
      final cancelled = await orders.orders(scope: 'cancelled');
      expect(cancelled.items.map((o) => o.id), contains(id));
    },
    skip: _hasSandboxKey ? false : 'needs a pk_test key',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
