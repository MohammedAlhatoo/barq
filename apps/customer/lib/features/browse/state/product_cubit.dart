import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/browse_models.dart';
import '../data/browse_repository.dart';

class ProductState {
  const ProductState({
    this.loading = true,
    this.product,
    this.vendor,
    this.selected = const {},
    this.qty = 1,
    this.error,
  });

  final bool loading;
  final Product? product;
  final Vendor? vendor;

  /// Option key → the chosen choice keys.
  final Map<String, Set<String>> selected;
  final int qty;
  final String? error;

  bool isSelected(ProductOption option, ProductChoice choice) =>
      selected[option.key]?.contains(choice.key) ?? false;

  /// True when every required option has a choice.
  bool get canAdd {
    final item = product;
    if (item == null || !item.inStock) return false;
    return item.options.every(
      (o) => !o.isRequired || (selected[o.key]?.isNotEmpty ?? false),
    );
  }

  /// The product's own price is the final one only for a single piece with no
  /// paid choice. Otherwise the server prices it, so the button shows no price.
  bool get showsPrice {
    final item = product;
    if (item == null || qty != 1) return false;
    return item.options.every(
      (o) => o.choices.every((c) => !isSelected(o, c) || c.price.amount == 0),
    );
  }

  /// The shape `POST /orders/quote` takes.
  Map<String, Object> get optionsPayload => {
    for (final option in product?.options ?? const <ProductOption>[])
      if (selected[option.key]?.isNotEmpty ?? false)
        option.key: option.isMulti
            ? selected[option.key]!.toList()
            : selected[option.key]!.first,
  };

  String? get optionsLabel {
    final labels = [
      for (final option in product?.options ?? const <ProductOption>[])
        for (final choice in option.choices)
          if (isSelected(option, choice)) choice.label,
    ];
    return labels.isEmpty ? null : labels.join('، ');
  }

  ProductState copyWith({Map<String, Set<String>>? selected, int? qty}) =>
      ProductState(
        loading: false,
        product: product,
        vendor: vendor,
        selected: selected ?? this.selected,
        qty: qty ?? this.qty,
      );
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository, this._id) : super(const ProductState());

  final BrowseRepository _repository;
  final int _id;

  /// A request can end after the user left the screen.
  @override
  void emit(ProductState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> load() async {
    emit(const ProductState());
    try {
      final product = await _repository.product(_id);
      final vendor = await _vendor(product.vendorId);
      emit(
        ProductState(
          loading: false,
          product: product,
          vendor: vendor,
          selected: {
            for (final option in product.options)
              if (option.isRequired &&
                  !option.isMulti &&
                  option.choices.isNotEmpty)
                option.key: {option.choices.first.key},
          },
        ),
      );
    } on ApiException catch (e) {
      emit(ProductState(loading: false, error: e.messageAr));
    }
  }

  /// The store row is extra: the product still shows without it.
  Future<Vendor?> _vendor(int? id) async {
    if (id == null) return null;
    try {
      return await _repository.vendor(id);
    } on ApiException {
      return null;
    }
  }

  void qtyChanged(int qty) => emit(state.copyWith(qty: qty));

  void toggle(ProductOption option, ProductChoice choice) {
    final current = state.selected[option.key] ?? const <String>{};
    final Set<String> next;
    if (option.isMulti) {
      next = current.contains(choice.key)
          ? current.difference({choice.key})
          : {...current, choice.key};
    } else {
      next = current.contains(choice.key) && !option.isRequired
          ? const {}
          : {choice.key};
    }
    emit(state.copyWith(selected: {...state.selected, option.key: next}));
  }
}
