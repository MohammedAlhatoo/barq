import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orders_models.dart';
import '../data/orders_repository.dart';

class TrackingState {
  const TrackingState({
    this.loading = true,
    this.error,
    this.tracking,
    this.order,
    this.sharing = false,
    this.shareError,
  });

  final bool loading;
  final String? error;
  final Tracking? tracking;

  /// Has `available_actions`, which the tracking answer does not.
  final Order? order;
  final bool sharing;
  final String? shareError;
}

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit({
    required this._repository,
    required this._orderId,
    required int pollSeconds,
  }) : super(const TrackingState()) {
    _poller = Poller(tick: _poll, defaultSeconds: pollSeconds);
  }

  final OrdersRepository _repository;
  final int _orderId;
  late final Poller _poller;

  /// A request can end after the user left the screen.
  @override
  void emit(TrackingState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> start() async {
    await load();
    if (!isClosed && state.tracking != null) _poller.start();
  }

  Future<void> load() async {
    try {
      final tracking = await _repository.tracking(_orderId);
      final order = await _repository.order(_orderId);
      emit(TrackingState(loading: false, tracking: tracking, order: order));
      if (order.isTerminal) _poller.stop();
    } on ApiException catch (e) {
      emit(TrackingState(loading: false, error: e.messageAr));
    }
  }

  /// `next_poll_seconds` from the server sets the next wait.
  Future<int?> _poll() async {
    final tracking = await _repository.tracking(_orderId);
    final changed = tracking.statusKey != state.tracking?.statusKey;
    final order = changed ? await _repository.order(_orderId) : state.order;
    emit(TrackingState(loading: false, tracking: tracking, order: order));
    if (order?.isTerminal == true) _poller.stop();
    return tracking.nextPollSeconds;
  }

  /// Null when the link could not be made; [TrackingState.shareError] says why.
  Future<ShareLink?> createShareLink() async {
    final current = state;
    emit(
      TrackingState(
        loading: false,
        tracking: current.tracking,
        order: current.order,
        sharing: true,
      ),
    );
    try {
      final link = await _repository.createShareLink(_orderId);
      emit(
        TrackingState(
          loading: false,
          tracking: state.tracking,
          order: state.order,
        ),
      );
      return link;
    } on ApiException catch (e) {
      emit(
        TrackingState(
          loading: false,
          tracking: state.tracking,
          order: state.order,
          shareError: e.messageAr,
        ),
      );
      return null;
    }
  }

  Future<void> stopShareLink() async {
    try {
      await _repository.stopShareLink(_orderId);
    } on ApiException catch (e) {
      emit(
        TrackingState(
          loading: false,
          tracking: state.tracking,
          order: state.order,
          shareError: e.messageAr,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _poller.stop();
    return super.close();
  }
}
