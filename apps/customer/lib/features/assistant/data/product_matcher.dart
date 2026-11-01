import '../../browse/data/browse_models.dart';
import '../../browse/data/browse_repository.dart';
import 'assistant_models.dart';
import 'list_parser.dart';
import 'quantity_fit.dart';

/// Finds the product behind each name of a list with `GET /products?q=`.
class ProductMatcher {
  ProductMatcher(this._browse);

  /// `q` is at most this long in `openapi.json`.
  static const _maxQuery = 60;
  static const _maxAlternatives = 3;

  /// Other names people use for the same thing.
  static const _sameThing = {
    'طماطم': 'بندورة',
    'بطاطس': 'بطاطا',
    'رز': 'أرز',
    'جلي': 'سائل جلي',
    'كعكة': 'كعك',
  };

  final BrowseRepository _browse;

  Future<MatchedItem> find(ParsedItem item) async {
    for (final term in searchTerms(item.name)) {
      final best = bestOf(term, await _search(term, item));
      if (best != null) return MatchedItem.found(item, best);
    }
    // Nothing has all the words: what has the main one is only a suggestion.
    // The main word comes first in Arabic and last in English.
    final words = item.name.split(' ');
    if (words.length > 1) {
      for (final word in {words.first, words.last}) {
        for (final term in searchTerms(word)) {
          final alternatives = _distinct(term, await _search(term, item));
          if (alternatives.isNotEmpty) {
            return MatchedItem(
              item: item,
              qty: item.qty,
              alternatives: alternatives,
            );
          }
        }
      }
    }
    return MatchedItem(item: item, qty: item.qty);
  }

  Future<List<Product>> _search(String term, ParsedItem item) async {
    final query = term.length > _maxQuery ? term.substring(0, _maxQuery) : term;
    final page = await _browse.products(query: query);
    return page.items
        .where((p) => p.inStock && QuantityFit.of(item, p) != null)
        .toList();
  }

  /// The server looks for the exact text, so "بندوره" and "ارز" find nothing.
  /// These are tried in order until one finds something.
  static List<String> searchTerms(String name) {
    final singular = _singular(name);
    // "cucumbers" misses the stores that sell "Cucumber 1kg", and the singular
    // is found inside both.
    final terms = <String>{?singular, name, ?_sameThing[name]};
    if (name.endsWith('ه')) terms.add('${_withoutLast(name)}ة');
    if (name.endsWith('ا')) terms.add('${_withoutLast(name)}ة');
    if (name.startsWith('ا')) terms.add('أ${name.substring(1)}');
    // One "موزة" is sold as "موز".
    if (name.endsWith('ة') || name.endsWith('ه')) terms.add(_withoutLast(name));
    return terms.toList();
  }

  static String _withoutLast(String name) => name.substring(0, name.length - 1);

  /// The English singular of [name], or null if it is not an English plural.
  static String? _singular(String name) {
    final lower = name.toLowerCase();
    if (!RegExp(r'[a-z]s$').hasMatch(lower) || lower.endsWith('ss')) {
      return null;
    }
    if (lower.endsWith('ies')) {
      return '${name.substring(0, name.length - 3)}y';
    }
    final strong = RegExp(r'(oes|ches|shes|xes|sses)$').hasMatch(lower);
    return name.substring(0, name.length - (strong ? 2 : 1));
  }

  /// The product whose name is closest to [term]. Null if [products] is empty.
  static Product? bestOf(String term, List<Product> products) {
    Product? best;
    var bestScore = -1;
    for (final product in products) {
      final score = _score(term, product.name);
      final closer =
          score > bestScore ||
          (score == bestScore && product.name.length < best!.name.length);
      if (closer) {
        best = product;
        bestScore = score;
      }
    }
    return best;
  }

  /// 3 is the same name, 2 starts with the term, 1 has it as a whole word and
  /// 0 only has it inside a word, like "حليب" in "بالحليب".
  static int _score(String term, String name) {
    final wanted = ListParser.fold(term);
    final words = ListParser.fold(name).split(' ');
    if (words.join(' ') == wanted) return 3;
    final termWords = wanted.split(' ');
    final startsWith =
        words.length >= termWords.length &&
        termWords.indexed.every((word) => words[word.$1] == word.$2);
    if (startsWith) return 2;
    return termWords.every(words.contains) ? 1 : 0;
  }

  /// Every store has its own copy of a product, so one name is one chip.
  static List<Product> _distinct(String term, List<Product> products) {
    final byName = <String, Product>{};
    for (final product in products) {
      byName.putIfAbsent(product.name, () => product);
    }
    final closest = byName.values.toList()
      ..sort((a, b) => _score(term, b.name).compareTo(_score(term, a.name)));
    return closest.take(_maxAlternatives).toList();
  }
}
