import 'dart:async';
import 'dart:io';

import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/auth_models.dart';
import 'account_models.dart';
import 'local_session.dart';

abstract class AccountRepository {
  /// Fires after the name or an address changed, so screens that are already
  /// open (Home stays alive behind the tabs) load again.
  Stream<void> get changes;

  Future<Profile> profile();
  Future<void> updateProfile({
    required String name,
    required String locale,
    int? avatarUploadId,
  });
  Future<int> uploadAvatar(File file);

  /// The default address comes first.
  Future<List<SavedAddress>> addresses();

  /// Adds a new address, or edits the one with [id].
  Future<SavedAddress> saveAddress({
    int? id,
    required String label,
    required double lat,
    required double lng,
    required String? details,
    required bool isDefault,
  });
  Future<SavedAddress> makeDefault(SavedAddress address);
  Future<void> deleteAddress(int id);

  /// Null when the count could not be loaded.
  Future<int?> ordersCount();

  /// Tells the screens that show the orders count that it changed.
  void orderPlaced();
  Future<int?> unreadNotifications();

  Future<void> logout();
  Future<void> deleteAccount();
}

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api, this._uploads, this._session);

  final ApiClient _api;
  final UploadService _uploads;
  final LocalSession _session;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<Profile> profile() async {
    final data = await _api.get('/me');
    return Profile.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String locale,
    int? avatarUploadId,
  }) async {
    await _api.put(
      '/me',
      body: {
        'name': name,
        'locale': locale,
        'avatar_upload_id': ?avatarUploadId,
      },
    );
    _changes.add(null);
  }

  @override
  Future<int> uploadAvatar(File file) =>
      _uploads.upload(file, purpose: 'avatar');

  @override
  Future<List<SavedAddress>> addresses() async {
    final data = await _api.get('/addresses') as List;
    return [
      for (final item in data)
        SavedAddress.fromJson((item as Map).cast<String, dynamic>()),
    ];
  }

  @override
  Future<SavedAddress> saveAddress({
    int? id,
    required String label,
    required double lat,
    required double lng,
    required String? details,
    required bool isDefault,
  }) async {
    final body = {
      'label': label,
      'lat': lat,
      'lng': lng,
      'details': details,
      'is_default': isDefault,
    };
    final data = id == null
        ? await _api.post('/addresses', body: body)
        : await _api.put('/addresses/$id', body: body);
    _changes.add(null);
    return SavedAddress.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<SavedAddress> makeDefault(SavedAddress address) => saveAddress(
    id: address.id,
    label: address.label ?? '',
    lat: address.lat,
    lng: address.lng,
    details: address.details,
    isDefault: true,
  );

  @override
  Future<void> deleteAddress(int id) async {
    await _api.delete('/addresses/$id');
    _changes.add(null);
  }

  @override
  Future<int?> ordersCount() => _total('/orders', const {'per_page': 1});

  @override
  void orderPlaced() => _changes.add(null);

  @override
  Future<int?> unreadNotifications() =>
      _total('/notifications', const {'unread': 1, 'per_page': 1});

  /// One row is enough: the count is in `meta.total`. These numbers decorate
  /// the screen, so a failure hides them instead of failing it.
  Future<int?> _total(String path, Map<String, dynamic> query) async {
    try {
      return (await _api.getPaged(path, query: query)).total;
    } on ApiException catch (e) {
      debugPrint('No count for $path: ${e.code}');
      return null;
    }
  }

  /// The phone stops receiving this user's notifications first, while the
  /// token still works. A 401 means the session is already over.
  @override
  Future<void> logout() async {
    try {
      await _api.put('/me/fcm-token', body: {'token': null});
    } on ApiException catch (e) {
      debugPrint('FCM token not removed: ${e.code}');
    }
    try {
      await _api.post('/auth/logout');
    } on ApiException catch (e) {
      if (e.status != 401) rethrow;
    }
    await _session.end();
  }

  @override
  Future<void> deleteAccount() async {
    await _api.delete('/me');
    await _session.end();
  }
}
