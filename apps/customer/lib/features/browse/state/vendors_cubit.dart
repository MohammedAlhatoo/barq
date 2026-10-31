import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/browse_models.dart';
import '../data/browse_repository.dart';
import '../data/user_location.dart';

class VendorsState {
  const VendorsState({
    this.loading = true,
    this.openOnly = false,
    this.items = const [],
    this.nextPage,
    this.loadingMore = false,
    this.moreFailed = false,
    this.error,
  });

  final bool loading;
  final bool openOnly;

  /// In the server's order: open first, then nearest.
  final List<Vendor> items;
  final int? nextPage;
  final bool loadingMore;
  final bool moreFailed;
  final String? error;
}

/// The "كل المتاجر" list with paging.
class VendorsCubit extends Cubit<VendorsState> {
  VendorsCubit(this._repository, this._location) : super(const VendorsState());

  final BrowseRepository _repository;
  final UserLocation _location;

  /// Without one the list still shows, only without distances.
  ({double lat, double lng})? _point;

  /// Answers of an older chip are ignored.
  int _request = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(VendorsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() => _firstPage(state.openOnly);

  Future<void> select({required bool openOnly}) async {
    if (openOnly != state.openOnly) await _firstPage(openOnly);
  }

  Future<void> _firstPage(bool openOnly) async {
    final request = ++_request;
    emit(VendorsState(openOnly: openOnly));
    try {
      _point = await _location.current();
      final page = await _repository.vendorsPage(
        lat: _point?.lat,
        lng: _point?.lng,
        openNow: openOnly,
      );
      if (request != _request) return;
      emit(
        VendorsState(
          loading: false,
          openOnly: openOnly,
          items: page.items,
          nextPage: page.nextPage,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request) return;
      emit(
        VendorsState(loading: false, openOnly: openOnly, error: e.messageAr),
      );
    }
  }

  Future<void> loadMore() async {
    final next = state.nextPage;
    if (next == null || state.loadingMore || state.loading) return;
    final request = _request;
    emit(_more(next, loadingMore: true));
    try {
      final page = await _repository.vendorsPage(
        lat: _point?.lat,
        lng: _point?.lng,
        openNow: state.openOnly,
        page: next,
      );
      if (request != _request) return;
      emit(
        VendorsState(
          loading: false,
          openOnly: state.openOnly,
          items: [...state.items, ...page.items],
          nextPage: page.nextPage,
        ),
      );
    } on ApiException {
      if (request != _request) return;
      emit(_more(next, moreFailed: true));
    }
  }

  VendorsState _more(
    int next, {
    bool loadingMore = false,
    bool moreFailed = false,
  }) => VendorsState(
    loading: false,
    openOnly: state.openOnly,
    items: state.items,
    nextPage: next,
    loadingMore: loadingMore,
    moreFailed: moreFailed,
  );
}
