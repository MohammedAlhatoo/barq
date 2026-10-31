// Calls the real sandbox. Needs a pk_test key, so it skips without one:
// flutter test test/live_browse_test.dart --dart-define-from-file=../../keys.json
import 'package:barq_core/barq_core.dart';
import 'package:barq_customer/features/auth/data/auth_repository.dart';
import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:barq_customer/features/browse/data/browse_repository.dart';
import 'package:barq_customer/features/cart/data/cart_models.dart';
import 'package:barq_customer/features/cart/data/cart_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A made-up number. In the sandbox the code is always 1234.
const _testPhone = '0590000271';
const _sandboxCode = '1234';

bool get _hasSandboxKey => BarqEnv.projectKey.startsWith('pk_test_');

void main() {
  test('browse and compare against the sandbox', () async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthStore();
    final api = ApiClient(authStore: auth, appVersion: '1.0.0');
    final authRepository = ApiAuthRepository(api, prefs);
    final browse = ApiBrowseRepository(api);
    final carts = ApiCartRepository(api);

    final ticket = await authRepository.sendOtp(
      PhoneNumber.normalize(_testPhone),
    );
    final session = await authRepository.verifyOtp(
      phone: ticket.phone,
      code: _sandboxCode,
    );
    await auth.save(session.token);

    final categories = await browse.categories();
    expect(categories, isNotEmpty);

    final first = await browse.products();
    expect(first.items, isNotEmpty);
    expect(first.nextPage, 2);
    expect(first.items.first.categoryIcon, isNotNull);

    // `page` is not in openapi.json, so this proves the server honors it.
    final second = await browse.products(page: 2);
    expect(
      second.items
          .map((p) => p.id)
          .toSet()
          .intersection(first.items.map((p) => p.id).toSet()),
      isEmpty,
    );

    final filtered = await browse.products(categoryId: categories.first.id);
    expect(filtered.items, isNotEmpty);

    final searched = await browse.products(query: 'بندورة');
    expect(searched.items.every((p) => p.name.contains('بندورة')), isTrue);

    final product = await browse.product(first.items.first.id);
    final vendor = await browse.vendor(product.vendorId!);
    expect(vendor.name, isNotEmpty);

    final byStore = await browse.products(vendorId: vendor.id);
    expect(byStore.items.every((p) => p.vendorId == vendor.id), isTrue);

    final address = await browse.defaultAddress();
    expect(address, isNotNull);
    final nearby = await browse.vendors(lat: address!.lat, lng: address.lng);
    expect(nearby.first.distanceKm, isNotNull);

    final comparison = await carts.compare(
      lines: [
        for (final item in first.items.take(2))
          CartLine(
            productId: item.id,
            name: item.name,
            imageUrl: item.imageUrl,
            categoryIcon: item.categoryIcon,
            unitPrice: item.price,
            qty: 1,
          ),
      ],
      addressId: address.id,
    );
    expect(comparison.zoneName, isNotEmpty);
    expect(comparison.stores, isNotEmpty);
    debugPrint(
      'zone=${comparison.zoneName} stores=${comparison.stores.length} '
      'best=${comparison.cheapestVendorId}',
    );
  }, skip: _hasSandboxKey ? false : 'needs a pk_test key');
}
