/// One line of a shopping list. [qty] is what goes to the API, always a whole
/// number. [rounded] means the customer asked for something else, like half a
/// kilo, and must be told.
class ParsedItem {
  const ParsedItem({
    required this.name,
    required this.qty,
    this.rounded = false,
  });

  final String name;
  final int qty;
  final bool rounded;
}

/// Reads a free text Arabic list such as
/// "كيلو بندورة وكيلو بطاطا ونص كيلو خيار، 2 لتر حليب".
/// It only reads text: it knows nothing about products or the server.
abstract final class ListParser {
  /// Writing a word with ه instead of ة, or ا instead of أ, is still that word.
  static String fold(String text) => text
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');

  static Set<String> _folded(List<String> words) => words.map(fold).toSet();

  /// One unit is worth this many kilos or items. Grams are 1/1000 of a kilo.
  static final Map<String, double> _units = {
    for (final word in _folded(const [
      'كيلو', 'كلو', 'كيلوغرام', 'كيلوجرام', 'كغ', 'كغم', 'كجم', //
      'لتر', 'ليتر', 'علبة', 'علب', 'حبة', 'حبات', 'حبه', 'قطعة', 'قطع', //
      'كيس', 'اكياس', 'زجاجة', 'قنينة', 'ربطة', 'ربطات', 'ضمة', 'باكيت', //
      'كرتونة', 'طبق',
    ]))
      word: 1,
    for (final word in _folded(const ['غرام', 'غم', 'غ', 'جرام', 'جم']))
      word: 1 / 1000,
  };

  /// The Arabic form that means "two of": "كيلوين" is 2 kilos.
  static final Set<String> _duals = _folded(const [
    'كيلوين', 'كلوين', 'لترين', 'ليترين', 'علبتين', 'حبتين', 'قطعتين', //
    'كيسين', 'زجاجتين', 'قنينتين', 'ربطتين', 'ضمتين', 'باكيتين', //
    'كرتونتين', 'طبقين',
  ]);

  static final Map<String, double> _numberWords = {
    for (final word in _folded(const ['واحد', 'واحدة', 'وحدة'])) word: 1,
    for (final word in _folded(const ['اثنين', 'اتنين', 'تنين', 'ثنتين']))
      word: 2,
    for (final word in _folded(const ['ثلاثة', 'ثلاث', 'تلاتة', 'تلات']))
      word: 3,
    for (final word in _folded(const ['اربعة', 'اربع'])) word: 4,
    for (final word in _folded(const ['خمسة', 'خمس'])) word: 5,
    for (final word in _folded(const ['ستة', 'ست'])) word: 6,
    for (final word in _folded(const ['سبعة', 'سبع'])) word: 7,
    for (final word in _folded(const ['ثمانية', 'تمانية', 'تمنية'])) word: 8,
    for (final word in _folded(const ['تسعة', 'تسع'])) word: 9,
    for (final word in _folded(const ['عشرة', 'عشر'])) word: 10,
    ..._fractions,
  };

  static final Map<String, double> _fractions = {
    for (final word in _folded(const ['نص', 'نصف'])) word: 1 / 2,
    for (final word in _folded(const ['ثلث', 'تلت'])) word: 1 / 3,
    fold('ربع'): 1 / 4,
  };

  /// Real words that start with و, so it is not an "and" stuck to the next
  /// word. The quantity words among them are read as numbers.
  static final Set<String> _wordsWithWaw = _folded(const [
    'واحد', 'واحدة', 'وحدة', 'ورق', 'ورقة', 'ورد', 'وردة', 'وجبة', 'وجبات', //
    'وافل', 'ويفر', 'وسادة', 'ولاعة', 'وسط', 'وطني', 'وزن',
  ]);

  static final Set<String> _fillers = _folded(const [
    'بدي', 'بدنا', 'اريد', 'نريد', 'ابي', 'ابغى', 'هات', 'هاتلي', 'جيب', //
    'جيبلي', 'جبلي', 'اعطيني', 'عطيني', 'اطلب', 'ضيف', 'ضيفلي', 'كمان', //
    'كذلك', 'ايضا', 'اشتري',
  ]);

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

  /// Everything that has one meaning however it was typed: digits, marks, and
  /// a decimal comma, which must survive splitting the list on commas.
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
        .replaceAll(RegExp(r'\b1/2\b'), '0.5')
        .replaceAll(RegExp(r'\b1/4\b'), '0.25')
        .replaceAll(RegExp('لو سمحتي|لو سمحت|من فضلك|الله يخليك'), ' ')
        // A lone "و" joins the next word, so there is only one case to read.
        .replaceAllMapped(RegExp(r'(^|\s)و\s+'), (match) => '${match[1]}و')
        .replaceAll(RegExp(r'(?<=\d)\s*[xX×*]|[xX×*]\s*(?=\d)'), ' ');
  }

  /// Splits on new lines, ، , ؛ ; and the word "و", which Arabic sticks to the
  /// next word: the list "بندورة وخيار" has two items, "ورق عنب" has one, and
  /// "كيلو ونص بندورة" is one item with a fraction.
  static List<List<String>> _segments(String text) {
    final segments = <List<String>>[];
    for (final chunk in text.split(RegExp(r'[\n\r،,؛;]+'))) {
      var current = <String>[];
      for (final token in chunk.split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
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
    return !(isFraction && current.isNotEmpty && _endsWithUnit(current));
  }

  static bool _endsWithUnit(List<String> tokens) {
    final last = fold(tokens.last);
    return _units.containsKey(last) || _duals.contains(last);
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
    return ParsedItem(name: name, qty: qty, rounded: qty != value);
  }

  static ({double value, int start, int end})? _quantityAtEnd(
    List<String> tokens,
  ) {
    for (var start = 1; start < tokens.length; start++) {
      final found = _quantityAt(tokens, start);
      if (found != null && found.end == tokens.length) return found;
    }
    return null;
  }

  /// Reads "2 كيلو", "كيلوين", "كيلو ونص", "نص كيلو" or "تلاتة" from [start].
  static ({double value, int start, int end})? _quantityAt(
    List<String> tokens,
    int start,
  ) {
    final word = fold(tokens[start]);
    final number = _numberWords[word] ?? double.tryParse(word);
    var end = start + 1;
    double value;
    if (_duals.contains(word)) {
      value = 2;
    } else if (_units.containsKey(word)) {
      value = _units[word]!;
      final next = end < tokens.length ? fold(tokens[end]) : '';
      if (_numberWords[next] == 1) end++;
    } else if (number != null) {
      value = number;
      final unit = end < tokens.length ? _units[fold(tokens[end])] : null;
      if (unit != null) {
        value *= unit;
        end++;
      } else if (number > _biggestBareNumber) {
        return null;
      }
    } else {
      return null;
    }
    if (end < tokens.length) {
      final next = fold(tokens[end]);
      final fraction = next.startsWith('و')
          ? _fractions[next.substring(1)]
          : null;
      if (fraction != null) {
        value += fraction;
        end++;
      }
    }
    return (value: value, start: start, end: end);
  }

  /// "من البندورة" is searched as "بندورة": the search looks for the exact text.
  static String _nameOf(List<String> words) {
    final kept = [...words];
    if (kept.isNotEmpty && kept.first == 'من') kept.removeAt(0);
    if (kept.isEmpty) return '';
    final first = kept.first;
    if (first.startsWith('ال') && first.length > 3) {
      kept[0] = first.substring(2);
    }
    return kept.join(' ');
  }
}
