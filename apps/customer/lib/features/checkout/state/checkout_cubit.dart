import 'package:barq_core/barq_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/countdown.dart';
import '../../auth/data/auth_models.dart';
import '../../browse/data/browse_repository.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/state/cart_cubit.dart';
import '../data/checkout_models.dart';
import '../data/checkout_repository.dart';

class CheckoutState {
  const CheckoutState({
    this.loading = true,
    this.emptyCart = false,
    this.noAddress = false,
    this.outOfZone = false,
    this.storeOutOfZone = false,
    this.error,
    this.address,
    this.quote,
    this.secondsLeft = 0,
    this.substitution = Substitution.callMe,
    this.coupon,
    this.checkingCoupon = false,
    this.couponError,
    this.pricing = false,
    this.placing = false,
    this.placeError,
    this.locked = false,
    this.repricing,
    this.placedOrderId,
  });

  final bool loading;
  final bool emptyCart;
  final bool noAddress;
  final bool outOfZone;

  /// The address is served, but not by the cart's store.
  final bool storeOutOfZone;

  /// The server's reason when no price could be loaded.
  final String? error;
  final SavedAddress? address;
  final OrderQuote? quote;
  final int secondsLeft;
  final Substitution substitution;

  /// The code that is applied now.
  final String? coupon;
  final bool checkingCoupon;
  final String? couponError;

  /// A new quote is on its way, so the price on screen must not be ordered.
  final bool pricing;
  final bool placing;
  final String? placeError;

  /// An order try got no answer, so the server may have it. Nothing can change
  /// until the same request is sent again, or it would be a second order.
  final bool locked;

  /// Set after the price expired and a new quote came. A new object each time.
  final Repricing? repricing;
  final int? placedOrderId;

  bool get canPlace => quote != null && !pricing && !placing && !checkingCoupon;

  CheckoutState copyWith({
    bool? loading,
    bool? emptyCart,
    bool? noAddress,
    bool? outOfZone,
    bool? storeOutOfZone,
    String? error,
    SavedAddress? address,
    OrderQuote? quote,
    int? secondsLeft,
    Substitution? substitution,
    String? Function()? coupon,
    bool? checkingCoupon,
    String? couponError,
    bool? pricing,
    bool? placing,
    String? placeError,
    bool? locked,
    Repricing? repricing,
    int? placedOrderId,
  }) => CheckoutState(
    loading: loading ?? false,
    emptyCart: emptyCart ?? false,
    noAddress: noAddress ?? false,
    outOfZone: outOfZone ?? false,
    storeOutOfZone: storeOutOfZone ?? false,
    error: error,
    address: address ?? this.address,
    quote: quote ?? this.quote,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    substitution: substitution ?? this.substitution,
    coupon: coupon == null ? this.coupon : coupon(),
    checkingCoupon: checkingCoupon ?? this.checkingCoupon,
    couponError: couponError,
    pricing: pricing ?? this.pricing,
    placing: placing ?? this.placing,
    placeError: placeError,
    locked: locked ?? this.locked,
    repricing: repricing ?? this.repricing,
    placedOrderId: placedOrderId,
  );
}

