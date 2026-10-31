import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/data/orders_repository.dart';

/// How many notifications are unread, for the dot on the home bell.
class UnreadCubit extends Cubit<int> {
  UnreadCubit({required this._repository, required this._pollSeconds})
    : super(0);

  final OrdersRepository _repository;
  final int? Function() _pollSeconds;
  Poller? _poller;

  /// Starts with the logged-in part of the app.
  Future<void> start() async {
    await refresh();
    final seconds = _pollSeconds();
    if (seconds == null || isClosed || _poller != null) return;
    _poller = Poller(
      tick: () async {
        await refresh();
        return null;
      },
      defaultSeconds: seconds,
    )..start();
  }

  void stop() {
    _poller?.stop();
    _poller = null;
  }

  Future<void> refresh() async {
    try {
      final count = await _repository.unreadNotifications();
      if (!isClosed) emit(count);
    } on ApiException {
      // The dot is a hint: a failed check keeps the last value.
    }
  }

  void clear() => emit(0);

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
