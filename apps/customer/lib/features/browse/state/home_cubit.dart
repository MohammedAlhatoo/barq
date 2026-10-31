import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/browse_models.dart';
import '../data/browse_repository.dart';

class HomeState {
  const HomeState({
    this.loading = true,
    this.categories = const [],
    this.products = const [],
    this.name,
    this.error,
  });

  final bool loading;
  final List<Category> categories;
  final List<Product> products;
  final String? name;
  final String? error;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final BrowseRepository _repository;

  /// A request can end after the user left the screen.
  @override
  void emit(HomeState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const HomeState());
    try {
      final categories = await _repository.categories();
      final page = await _repository.products();
      emit(
        HomeState(
          loading: false,
          categories: categories,
          products: page.items,
          name: await _name(),
        ),
      );
    } on ApiException catch (e) {
      emit(HomeState(loading: false, error: e.messageAr));
    }
  }

  /// The greeting is not worth failing the whole screen for.
  Future<String?> _name() async {
    try {
      return await _repository.currentName();
    } on ApiException {
      return null;
    }
  }
}
