import 'package:barq_core/barq_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_models.dart';
import '../../browse/data/browse_repository.dart';
import '../../cart/data/basket_ranking.dart';
import '../../cart/data/cart_models.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/state/cart_cubit.dart';
import '../../orders/data/orders_models.dart';
import '../../orders/data/orders_repository.dart';
import '../data/assistant_models.dart';
import '../data/list_parser.dart';
import '../data/product_matcher.dart';

/// A message holds data, not text: the screen turns it into the app's language.
sealed class AssistantMessage {
  const AssistantMessage();
}

class GreetingMessage extends AssistantMessage {
  const GreetingMessage();
}

/// "اكتب قائمتك": how a list is written.
class HintMessage extends AssistantMessage {
  const HintMessage();
}

class UserMessage extends AssistantMessage {
  const UserMessage(this.text);

  final String text;
}

/// What was found for the list, waiting for the customer to confirm it.
class MatchesMessage extends AssistantMessage {
  const MatchesMessage({required this.items, this.droppedCount = 0});

  final List<MatchedItem> items;

  /// Items left out because the cart has a limit of lines.
  final int droppedCount;

  bool get hasMatches => items.any((item) => item.product != null);
}

/// The stores for the list. The first one is the best.
class StoresMessage extends AssistantMessage {
  const StoresMessage({required this.options, required this.selectedVendorId});

  final List<StoreOption> options;
  final int selectedVendorId;

  StoreOption get selected =>
      options.firstWhere((o) => o.store.vendorId == selectedVendorId);
}

enum AssistantProblem {
  notUnderstood,
  noLastOrder,
  noAddress,
  outOfZone,
  noStores,
  failed,
}

class ProblemMessage extends AssistantMessage {
  const ProblemMessage(this.problem, {this.error});

  final AssistantProblem problem;

  /// The server's own words, for [AssistantProblem.failed].
  final String? error;
}

class AssistantState {
  const AssistantState({
    this.messages = const [GreetingMessage()],
    this.busy = false,
  });

  final List<AssistantMessage> messages;

  /// Waiting for the server: the screen shows the typing bubble.
  final bool busy;

  /// Only the newest message can still be answered.
  bool canAnswer(AssistantMessage message) =>
      !busy && identical(message, messages.last);
}

/// The whole conversation: list → items found → stores → cart.
class AssistantCubit extends Cubit<AssistantState> {
  AssistantCubit({
    required this._browse,
    required this._carts,
    required this._orders,
    required this._cart,
  }) : super(const AssistantState());

  final BrowseRepository _browse;
  final CartRepository _carts;
  final OrdersRepository _orders;
  final CartCubit _cart;
  late final _matcher = ProductMatcher(_browse);
  late final _ranking = BasketRanking(browse: _browse, cart: _carts);

  /// `GET /orders` answers one scope at a time.
  static const _orderScopes = ['active', 'completed', 'cancelled'];

  /// Runs the step that failed again.
  Future<void> Function()? _retry;

  /// The list being worked on, as sent to `POST /baskets/compare`.
  List<CartLine> _lines = const [];

  /// A request can end after the user left the screen.
  @override
  void emit(AssistantState state) {
    if (!isClosed) super.emit(state);
  }

  void _add(AssistantMessage message, {bool busy = false}) =>
      emit(AssistantState(messages: [...state.messages, message], busy: busy));

  void _replaceLast(AssistantMessage message) => emit(
    AssistantState(
      messages: [...state.messages.take(state.messages.length - 1), message],
    ),
  );

  void _setBusy(bool busy) =>
      emit(AssistantState(messages: state.messages, busy: busy));

  void _fail(ApiException e, Future<void> Function() step) {
    _retry = step;
    _add(ProblemMessage(AssistantProblem.failed, error: e.userMessage));
  }

  void showHint() => _add(const HintMessage());

