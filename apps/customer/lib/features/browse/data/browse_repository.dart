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

  /// [lat] and [lng] make the server fill `distance_km`.
  Future<List<Vendor>> vendors({double? lat, double? lng});
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
      items: result.items.map((e) => _product(e, icons)).toList(),
      nextPage: result.nextPage,
      total: result.total,
    );
  }

  @override
  Future<Product> product(int id) async {
    final icons = await _categoryIcons();
    return _product(await _api.get('/products/$id'), icons);
  }

  @override
  Future<List<Vendor>> vendors({double? lat, double? lng}) async {
    final data = await _api.get(
      '/vendors',
      query: {'lat': ?lat, 'lng': ?lng, 'per_page': _vendorsPageSize},
    );
    return (data as List)
        .map((e) => Vendor.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<Vendor> vendor(int id) async {
    final data = await _api.get('/vendors/$id');
    return Vendor.fromJson((data as Map).cast<String, dynamic>());
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

  Product _product(dynamic json, Map<int, String?> icons) {
    final map = (json as Map).cast<String, dynamic>();
    return Product.fromJson(map, categoryIcon: icons[map['category_id']]);
  }
}