/// Prices the cart, keeps the price's countdown, and creates the order.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required this._repository,
    required this._browse,
    required this._carts,
    required this._cart,
    required this._compareEnabled,
  }) : super(const CheckoutState());

  final CheckoutRepository _repository;
  final BrowseRepository _browse;
  final CartRepository _carts;
  final CartCubit _cart;

  /// False when the project has no `basket_compare` module to ask.
  final bool Function() _compareEnabled;
  late final _countdown = Countdown(
    onTick: (left) => emit(_withSeconds(left)),
    onDone: _onPriceEnded,
  );

  /// Belongs to one exact request: the server refuses the same key with another
  /// body. Kept when a try gets no answer, so sending again can never create a
  /// second order. A new quote gets a new key.
  String? _idempotencyKey;

  String _note = '';

  /// Only the newest quote counts when the user changes things quickly.
  int _quoteRequest = 0;

  /// A request can end after the user left the screen.
  @override
  void emit(CheckoutState state) {
    if (!isClosed) super.emit(state);
  }

  /// A tick must not wipe a message that is on screen.
  CheckoutState _withSeconds(int left) => state.copyWith(
    loading: state.loading,
    error: state.error,
    couponError: state.couponError,
    placeError: state.placeError,
    secondsLeft: left,
  );

  Future<void> start() async {
    if (_cart.state.isEmpty) {
      emit(state.copyWith(emptyCart: true));
      return;
    }
    emit(state.copyWith(loading: true, coupon: () => null));
    try {
      final address = state.address ?? await _browse.defaultAddress();
      if (address == null) {
        emit(state.copyWith(noAddress: true));
        return;
      }
      emit(state.copyWith(loading: true, address: address));
      if (await _storeDelivers(address)) {
        _showQuote(await _fetchQuote());
      } else {
        _blockStore();
      }
    } on ApiException catch (e) {
      _failed(e);
    }
  }

  /// `POST /orders/quote` and `POST /orders` accept a store that does not
  /// deliver to the address. `POST /baskets/compare` lists only the ones that
  /// do, so a cart whose store is missing there must not reach them.
  Future<bool> _storeDelivers(SavedAddress address) async {
    final vendorId = _cart.state.vendorId;
    if (vendorId == null || !_compareEnabled()) return true;
    final comparison = await _carts.compare(
      lines: _cart.state.lines,
      addressId: address.id,
    );
    return comparison.storeOf(vendorId) != null;
  }

  void _blockStore() {
    _countdown.stop();
    _idempotencyKey = null;
    emit(
      state.copyWith(
        storeOutOfZone: true,
        pricing: false,
        checkingCoupon: false,
      ),
    );
  }

  Future<void> changeAddress(SavedAddress address) async {
    _countdown.stop();
    emit(state.copyWith(loading: true, address: address));
    await _requote(checkStore: true);
  }

  /// The server keeps this choice in the quote, and refuses an order that
  /// differs from its quote. So a new choice needs a new quote.
  Future<void> substitutionChanged(Substitution value) async {
    if (state.locked || value == state.substitution) return;
    emit(state.copyWith(substitution: value, pricing: true));
    await _requote();
  }

  void noteChanged(String value) => _note = value.trim();

  Future<void> applyCoupon(String text) async {
    final code = text.trim();
    final vendorId = _cart.state.vendorId;
    if (code.isEmpty || vendorId == null) return;
    if (!state.canPlace || state.locked) return;
    emit(state.copyWith(checkingCoupon: true));
    try {
      await _repository.validateCoupon(code: code, vendorId: vendorId);
      final quote = await _fetchQuote(coupon: code);
      _showQuote(quote, coupon: code);
    } on ApiException catch (e) {
      emit(state.copyWith(checkingCoupon: false, couponError: e.userMessage));
    }
  }

  /// Editing an applied code takes the discount away.
  Future<void> couponEdited(String text) async {
    if (state.couponError != null) emit(state.copyWith());
    if (state.coupon == null || text.trim() == state.coupon) return;
    emit(state.copyWith(coupon: () => null, pricing: true));
    await _requote();
  }

  Future<void> confirm() async {
    final quote = state.quote;
    if (quote == null || !state.canPlace) return;
    emit(state.copyWith(placing: true));
    try {
      final id = await _repository.placeOrder(
        quoteToken: quote.token,
        note: _note,
        substitution: state.substitution,
        idempotencyKey: _idempotencyKey ??= newIdempotencyKey(),
      );
      _countdown.stop();
      _cart.clear();
      emit(state.copyWith(placing: false, placedOrderId: id));
    } on ApiException catch (e) {
      if (e.code == 'quote_expired' || e.code == 'quote_used') {
        _countdown.stop();
        emit(state.copyWith(placing: false, locked: false));
        await _reprice();
      } else if (e.isNetwork || e.status >= 500) {
        emit(
          state.copyWith(
            placing: false,
            locked: true,
            placeError: e.userMessage,
          ),
        );
      } else {
        _idempotencyKey = null;
        emit(state.copyWith(placing: false, placeError: e.userMessage));
      }
    }
  }

  /// While locked the same request is sent again, and the server itself answers
  /// `quote_expired` if the first one never arrived.
  Future<void> _onPriceEnded() async {
    if (!state.locked) await _reprice();
  }

  Future<OrderQuote> _fetchQuote({String? coupon}) => _repository.quote(
    cart: _cart.state,
    addressId: state.address!.id,
    substitution: state.substitution,
    coupon: coupon ?? state.coupon,
  );

  Future<void> _requote({bool checkStore = false}) async {
    final request = ++_quoteRequest;
    try {
      if (checkStore && !await _storeDelivers(state.address!)) {
        if (request == _quoteRequest) _blockStore();
        return;
      }
      final quote = await _fetchQuote();
      if (request == _quoteRequest) _showQuote(quote);
    } on ApiException catch (e) {
      if (request == _quoteRequest) _failed(e);
    }
  }

  void _showQuote(OrderQuote quote, {String? coupon, Repricing? repricing}) {
    _idempotencyKey = null;
    emit(
      state.copyWith(
        quote: quote,
        secondsLeft: quote.expiresIn,
        coupon: coupon == null ? null : () => coupon,
        checkingCoupon: false,
        pricing: false,
        repricing: repricing,
      ),
    );
    _countdown.start(quote.expiresIn);
  }

  void _failed(ApiException e) {
    _countdown.stop();
    emit(
      state.copyWith(
        outOfZone: e.code == 'out_of_zone',
        error: e.code == 'out_of_zone' ? null : e.userMessage,
        pricing: false,
        checkingCoupon: false,
        placing: false,
      ),
    );
  }

  /// The reserved price ended: asks for a new one and reports what changed.
  Future<void> _reprice() async {
    final old = state.quote;
    if (old == null) return;
    emit(state.copyWith(pricing: true));
    try {
      final fresh = await _fetchQuote();
      _showQuote(
        fresh,
        repricing: Repricing(
          oldTotal: old.total,
          newTotal: fresh.total,
          changes: await _changes(old, fresh),
          minutes: old.expiresIn ~/ 60,
        ),
      );
    } on ApiException catch (e) {
      _failed(e);
    }
  }

  /// Each product whose price moved, then the other rows of the breakdown. A
  /// quote has no prices per product, so those come from the products.
  Future<List<PriceChange>> _changes(OrderQuote old, OrderQuote fresh) async {
    final products = old.itemsTotal.amount == fresh.itemsTotal.amount
        ? const <PriceChange>[]
        : await _productChanges();
    return [
      ...products,
      for (final line in fresh.breakdown)
        if (line.kind != 'items' || products.isEmpty) ..._lineChange(old, line),
    ];
  }

  Iterable<PriceChange> _lineChange(OrderQuote old, PriceLine line) sync* {
    for (final before in old.breakdown) {
      if (before.key == line.key && before.price.amount != line.price.amount) {
        yield PriceChange(
          title: line.label,
          before: before.price,
          after: line.price,
        );
      }
    }
  }

  Future<List<PriceChange>> _productChanges() async {
    final changes = <PriceChange>[];
    final prices = <int, Money>{};
    try {
      for (final line in _cart.state.lines) {
        final price = (await _browse.product(line.productId)).price;
        if (price.amount == line.unitPrice.amount) continue;
        prices[line.productId] = price;
        changes.add(
          PriceChange(
            title: line.name,
            before: line.unitPrice,
            after: price,
            line: line,
          ),
        );
      }
    } on ApiException catch (e) {
      // The breakdown row still shows that the items total moved.
      debugPrint('Product prices not loaded: ${e.code}');
      return const [];
    }
    _cart.updatePrices(prices);
    return changes;
  }

  @override
  Future<void> close() {
    _countdown.stop();
    return super.close();
  }
}
