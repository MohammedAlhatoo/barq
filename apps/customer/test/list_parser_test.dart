import 'package:barq_customer/features/assistant/data/list_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void _expect(String text, List<(String, int, bool)> expected) {
  final items = ListParser.parse(text);
  expect(
    items.map((item) => (item.name, item.qty, item.rounded)).toList(),
    expected,
    reason: text,
  );
}

void main() {
  group('splitting', () {
    test('the example of the spec', () {
      _expect('كيلو بندورة وكيلو بطاطا وكيلو خيار ولتر حليب', [
        ('بندورة', 1, false),
        ('بطاطا', 1, false),
        ('خيار', 1, false),
        ('حليب', 1, false),
      ]);
    });

    test('a و with spaces around it', () {
      _expect('بندورة و خيار', [('بندورة', 1, false), ('خيار', 1, false)]);
    });

    test('a و stuck to a name with no quantity', () {
      _expect('خبز وبيض ولبنة', [
        ('خبز', 1, false),
        ('بيض', 1, false),
        ('لبنة', 1, false),
      ]);
    });

    test('Arabic and Western commas', () {
      _expect('حليب، بيض, موز', [
        ('حليب', 1, false),
        ('بيض', 1, false),
        ('موز', 1, false),
      ]);
    });

    test('new lines', () {
      _expect('كيلو موز\n2 لتر حليب\r\nبيض', [
        ('موز', 1, false),
        ('حليب', 2, false),
        ('بيض', 1, false),
      ]);
    });

    test('a word that starts with و stays whole', () {
      _expect('ورق عنب وخبز', [('ورق عنب', 1, false), ('خبز', 1, false)]);
    });

    test('a name of two words stays whole', () {
      _expect('2 خبز عربي', [('خبز عربي', 2, false)]);
    });

    test('an empty or punctuation only text has no items', () {
      expect(ListParser.parse(''), isEmpty);
      expect(ListParser.parse('  ،, \n و '), isEmpty);
    });

    test('a quantity with no product is dropped', () {
      expect(ListParser.parse('كيلو'), isEmpty);
      expect(ListParser.parse('2 كيلو'), isEmpty);
    });
  });

  group('quantities', () {
    test('Western digits with a unit', () {
      _expect('2 كيلو بندورة', [('بندورة', 2, false)]);
    });

    test('Arabic digits with a unit', () {
      _expect('٣ كيلو بطاطا و٢ لتر حليب', [
        ('بطاطا', 3, false),
        ('حليب', 2, false),
      ]);
    });

    test('the dual forms', () {
      _expect('كيلوين بندورة ولترين حليب وعلبتين لبنة وحبتين خيار', [
        ('بندورة', 2, false),
        ('حليب', 2, false),
        ('لبنة', 2, false),
        ('خيار', 2, false),
      ]);
    });

    test('علبة and حبة are one each', () {
      _expect('علبة لبنة وحبة خيار', [('لبنة', 1, false), ('خيار', 1, false)]);
    });

    test('number words', () {
      _expect('تلاتة كيلو موز وخمس حبات خيار واتنين حليب', [
        ('موز', 3, false),
        ('خيار', 5, false),
        ('حليب', 2, false),
      ]);
    });

    test('a number with no unit', () {
      _expect('3 بيض', [('بيض', 3, false)]);
    });

    test('the quantity after the name', () {
      _expect('بندورة كيلو، حليب 2، بطاطا 3 كيلو، خيار كيلوين', [
        ('بندورة', 1, false),
        ('حليب', 2, false),
        ('بطاطا', 3, false),
        ('خيار', 2, false),
      ]);
    });

    test('a multiplier sign', () {
      _expect('حليب ×3', [('حليب', 3, false)]);
      _expect('2x حليب', [('حليب', 2, false)]);
      _expect('xbox', [('xbox', 1, false)]);
    });

    test('ه instead of ة in a unit', () {
      _expect('علبه لبنة', [('لبنة', 1, false)]);
    });

    test('kilo with the word for one', () {
      _expect('كيلو واحد موز', [('موز', 1, false)]);
    });

    test('a big bare number belongs to the name', () {
      _expect('بيبسي 330', [('بيبسي 330', 1, false)]);
    });
  });

  group('rounding halves up', () {
    test('half a kilo becomes 1 and is reported', () {
      _expect('نص كيلو خيار', [('خيار', 1, true)]);
    });

    test('نصف and ربع', () {
      _expect('نصف كيلو موز وربع كيلو لبنة', [
        ('موز', 1, true),
        ('لبنة', 1, true),
      ]);
    });

    test('kilo and a half is not split on its و', () {
      _expect('كيلو ونص بندورة وكيلو خيار', [
        ('بندورة', 2, true),
        ('خيار', 1, false),
      ]);
    });

    test('the same with a space after و', () {
      _expect('كيلو و نص بندورة', [('بندورة', 2, true)]);
    });

    test('a half after a product starts a new item', () {
      _expect('كيلو بندورة ونص كيلو خيار', [
        ('بندورة', 1, false),
        ('خيار', 1, true),
      ]);
    });

    test('decimals', () {
      _expect('1.5 كيلو موز و٢٫٥ كيلو بطاطا و1,5 لتر حليب', [
        ('موز', 2, true),
        ('بطاطا', 3, true),
        ('حليب', 2, true),
      ]);
    });

    test('fractions as signs', () {
      _expect('1/2 كيلو موز', [('موز', 1, true)]);
      _expect('½ كيلو موز', [('موز', 1, true)]);
    });

    test('grams', () {
      _expect('500 غرام لبنة', [('لبنة', 1, true)]);
      _expect('2000 غرام بطاطا', [('بطاطا', 2, false)]);
    });
  });

  group('what was asked for is kept', () {
    void expectWanted(String text, double amount, ItemMeasure measure) {
      final wanted = ListParser.parse(text).single.wanted;
      expect(wanted?.amount, closeTo(amount, 0.0001), reason: text);
      expect(wanted?.measure, measure, reason: text);
    }

    test('نص كيلو', () {
      _expect('نص كيلو بندورة', [('بندورة', 1, true)]);
      expectWanted('نص كيلو بندورة', 0.5, ItemMeasure.weight);
    });

    test('كيلو ونص', () {
      _expect('كيلو ونص بندورة', [('بندورة', 2, true)]);
      expectWanted('كيلو ونص بندورة', 1.5, ItemMeasure.weight);
    });

    test('ربع', () {
      _expect('ربع كيلو لبنة', [('لبنة', 1, true)]);
      expectWanted('ربع كيلو لبنة', 0.25, ItemMeasure.weight);
    });

    test('كيلو وربع and two and a half', () {
      expectWanted('كيلو وربع موز', 1.25, ItemMeasure.weight);
      expectWanted('2 ونص كيلو موز', 2.5, ItemMeasure.weight);
    });

    test('litres and pieces', () {
      expectWanted('لتر ونص حليب', 1.5, ItemMeasure.volume);
      expectWanted('5 حبات خيار', 5, ItemMeasure.pieces);
    });

    test('a box has no measure', () {
      expect(ListParser.parse('علبة لبنة').single.wanted, isNull);
      expect(ListParser.parse('3 بيض').single.wanted, isNull);
    });
  });

  group('the size in a product name', () {
    void expectPack(String name, double? amount, [ItemMeasure? measure]) {
      final pack = ListParser.packOf(name);
      expect(pack?.amount, amount, reason: name);
      expect(pack?.measure, measure, reason: name);
    }

    test('Arabic names', () {
      expectPack('بندورة ١ كغ', 1, ItemMeasure.weight);
      expectPack('لبنة ٥٠٠ غ', 0.5, ItemMeasure.weight);
      expectPack('حليب ١ لتر', 1, ItemMeasure.volume);
      expectPack('بيض (طبق ٣٠)', 30, ItemMeasure.pieces);
      expectPack('خبز عربي (ربطة)', null);
      expectPack('سائل جلي', null);
    });

    test('English names', () {
      expectPack('Tomatoes 1 kg', 1, ItemMeasure.weight);
      expectPack('Potatoes 1kg', 1, ItemMeasure.weight);
      expectPack('Labneh 500g', 0.5, ItemMeasure.weight);
      expectPack('Milk 1L', 1, ItemMeasure.volume);
      expectPack('Eggs (tray of 30)', 30, ItemMeasure.pieces);
      expectPack('Arabic Bread (bundle)', null);
    });

    test('a choice label', () {
      expectPack('500 غ', 0.5, ItemMeasure.weight);
      expectPack('نص كيلو', 0.5, ItemMeasure.weight);
    });
  });

  group('English', () {
    test('the example of the spec', () {
      _expect('1 kg tomatoes, 2 kg potatoes and 1 liter milk', [
        ('tomatoes', 1, false),
        ('potatoes', 2, false),
        ('milk', 1, false),
      ]);
    });

    test('new lines and a comma before and', () {
      _expect('bread\n2 milk, eggs, and rice', [
        ('bread', 1, false),
        ('milk', 2, false),
        ('eggs', 1, false),
        ('rice', 1, false),
      ]);
    });

    test('every spelling of kilo and litre', () {
      _expect('2 kilos of rice, 3 litres milk, 1 kilogram sugar, 2 l water', [
        ('rice', 2, false),
        ('milk', 3, false),
        ('sugar', 1, false),
        ('water', 2, false),
      ]);
    });

    test('a number stuck to its unit', () {
      _expect('2kg potatoes and 500g labneh', [
        ('potatoes', 2, false),
        ('labneh', 1, true),
      ]);
    });

    test('half and quarter', () {
      _expect('half a kilo of tomatoes and a quarter kg cheese', [
        ('tomatoes', 1, true),
        ('cheese', 1, true),
      ]);
    });

    test('and a half stays with its amount', () {
      _expect('1 and a half kg tomatoes and 1 kg potatoes', [
        ('tomatoes', 2, true),
        ('potatoes', 1, false),
      ]);
      _expect('a kilo and a half of rice', [('rice', 2, true)]);
    });

    test('pack, box and piece', () {
      _expect('2 packs of labneh, a box of tea, 3 pieces cucumber', [
        ('labneh', 2, false),
        ('tea', 1, false),
        ('cucumber', 3, false),
      ]);
    });

    test('a dozen is twelve pieces', () {
      _expect('a dozen eggs and half a dozen bananas', [
        ('eggs', 12, false),
        ('bananas', 6, false),
      ]);
      expect(
        ListParser.parse('a dozen eggs').single.wanted?.measure,
        ItemMeasure.pieces,
      );
    });

    test('دزينة too', () {
      _expect('دزينة بيض', [('بيض', 12, false)]);
    });

    test('number words and capitals', () {
      _expect('Two KG Tomatoes and ONE Liter Milk', [
        ('Tomatoes', 2, false),
        ('Milk', 1, false),
      ]);
    });

    test('the quantity after the name', () {
      _expect('tomatoes 2 kg, milk x3', [
        ('tomatoes', 2, false),
        ('milk', 3, false),
      ]);
    });

    test('request words', () {
      _expect('please get me 2 kg of the tomatoes', [('tomatoes', 2, false)]);
      _expect('I need some rice', [('rice', 1, false)]);
    });

    test('a letter that only looks like a quantity', () {
      _expect('vitamin a', [('vitamin a', 1, false)]);
    });

    test('a word with a unit inside it stays whole', () {
      _expect('2 canned beans', [('canned beans', 2, false)]);
    });

    test('a quantity with no product is dropped', () {
      expect(ListParser.parse('2 kg'), isEmpty);
      expect(ListParser.parse('and'), isEmpty);
    });
  });

  group('mixed lists', () {
    test('English units with Arabic names', () {
      _expect('2 kg بندورة and 1 liter حليب', [
        ('بندورة', 2, false),
        ('حليب', 1, false),
      ]);
    });

    test('Arabic units with English names', () {
      _expect('كيلو tomatoes وكيلوين potatoes', [
        ('tomatoes', 1, false),
        ('potatoes', 2, false),
      ]);
    });

    test('both ways of saying and in one list', () {
      _expect('لتر حليب and 1 kg rice و نص كيلو خيار, eggs', [
        ('حليب', 1, false),
        ('rice', 1, false),
        ('خيار', 1, true),
        ('eggs', 1, false),
      ]);
    });

    test('Arabic digits with English words', () {
      _expect('٢ kg tomatoes', [('tomatoes', 2, false)]);
    });
  });

  group('words around the list', () {
    test('polite and request words', () {
      _expect('بدي كيلو بندورة لو سمحت', [('بندورة', 1, false)]);
      _expect('جيبلي لتر حليب من فضلك', [('حليب', 1, false)]);
      _expect('لتر حليب لو سمحتي', [('حليب', 1, false)]);
    });

    test('من and ال are not part of the name', () {
      _expect('كيلو من البندورة', [('بندورة', 1, false)]);
      _expect('كيلو الرز', [('رز', 1, false)]);
    });

    test('short names keep their first letters', () {
      _expect('الو', [('الو', 1, false)]);
    });

    test('marks are removed', () {
      _expect('كِيلو بَندورة', [('بندورة', 1, false)]);
    });
  });
}
