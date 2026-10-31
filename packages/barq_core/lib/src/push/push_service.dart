import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/barq_env.dart';
import 'push_message.dart';

/// FCM notifications. Until the Firebase project is connected, [init] logs
/// the problem and every other method does nothing, so the app keeps working.
class PushService {
  PushService({required this._api, required this._app});

  final ApiClient _api;
  final BarqAppKind _app;
  final _onOpen = StreamController<PushMessage>.broadcast();
  StreamSubscription<String>? _registered;
  StreamSubscription<RemoteMessage>? _opened;
  bool _ready = false;

  /// Fires when the user taps a notification.
  Stream<PushMessage> get onOpen => _onOpen.stream;

  String get _tokenPath =>
      _app == BarqAppKind.driver ? '/driver/me/fcm-token' : '/me/fcm-token';

  /// Connects Firebase and asks for permission. Listen to [onOpen] first, so
  /// a tap that opened the app is not missed.
  Future<void> init() async {
    if (_ready) return;
    try {
      await Firebase.initializeApp();
    } on Object catch (e) {
      debugPrint('Push is off, Firebase is not connected: $e');
      return;
    }
    _ready = true;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(_handleOpen);
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleOpen(initial);
  }

  /// Call after login. Also sends every new token Firebase gives us.
  Future<void> registerToken() async {
    if (!_ready) return;
    final messaging = FirebaseMessaging.instance;
    _registered ??= messaging.onRegistered.listen(_sendToken);
    await messaging.register();
  }

  Future<void> dispose() async {
    await _registered?.cancel();
    await _opened?.cancel();
    await _onOpen.close();
  }

  Future<void> _sendToken(String token) =>
      _api.put(_tokenPath, body: {'token': token});

  void _handleOpen(RemoteMessage message) {
    _onOpen.add(
      PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
      ),
    );
  }
}
