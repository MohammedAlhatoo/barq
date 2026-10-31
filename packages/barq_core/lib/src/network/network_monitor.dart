import 'package:connectivity_plus/connectivity_plus.dart';

/// Tells the app when the device loses or regains its network.
class NetworkMonitor {
  NetworkMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  /// true when the network comes back, false when it goes away.
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();

  bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