  Future<void> retry() async {
    final step = _retry;
    if (step != null && !state.busy) await step();
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || state.busy) return;
    _add(UserMessage(message), busy: true);
    final items = ListParser.parse(message);
    if (items.isEmpty) {
      _add(const ProblemMessage(AssistantProblem.notUnderstood));
      return;
    }
    await _match(items);
  }

  Future<void> reorderLast(String chipLabel) async {
    if (state.busy) return;
    _add(UserMessage(chipLabel), busy: true);
    await _reorderLast();
  }

  /// An order has only names and quantities, and no reorder endpoint exists, so
  /// its items take the same way as a typed list.
  Future<void> _reorderLast() async {
    _setBusy(true);
    try {
      final order = await _latestOrder();
      if (order == null || order.items.isEmpty) {
        _add(const ProblemMessage(AssistantProblem.noLastOrder));
        return;
      }
      await _match([
        for (final item in order.items)
          ParsedItem(name: item.name, qty: item.qty),
      ]);
    } on ApiException catch (e) {
      _fail(e, _reorderLast);
    }
  }

  Future<Order?> _latestOrder() async {
    final pages = await Future.wait([
      for (final scope in _orderScopes) _orders.orders(scope: scope),
    ]);
    OrderSummary? latest;
    for (final page in pages) {
      for (final order in page.items) {
        if (latest == null || order.createdAt.isAfter(latest.createdAt)) {
          latest = order;
        }
      }
    }
    return latest == null ? null : _orders.order(latest.id);
  }

  /// One request at a time: a long list must not trip the server's rate limit.
  Future<void> _match(List<ParsedItem> items) async {
    _setBusy(true);
    final taken = items.take(_cart.maxLines).toList();
    try {
      final matched = <MatchedItem>[];
      for (final item in taken) {
        final found = await _matcher.find(item);
        matched.add(
          found.qty > _cart.maxQty ? found.withQty(_cart.maxQty) : found,
        );
      }
      _add(
        MatchesMessage(
          items: matched,
          droppedCount: items.length - taken.length,
        ),
      );
    } on ApiException catch (e) {
      _fail(e, () => _match(items));
    }
  }

  /// [item] of the last message takes the suggestion the customer tapped.
  void chooseAlternative(MatchedItem item, int productId) {
    final message = state.messages.last;
    if (message is! MatchesMessage || state.busy) return;
    final choice = item.alternatives.firstWhere((p) => p.id == productId);
    _replaceLast(
      MatchesMessage(
        items: [
          for (final other in message.items)
            identical(other, item) ? other.choose(choice) : other,
        ],
        droppedCount: message.droppedCount,
      ),
    );
  }

  /// The list as the server wants it: each product once.
  List<CartLine> _linesOf(List<MatchedItem> items) {
    final lines = <int, CartLine>{};
    for (final item in items) {
      final line = item.line;
      if (line == null) continue;
      final known = lines[line.productId];
      final qty = line.qty + (known?.qty ?? 0);
      lines[line.productId] = line.copyWith(
        qty: qty > _cart.maxQty ? _cart.maxQty : qty,
      );
    }
    return lines.values.toList();
  }

  Future<void> compareStores() async {
    final message = state.messages.last;
    if (message is! MatchesMessage || state.busy) return;
    _lines = _linesOf(message.items);
    await _compare();
  }

  /// After another address became the default one.
  Future<void> compareAgain() => _compare();

  Future<void> _compare() async {
    _setBusy(true);
    try {
      final address = await _browse.defaultAddress();
      if (address == null) {
        _retry = _compare;
        _add(const ProblemMessage(AssistantProblem.noAddress));
        return;
      }
      final comparison = await _carts.compare(
        lines: _lines,
        addressId: address.id,
      );
      final options = await _options(comparison, address);
      if (options.isEmpty) {
        _add(const ProblemMessage(AssistantProblem.noStores));
        return;
      }
      _add(
        StoresMessage(
          options: options,
          selectedVendorId: options.first.store.vendorId,
        ),
      );
    } on ApiException catch (e) {
      if (e.code == 'out_of_zone') {
        _retry = _compare;
        _add(const ProblemMessage(AssistantProblem.outOfZone));
      } else {
        _fail(e, _compare);
      }
    }
  }

  /// The nearest complete stores from the lowest total. If they are too few,
  /// the stores that have most of the list follow, with what they miss.
  Future<List<StoreOption>> _options(
    BasketComparison comparison,
    SavedAddress address,
  ) async {
    final distances = await _ranking.distances(address);
    final complete = _ranking
        .nearest(comparison.stores.where((s) => s.complete).toList(), distances)
        .take(BasketRanking.comparedStores)
        .toList();
    final partial = _partialStores(comparison, distances, complete.length);
    final totals = await _ranking.quote([...complete, ...partial], address);
    return [
      for (final store in [
        ..._ranking.rank(complete, comparison.stores, totals),
        ...partial,
      ])
        StoreOption(
          store: store,
          total: totals[store.vendorId],
          distanceKm: distances[store.vendorId],
        ),
    ];
  }

  List<BasketStore> _partialStores(
    BasketComparison comparison,
    Map<int, double> distances,
    int completeCount,
  ) {
    final nearest = _ranking.nearest(
      comparison.stores
          .where((s) => !s.complete && s.availableCount > 0)
          .toList(),
      distances,
    );
    final mostFirst = [...nearest]
      ..sort((a, b) {
        final order = b.availableCount.compareTo(a.availableCount);
        return order != 0
            ? order
            : nearest.indexOf(a).compareTo(nearest.indexOf(b));
      });
    return mostFirst
        .take(BasketRanking.comparedStores - completeCount)
        .toList();
  }

  void selectStore(int vendorId) {
    final message = state.messages.last;
    if (message is! StoresMessage || state.busy) return;
    _replaceLast(
      StoresMessage(options: message.options, selectedVendorId: vendorId),
    );
  }

  /// Puts the chosen store's products in the cart, ready for checkout.
  void fillCart() {
    final message = state.messages.last;
    if (message is StoresMessage) {
      _cart.fillFrom(message.selected.store, _lines);
    }
  }
}
