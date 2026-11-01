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
