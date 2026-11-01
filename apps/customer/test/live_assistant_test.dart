// Calls the real sandbox. Needs a pk_test key, so it skips without one:
// flutter test test/live_assistant_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/assistant/state/assistant_cubit.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:barq_customer/features/auth/data/location_repository.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/browse/data/user_location.dart';
import 'package:barq_customer/features/browse/state/search_cubit.dart';
import 'package:barq_customer/features/cart/data/cart_repository.dart';
import 'package:barq_customer/features/cart/state/cart_cubit.dart';
import 'package:barq_customer/features/cart/state/shop_scope_cubit.dart';
import 'package:barq_customer/features/orders/data/orders_repository.dart';
import 'package:barq_customer/l10n/generated/app_localizations.dart';
import 'package:barq_customer/l10n/generated/app_localizations_ar.dart';
import 'package:barq_customer/l10n/generated/app_localizations_en.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000271';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test(
    'the normal search finds other spellings on the sandbox',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final api = ApiClient(authStore: AuthStore(), appVersion: '1.0.0');
      final browse = ApiBrowseRepository(api);
      final config = ConfigStore(api: api, app: BarqAppKind.customer);
      final cart = CartCubit(prefs: prefs, config: config, browse: browse);
      final cubit = SearchCubit(
        browse,
        prefs,
        UserLocation(browse, GeolocatorLocationRepository()),
        ShopScopeCubit(cart: cart, browse: browse),
      );
      for (final word in const [
        'بندوره',
        'البندورة',
        'ارز',
        'cucumbers',
        'مكرونة',
        'مكرونه',
        'معكرونه',
        'باستا',
        'pasta',
        'بطاطس',
        'طماطم',
        'لحم',
        'لحوم',
        'لحم مفروم',
      ]) {
        await cubit.search(word);
        debugPrint('$word → ${cubit.state.total} results');
        expect(cubit.state.items, isNotEmpty, reason: word);
      }
      // `q` stays the spelling that worked, or page 2 would be empty.
      await cubit.search('cucumbers');
      expect(cubit.state.total, greaterThan(20));
      expect(cubit.state.nextPage, 2);
      await cubit.loadMore();
      expect(cubit.state.items.length, cubit.state.total);
    },
    skip: _hasSandboxKey ? false : 'needs a pk_test key',
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'a list reaches the stores on the sandbox',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthStore();
      final api = ApiClient(authStore: auth, appVersion: '1.0.0');
      final authRepository = ApiAuthRepository(api, prefs);
      final ticket = await authRepository.sendOtp(
        PhoneNumber.normalize(_testPhone),
      );
      final session = await authRepository.verifyOtp(
        phone: ticket.phone,
        code: _sandboxCode,
      );
      await auth.save(session.token);

      final browse = ApiBrowseRepository(api);
      final cart = CartCubit(
        prefs: prefs,
        config: ConfigStore(api: api, app: BarqAppKind.customer),
        browse: browse,
      );
      AssistantCubit assistant() => AssistantCubit(
        browse: browse,
        carts: ApiCartRepository(api),
        orders: ApiOrdersRepository(api),
        cart: cart,
      );

      // Every preset chip, in the language it is written for: one of each
      // product, and a store that sells them all.
      for (final (language, l10n) in <(String, AppLocalizations)>[
        ('ar', AppLocalizationsAr()),
        ('en', AppLocalizationsEn()),
      ]) {
        final localApi = ApiClient(
          authStore: auth,
          appVersion: '1.0.0',
          language: () => language,
        );
        final localBrowse = ApiBrowseRepository(localApi);
        for (final preset in [
          l10n.assistantListVegetables,
          l10n.assistantListBreakfast,
          l10n.assistantListCooking,
        ]) {
          final cubit = AssistantCubit(
            browse: localBrowse,
            carts: ApiCartRepository(localApi),
            orders: ApiOrdersRepository(localApi),
            cart: cart,
          );
          await cubit.send(preset);
          final found = cubit.state.messages.last as MatchesMessage;
          debugPrint(
            found.items
                .map((i) => '${i.item.name} → ${i.product?.name} × ${i.qty}')
                .join(' | '),
          );
          expect(found.items.every((i) => i.product != null), isTrue);
          expect(found.items.every((i) => i.qty == 1), isTrue, reason: preset);

          await cubit.compareStores();
          final stores = cubit.state.messages.last as StoresMessage;
          expect(stores.options.any((o) => o.store.complete), isTrue);
        }
      }

      // The spellings the server misses, then English and mixed lists, with the
      // quantities they must end up with.
      const lists = {
        'كيلو بندوره وكيلو رز ونص كيلو البطاطا': [1, 1, 1],
        'باكيت باستا وكيلو لحم مفروم وكيلو طماطم وكيلو بطاطس': [1, 1, 1, 1],
        'كيلو مكرونة وكيلو لحمه': [2, 1],
        '1 kg tomatoes, 2 kg cucumbers and 1 liter milk': [1, 2, 1],
        'كيلو لبنة and a dozen eggs': [2, 1],
        'half a kilo of potatoes و 2 kg rice': [1, 2],
      };
      for (final MapEntry(key: list, value: quantities) in lists.entries) {
        final cubit = assistant();
        await cubit.send(list);
        final found = cubit.state.messages.last as MatchesMessage;
        expect(found.items.map((item) => item.qty), quantities, reason: list);
        debugPrint(
          found.items
              .map((i) => '${i.item.name} → ${i.product?.name} × ${i.qty}')
              .join(' | '),
        );
        expect(found.items.every((item) => item.product != null), isTrue);

        await cubit.compareStores();
        final stores = cubit.state.messages.last as StoresMessage;
        expect(stores.options, isNotEmpty);
        for (final option in stores.options) {
          debugPrint(
            '${option.store.vendorName} '
            'total=${option.total?.formatted} km=${option.distanceKm} '
            'complete=${option.store.complete}',
          );
        }
        final totals = stores.options
            .map((o) => o.total?.amount)
            .nonNulls
            .toList();
        expect(totals, [...totals]..sort());

        cubit.fillCart();
        expect(cart.state.vendorId, stores.selected.store.vendorId);
        expect(
          cart.state.lines.map((line) => line.productId),
          stores.selected.store.lines.map((line) => line.storeProductId),
        );
      }
    },
    skip: _hasSandboxKey ? false : 'needs a pk_test key',
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
