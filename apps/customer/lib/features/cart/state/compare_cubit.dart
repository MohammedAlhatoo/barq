import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../browse/data/browse_repository.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

enum CompareStatus { loading, ready, outOfZone, noAddress, failed }

class CompareState {
  const CompareState({
    this.status = CompareStatus.loading,
    this.comparison,
    this.selectedVendorId,
    this.error,
    this.errorCode,
  });

  final CompareStatus status;
  final BasketComparison? comparison;
  final int? selectedVendorId;
  final String? error;

  /// Shown on the out-of-zone screen, like "422 out_of_zone".
  final String? errorCode;

  BasketStore? get selected => comparison?.storeOf(selectedVendorId);
}

class CompareCubit extends Cubit<CompareState> {
  CompareCubit({
    required this._browse,
    required this._cart,
    required this._lines,
  }) : super(const CompareState());

  final BrowseRepository _browse;
  final CartRepository _cart;
  final List<CartLine> _lines;

  /// A request can end after the user left the screen.
  @override
  void emit(CompareState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const CompareState());
    try {
      final address = await _browse.defaultAddress();
      if (address == null) {
        emit(const CompareState(status: CompareStatus.noAddress));
        return;
      }
      final comparison = await _cart.compare(
        lines: _lines,
        addressId: address.id,
      );
      final stores = comparison.stores;
      emit(
        CompareState(
          status: CompareStatus.ready,
          comparison: comparison,
          selectedVendorId:
              comparison.cheapestVendorId ??
              (stores.isEmpty ? null : stores.first.vendorId),
        ),
      );
    } on ApiException catch (e) {
      emit(
        CompareState(
          status: e.code == 'out_of_zone'
              ? CompareStatus.outOfZone
              : CompareStatus.failed,
          error: e.messageAr,
          errorCode: '${e.status} ${e.code}',
        ),
      );
    }
  }

  void select(int vendorId) => emit(
    CompareState(
      status: state.status,
      comparison: state.comparison,
      selectedVendorId: vendorId,
    ),
  );
}
