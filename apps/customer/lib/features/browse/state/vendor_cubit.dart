import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/browse_models.dart';
import '../data/browse_repository.dart';

class VendorState {
  const VendorState({this.loading = true, this.vendor, this.error});

  final bool loading;
  final Vendor? vendor;
  final String? error;
}

class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repository, this._id) : super(const VendorState());

  final BrowseRepository _repository;
  final int _id;

  /// A request can end after the user left the screen.
  @override
  void emit(VendorState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const VendorState());
    try {
      final vendor = await _repository.vendor(_id);
      emit(VendorState(loading: false, vendor: vendor));
    } on ApiException catch (e) {
      emit(VendorState(loading: false, error: e.messageAr));
    }
  }
}
