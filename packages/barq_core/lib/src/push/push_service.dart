import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/barq_env.dart';
import 'push_message.dart';

/// FCM notifications. Until the app has its google-services.json, [init] logs
/// the problem and every other method does nothing, so the app keeps working.
class PushService {
  PushService({required this._api, required this._app});

  final ApiClient _api;
  final BarqAppKind _app;
  final _onOpen = StreamController<PushMessage>.broadcast();
  final _onForeground = StreamController<PushMessage>.broadcast();
  StreamSubscription<String>? _refreshed;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<RemoteMessage>? _received;
  bool _ready = false;

  /// Fires when the user taps a notification.
  Stream<PushMessage> get onOpen => _onOpen.stream;

  /// Fires when a notification arrives while the app is open. The phone does
  /// not show it then, so the app refreshes its own list instead.
  Stream<PushMessage> get onForeground => _onForeground.stream;

  bool get _isDriver => _app == BarqAppKind.driver;
  String get _tokenPath => _isDriver ? '/driver/me/fcm-token' : '/me/fcm-token';
  String _openedPath(String id) => _isDriver
      ? '/driver/notifications/$id/opened'
      : '/notifications/$id/opened';

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
    _received = FirebaseMessaging.onMessage.listen(
      (message) => _onForeground.add(_toPush(message)),
    );
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(_handleOpen);
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleOpen(initial);
  }

  /// Call after login. Also sends every new token Firebase gives us.
  Future<void> registerToken() async {
    if (!_ready) return;
    final messaging = FirebaseMessaging.instance;
    // onRegistered gives the token now, and again whenever Firebase changes it.
    _refreshed ??= messaging.onRegistered.listen(_sendToken);
    try {
      await messaging.register();
    } on Object catch (e) {
      debugPrint('FCM token not received: $e');
    }
  }

  Future<void> dispose() async {
    await _refreshed?.cancel();
    await _opened?.cancel();
    await _received?.cancel();
    await _onOpen.close();
    await _onForeground.close();
  }

  Future<void> _sendToken(String token) async {
    try {
      await _api.put(_tokenPath, body: {'token': token});
    } on ApiException catch (e) {
      debugPrint('FCM token not saved: ${e.code}');
    }
  }

  /// Tells the server the user opened it (the dashboard shows «فُتح»), then
  /// lets the app open the right screen.
  Future<void> _handleOpen(RemoteMessage message) async {
    _onOpen.add(_toPush(message));
    final id = message.data['notification_id'];
    if (id == null) return;
    try {
      await _api.post(_openedPath('$id'));
    } on ApiException catch (e) {
      debugPrint('Push open not recorded: ${e.code}');
    }
  }

  PushMessage _toPush(RemoteMessage message) => PushMessage(
    title: message.notification?.title,
    body: message.notification?.body,
    data: message.data,
  );
}
