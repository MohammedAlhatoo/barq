import 'package:barq_core/barq_core.dart';

import '../../auth/data/auth_models.dart';
import 'browse_models.dart';

abstract class BrowseRepository {
  Future<List<Category>> categories({int? vendorId});
  Future<Paged<Product>> products({
    int? categoryId,
    int? vendorId,
    String? query,
    int page = 1,
  });
  Future<Product> product(int id);

  /// [lat] and [lng] make the server fill `distance_km` and put the nearest
  /// first, after the open stores.
  Future<List<Vendor>> vendors({double? lat, double? lng});

  /// One page of the stores list. [openNow] keeps only the open stores.
  Future<Paged<Vendor>> vendorsPage({
    double? lat,
    double? lng,
    bool openNow = false,
    int page = 1,
    int perPage,
  });
  Future<Vendor> vendor(int id);

  /// The user's default address, or null if they have none.
  Future<SavedAddress?> defaultAddress();
  Future<String?> currentName();
}

class ApiBrowseRepository implements BrowseRepository {
  ApiBrowseRepository(this._api);

  static const _pageSize = 20;

  // The server's maximum. All stores fit in one page today (24).
  static const _vendorsPageSize = 50;

  final ApiClient _api;

  /// Category id → icon, so products can show a matching picture.
  Map<int, String?>? _icons;

  /// Vendor id → name, so tiles can show who sells each product.
  Map<int, String>? _vendorNames;

  /// `GET /vendors/{id}` has no distance, so the last list's value is kept.
  final Map<int, double> _distances = {};

  @override
  Future<List<Category>> categories({int? vendorId}) async {
    final data = await _api.get('/categories', query: {'vendor': ?vendorId});
    final categories = (data as List)
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    if (vendorId == null) {
      _icons = {for (final category in categories) category.id: category.icon};
    }
    return categories;
  }

  @override
  Future<Paged<Product>> products({
    int? categoryId,
    int? vendorId,
    String? query,
    int page = 1,
  }) async {
    final icons = await _categoryIcons();
    final names = await _namesOfVendors();
    final result = await _api.getPaged(
      '/products',
      query: {
        'category': ?categoryId,
        'vendor': ?vendorId,
        'q': ?query,
        'per_page': _pageSize,
        'page': page,
      },
    );
    return Paged(
      items: result.items.map((e) => _product(e, icons, names)).toList(),
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<Product> product(int id) async {
    final icons = await _categoryIcons();
    final names = await _namesOfVendors();
    return _product(await _api.get('/products/$id'), icons, names);
  }

  @override
  Future<List<Vendor>> vendors({double? lat, double? lng}) async {
    final page = await vendorsPage(
      lat: lat,
      lng: lng,
      perPage: _vendorsPageSize,
    );
    return page.items;
  }

  @override
  Future<Paged<Vendor>> vendorsPage({
    double? lat,
    double? lng,
    bool openNow = false,
    int page = 1,
    int perPage = _pageSize,
  }) async {
    final result = await _api.getPaged(
      '/vendors',
      query: {
        'lat': ?lat,
        'lng': ?lng,
        // The server refuses `true` here: 422 unless it is 1.
        if (openNow) 'open_now': 1,
        'per_page': perPage,
        'page': page,
      },
    );
    final vendors = result.items
        .map((e) => Vendor.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    _vendorNames = {
      ...?_vendorNames,
      for (final vendor in vendors) vendor.id: vendor.name,
    };
    for (final vendor in vendors) {
      final km = vendor.distanceKm;
      if (km != null) _distances[vendor.id] = km;
    }
    return Paged(
      items: vendors,
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<Vendor> vendor(int id) async {
    final data = await _api.get('/vendors/$id');
    return Vendor.fromJson(
      (data as Map).cast<String, dynamic>(),
      knownDistance: _distances[id],
    );
  }

  @override
  Future<SavedAddress?> defaultAddress() async {
    final data = await _api.get('/addresses') as List;
    if (data.isEmpty) return null;
    return SavedAddress.fromJson((data.first as Map).cast<String, dynamic>());
  }

  @override
  Future<String?> currentName() async {
    final data = await _api.get('/me');
    return (data as Map)['name'] as String?;
  }

  /// Pictures are a nicety: products still load if categories fail.
  Future<Map<int, String?>> _categoryIcons() async {
    final known = _icons;
    if (known != null) return known;
    try {
      await categories();
    } on ApiException {
      return const {};
    }
    return _icons ?? const {};
  }

  /// Like the pictures: products still load without the store names.
  Future<Map<int, String>> _namesOfVendors() async {
    final known = _vendorNames;
    if (known != null) return known;
    try {
      await vendors();
    } on ApiException {
      return const {};
    }
    return _vendorNames ?? const {};
  }

  Product _product(
    dynamic json,
    Map<int, String?> icons,
    Map<int, String> names,
  ) {
    final map = (json as Map).cast<String, dynamic>();
    return Product.fromJson(
      map,
      categoryIcon: icons[map['category_id']],
      vendorName: names[map['vendor_id']],
    );
  }
}
