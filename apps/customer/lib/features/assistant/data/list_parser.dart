/// What an amount counts. A box or a bundle has no measure: it is just one.
enum ItemMeasure { weight, volume, pieces }

/// An amount in kilos, litres or pieces.
class PackSize {
  const PackSize(this.amount, this.measure);

  final double amount;
  final ItemMeasure measure;
}

/// One line of a shopping list. [qty] is what goes to the API, always a whole
/// number. [rounded] means the customer asked for something else, like half a
/// kilo. [wanted] is what they asked for, when it was a real measure.
class ParsedItem {
  const ParsedItem({
    required this.name,
    required this.qty,
    this.rounded = false,
    this.wanted,
  });

  final String name;
  final int qty;
  final bool rounded;
  final PackSize? wanted;
}

typedef _Unit = ({double size, ItemMeasure? measure});

/// Reads a free text list in Arabic, English or both, such as
/// "كيلو بندورة ونص كيلو خيار، 2 kg potatoes and 1 liter milk".
/// It only reads text: it knows nothing about products or the server.
abstract final class ListParser {
  /// Writing a word with ه instead of ة, or ا instead of أ, is still that word,
  /// and so is an English word in capitals.
  static String fold(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');

  static Map<String, _Unit> _unit(
    List<String> words,
    double size,
    ItemMeasure? measure,
  ) => {for (final word in words) fold(word): (size: size, measure: measure)};

  static final Map<String, _Unit> _units = {
    ..._unit(
      const ['كيلو', 'كلو', 'كيلوغرام', 'كيلوجرام', 'كغ', 'كغم', 'كجم'],
      1,
      ItemMeasure.weight,
    ),
    ..._unit(
      const ['kg', 'kgs', 'kilo', 'kilos', 'kilogram', 'kilograms'],
      1,
      ItemMeasure.weight,
    ),
    ..._unit(
      const ['غرام', 'غم', 'غ', 'جرام', 'جم', 'g', 'gm', 'gram', 'grams'],
      1 / 1000,
      ItemMeasure.weight,
    ),
    ..._unit(
      const ['لتر', 'ليتر', 'l', 'ltr', 'liter', 'liters', 'litre', 'litres'],
      1,
      ItemMeasure.volume,
    ),
    ..._unit(const ['مل', 'ml'], 1 / 1000, ItemMeasure.volume),
    ..._unit(
      const ['حبة', 'حبات', 'قطعة', 'قطع', 'piece', 'pieces', 'pc', 'pcs'],
      1,
      ItemMeasure.pieces,
    ),
    ..._unit(const ['دزينة', 'dozen', 'dozens'], 12, ItemMeasure.pieces),
    ..._unit(
      const [
        'علبة', 'علب', 'كيس', 'اكياس', 'زجاجة', 'قنينة', 'ربطة', 'ربطات', //
        'ضمة', 'باكيت', 'كرتونة', 'طبق', 'pack', 'packs', 'packet', 'packets',
        'box', 'boxes', 'bag', 'bags', 'bottle', 'bottles', 'can', 'cans', //
        'bundle', 'bundles', 'tray', 'trays',
      ],
      1,
      null,
    ),
  };

  /// The Arabic form that means "two of": "كيلوين" is 2 kilos.
  static final Map<String, _Unit> _duals = {
    ..._unit(const ['كيلوين', 'كلوين'], 1, ItemMeasure.weight),
    ..._unit(const ['لترين', 'ليترين'], 1, ItemMeasure.volume),
    ..._unit(const ['حبتين', 'قطعتين'], 1, ItemMeasure.pieces),
    ..._unit(
      const [
        'علبتين', 'كيسين', 'زجاجتين', 'قنينتين', 'ربطتين', 'ضمتين', //
        'باكيتين', 'كرتونتين', 'طبقين',
      ],
      1,
      null,
    ),
  };

  static Map<String, double> _numbers(List<String> words, double value) => {
    for (final word in words) fold(word): value,
  };

  static final Map<String, double> _fractions = {
    ..._numbers(const ['نص', 'نصف', 'half'], 1 / 2),
    ..._numbers(const ['ثلث', 'تلت', 'third'], 1 / 3),
    ..._numbers(const ['ربع', 'quarter'], 1 / 4),
  };

  static final Map<String, double> _numberWords = {
    ..._numbers(const ['واحد', 'واحدة', 'وحدة', 'one'], 1),
    ..._numbers(const ['اثنين', 'اتنين', 'تنين', 'ثنتين', 'two'], 2),
    ..._numbers(const ['ثلاثة', 'ثلاث', 'تلاتة', 'تلات', 'three'], 3),
    ..._numbers(const ['اربعة', 'اربع', 'four'], 4),
    ..._numbers(const ['خمسة', 'خمس', 'five'], 5),
    ..._numbers(const ['ستة', 'ست', 'six'], 6),
    ..._numbers(const ['سبعة', 'سبع', 'seven'], 7),
    ..._numbers(const ['ثمانية', 'تمانية', 'تمنية', 'eight'], 8),
    ..._numbers(const ['تسعة', 'تسع', 'nine'], 9),
    ..._numbers(const ['عشرة', 'عشر', 'ten'], 10),
    ..._numbers(_articles.toList(), 1),
    ..._fractions,
  };

  /// One, but only before the thing: "vitamin a" has no quantity.
  static const _articles = {'a', 'an'};

  /// Real words that start with و, so it is not an "and" stuck to the next
  /// word. The quantity words among them are read as numbers.
  static final Set<String> _wordsWithWaw = const {
    'واحد', 'واحدة', 'وحدة', 'ورق', 'ورقة', 'ورد', 'وردة', 'وجبة', 'وجبات', //
    'وافل', 'ويفر', 'وسادة', 'ولاعة', 'وسط', 'وطني', 'وزن',
  }.map(fold).toSet();

  static final Set<String> _fillers = const {
    'بدي', 'بدنا', 'اريد', 'نريد', 'ابي', 'ابغى', 'هات', 'هاتلي', 'جيب', //
    'جيبلي', 'جبلي', 'اعطيني', 'عطيني', 'اطلب', 'ضيف', 'ضيفلي', 'كمان', //
    'كذلك', 'ايضا', 'اشتري', 'please', 'pls', 'plz', 'i', 'want', 'need', //
    'get', 'buy', 'add', 'give', 'me', 'also', 'some',
  }.map(fold).toSet();

  /// Comes between a quantity and its product: "كيلو من", "a kilo of".
  static const _linkWords = {'من', 'of'};

  /// A number with no unit bigger than this is part of a name ("بيبسي 330").
  static const _biggestBareNumber = 99;

  static List<ParsedItem> parse(String text) {
    final items = <ParsedItem>[];
    for (final segment in _segments(_clean(text))) {
      final item = _item(segment);
      if (item != null) items.add(item);
    }
    return items;
  }

  /// The size written in a product name or an option: "لبنة ٥٠٠ غ" is half a
  /// kilo, "Milk 1L" is a litre and "Eggs (tray of 30)" is 30 pieces. Null if
  /// it has none.
  static PackSize? packOf(String text) {
    final cleaned = _clean(text.replaceAll(RegExp('[()]'), ' '));
    final tokens = [
      for (final token in _tokens(cleaned))
        if (!_linkWords.contains(fold(token))) token,
    ];
    for (var i = 0; i < tokens.length; i++) {
      final word = fold(tokens[i]);
      final next = i + 1 < tokens.length
          ? double.tryParse(tokens[i + 1])
          : null;
      if (_units[word]?.measure == null && _units.containsKey(word)) {
        if (next != null) return PackSize(next, ItemMeasure.pieces);
        continue;
      }
      if (_numberWords.containsKey(word) && _articles.contains(word)) continue;
      final found = _quantityAt(tokens, i);
      final measure = found?.measure;
      if (found != null && measure != null) {
        return PackSize(found.value, measure);
      }
    }
    return null;
  }

  /// Everything that has one meaning however it was typed: digits, marks, the
  /// English "and", and a decimal comma, which must survive splitting the list
  /// on commas.
  static String _clean(String text) {
    final digits = StringBuffer();
    for (final code in text.runes) {
      if (code >= 0x660 && code <= 0x669) {
        digits.write(code - 0x660);
      } else if (code >= 0x6F0 && code <= 0x6F9) {
        digits.write(code - 0x6F0);
      } else {
        digits.writeCharCode(code);
      }
    }
    return digits
        .toString()
        .replaceAll(RegExp('[ً-ٰٟـ]'), '')
        .replaceAll('٫', '.')
        .replaceAllMapped(
          RegExp(r'(\d),(\d)'),
          (match) => '${match[1]}.${match[2]}',
        )
        .replaceAll('½', ' 0.5 ')
        .replaceAll('¼', ' 0.25 ')
        .replaceAllMapped(RegExp(r'\b(\d)/([1-9])\b'), _fraction)
        .replaceAll(RegExp('لو سمحتي|لو سمحت|من فضلك|الله يخليك'), ' ')
        // "and a half" is the English "ونص", and is read the same way.
        .replaceAllMapped(
          _word(r'and\s+(?:an?\s+)?(half|quarter)'),
          (match) => 'و${match[1]}',
        )
        .replaceAllMapped(
          _word(r'an?\s+(half|quarter)'),
          (match) => '${match[1]}',
        )
        .replaceAllMapped(
          _word(r'(half|quarter)\s+an?'),
          (match) => '${match[1]}',
        )
        .replaceAll(_word('and'), ' و ')
        .replaceAll(RegExp(r'\s&\s'), ' و ')
        // A lone "و" joins the next word, so there is only one case to read.
        .replaceAllMapped(RegExp(r'(^|\s)و\s+'), (match) => '${match[1]}و')
        .replaceAll(RegExp(r'(?<=\d)\s*[xX×*]|[xX×*]\s*(?=\d)'), ' ');
  }

  static String _fraction(Match match) =>
      '${int.parse(match[1]!) / int.parse(match[2]!)}';

  static RegExp _word(String pattern) =>
      RegExp('\\b$pattern\\b', caseSensitive: false);

  /// "2kg" is two words, and so is "و2kg": the number and its unit.
  static List<String> _tokens(String chunk) {
    final tokens = <String>[];
    for (final token in chunk.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final parts = RegExp(r'^(و?\d+(?:\.\d+)?)(\D+)$').firstMatch(token);
      final unit = parts == null ? null : fold(parts[2]!);
      if (_units.containsKey(unit) || _duals.containsKey(unit)) {
        tokens.addAll([parts![1]!, parts[2]!]);
      } else {
        tokens.add(token);
      }
    }
    return tokens;
  }

  /// Splits on new lines, ، , ؛ ; and the word "و", which Arabic sticks to the
  /// next word: the list "بندورة وخيار" has two items, "ورق عنب" has one, and
  /// "كيلو ونص بندورة" is one item with a fraction.
  static List<List<String>> _segments(String text) {
    final segments = <List<String>>[];
    for (final chunk in text.split(RegExp(r'[\n\r،,؛;]+'))) {
      var current = <String>[];
      for (final token in _tokens(chunk)) {
        if (token == 'و') {
          segments.add(current);
          current = [];
        } else if (_startsNewItem(token, current)) {
          segments.add(current);
          current = [token.substring(1)];
        } else {
          current.add(token);
        }
      }
      segments.add(current);
    }
    return segments;
  }

  static bool _startsNewItem(String token, List<String> current) {
    if (!token.startsWith('و') || _wordsWithWaw.contains(fold(token))) {
      return false;
    }
    final isFraction = _fractions.containsKey(fold(token.substring(1)));
    return !(isFraction && current.isNotEmpty && _endsWithAmount(current));
  }

  static bool _endsWithAmount(List<String> tokens) {
    final last = fold(tokens.last);
    return _units.containsKey(last) ||
        _duals.containsKey(last) ||
        double.tryParse(last) != null;
  }

  static ParsedItem? _item(List<String> segment) {
    final tokens = [
      for (final token in segment)
        if (!_fillers.contains(fold(token))) token,
    ];
    if (tokens.isEmpty) return null;
    final leading = _quantityAt(tokens, 0);
    final trailing = leading == null ? _quantityAtEnd(tokens) : null;
    final found = leading ?? trailing;
    final words = leading != null
        ? tokens.sublist(leading.end)
        : tokens.sublist(0, trailing?.start ?? tokens.length);
    final name = _nameOf(words);
    if (name.isEmpty) return null;
    final value = found?.value ?? 1;
    final qty = value < 1 ? 1 : value.ceil();
    final measure = found?.measure;
    return ParsedItem(
      name: name,
      qty: qty,
      rounded: qty != value,
      wanted: measure == null ? null : PackSize(value, measure),
    );
  }

  static _Found? _quantityAtEnd(List<String> tokens) {
    for (var start = 1; start < tokens.length; start++) {
      if (_articles.contains(fold(tokens[start]))) continue;
      final found = _quantityAt(tokens, start);
      if (found != null && found.end == tokens.length) return found;
    }
    return null;
  }

  /// A fraction written after an amount: "ونص" or "and a half".
  static double? _extraFraction(List<String> tokens, int index) {
    if (index >= tokens.length) return null;
    final word = fold(tokens[index]);
    return word.startsWith('و') ? _fractions[word.substring(1)] : null;
  }

  /// Reads "2 كيلو", "كيلوين", "كيلو ونص", "نص كيلو", "half a dozen" or
  /// "تلاتة" from [start].
  static _Found? _quantityAt(List<String> tokens, int start) {
    final word = fold(tokens[start]);
    final number = _numberWords[word] ?? double.tryParse(word);
    var end = start + 1;
    double value;
    ItemMeasure? measure;
    final dual = _duals[word];
    final unit = _units[word];
    if (dual != null) {
      value = 2;
      measure = dual.measure;
    } else if (unit != null) {
      value = unit.size;
      measure = unit.measure;
      final next = end < tokens.length ? fold(tokens[end]) : '';
      if (_numberWords[next] == 1 && !_articles.contains(next)) end++;
    } else if (number != null) {
      value = number;
      final extra = _extraFraction(tokens, end);
      if (extra != null) {
        value += extra;
        end++;
      }
      final after = end < tokens.length ? _units[fold(tokens[end])] : null;
      if (after != null) {
        value *= after.size;
        measure = after.measure;
        end++;
      } else if (number > _biggestBareNumber) {
        return null;
      }
    } else {
      return null;
    }
    final extra = _extraFraction(tokens, end);
    if (extra != null) {
      value += extra;
      end++;
    }
    return (value: value, measure: measure, start: start, end: end);
  }

  /// "من البندورة" is searched as "بندورة": the search looks for the exact text.
  static String _nameOf(List<String> words) {
    final kept = [...words];
    if (kept.isNotEmpty && _linkWords.contains(fold(kept.first))) {
      kept.removeAt(0);
    }
    if (kept.isNotEmpty && fold(kept.first) == 'the') kept.removeAt(0);
    if (kept.isEmpty) return '';
    final first = kept.first;
    if (first.startsWith('ال') && first.length > 3) {
      kept[0] = first.substring(2);
    }
    return kept.join(' ');
  }
}

typedef _Found = ({double value, ItemMeasure? measure, int start, int end});
