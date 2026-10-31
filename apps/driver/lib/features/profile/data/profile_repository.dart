import 'package:barq_core/barq_core.dart';

import 'driver_models.dart';

abstract class ProfileRepository {
  Future<Driver> me();
  Future<Driver> setOnline(bool online);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);

  final ApiClient _api;

  Driver _driver(dynamic data) => Driver.fromJson((data as Map).cast());

  @override
  Future<Driver> me() async => _driver(await _api.get('/driver/me'));

  @override
  Future<Driver> setOnline(bool online) async =>
      _driver(await _api.put('/driver/status', body: {'is_online': online}));
}
