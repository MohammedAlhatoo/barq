import '../../browse/data/browse_models.dart';
import 'list_parser.dart';

/// What the confirmation bubble must tell the customer about a quantity.
enum QuantityNote { none, soldByKilo, soldByLiter, rounded }

/// How what the customer asked for fits what a product sells.
class QuantityFit {
  const QuantityFit({
    required this.qty,
    this.options = const {},
    this.optionsLabel,
    this.note = QuantityNote.none,
  });

  /// The size of one pack is not always exact, but a tiny rest is only how
  /// decimals are stored.
  static const _tolerance = 0.000001;

  final int qty;

  /// The shape `POST /orders/quote` takes.
  final Map<String, Object> options;
  final String? optionsLabel;
  final QuantityNote note;

  /// Tries a choice of the product, then the size in its name, then just
  /// rounds. Null if the product needs a choice that cannot be made from the
  /// list: only its own screen can do that.
  static QuantityFit? of(ParsedItem item, Product product) {
    final wanted = item.wanted;
    final byChoice = wanted == null ? null : _byChoice(wanted, product);
    if (byChoice != null) return byChoice;
    if (product.needsChoice) return null;
    final pack = ListParser.packOf(product.name);
    if (wanted == null || pack == null || pack.measure != wanted.measure) {
      return QuantityFit(
        qty: item.qty,
        note: item.rounded ? QuantityNote.rounded : QuantityNote.none,
      );
    }
    final packs = wanted.amount / pack.amount;
    final qty = (packs - _tolerance).ceil();
    if ((qty - packs).abs() < _tolerance) return QuantityFit(qty: qty);
    return QuantityFit(qty: qty, note: _noteFor(pack));
  }

  /// The biggest choice that makes the amount exactly: a kilo and a half with
  /// choices of 500 g and 1 kg is three of 500 g.
  static QuantityFit? _byChoice(PackSize wanted, Product product) {
    final options = <String, Object>{};
    final labels = <String>[];
    var qty = 1;
    for (final option in product.options) {
      ProductChoice? best;
      var bestCount = 0;
      var bestSize = 0.0;
      for (final choice in option.choices) {
        final size = ListParser.packOf(choice.label);
        if (size == null || size.measure != wanted.measure) continue;
        final count = wanted.amount / size.amount;
        final exact = (count - count.round()).abs() < _tolerance;
        if (exact && count.round() >= 1 && size.amount > bestSize) {
          best = choice;
          bestCount = count.round();
          bestSize = size.amount;
        }
      }
      if (best == null) continue;
      options[option.key] = option.isMulti ? [best.key] : best.key;
      labels.add(best.label);
      qty = bestCount;
    }
    final complete = product.options.every(
      (option) => !option.isRequired || options.containsKey(option.key),
    );
    if (options.isEmpty || !complete) return null;
    return QuantityFit(
      qty: qty,
      options: options,
      optionsLabel: labels.join(' · '),
    );
  }

  static QuantityNote _noteFor(PackSize pack) {
    if ((pack.amount - 1).abs() >= _tolerance) return QuantityNote.rounded;
    return switch (pack.measure) {
      ItemMeasure.weight => QuantityNote.soldByKilo,
      ItemMeasure.volume => QuantityNote.soldByLiter,
      ItemMeasure.pieces => QuantityNote.rounded,
    };
  }
}
