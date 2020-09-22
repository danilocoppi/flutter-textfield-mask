import 'package:easy_mask/src/magic_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Brazilian Cellphone', () {
    String baseMask = '\\+99? (99) 99999 - 9999?';
    String basetest = '5519981234567';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 3, false, -1, '', 0);
    print(result);
    expect(result['text'], '+55 (19) 98123 - 4567');
    expect(result['selectionBase'], 6);
  });

  test('Brazilian Personal Document', () {
    String baseMask = '999.999.999-99';
    String basetest = '123123HUM12344';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '123.123.123-44');
    expect(result['selectionBase'], 5);
  });

  test('USA Celphone', () {
    String baseMask = '\\+1 (999) 999 99 99';
    String basetest = '446667AAAAAA8899';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '+1 (446) 667 88 99');
    expect(result['selectionBase'], 10);
  });

  test('Credit Card', () {
    String baseMask = '9999 9999 9999 9999';
    String basetest = '1234555@#566667878';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '1234 5555 6666 7878');
    expect(result['selectionBase'], 4);
  });

  test('Reversed Money without thousand separator comma', () {
    String baseMask = '\$! !9+.99';
    String basetest = '1025065';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 7, true, -1, '', 0);
    print(result);
    expect(result['text'], '\$ 10250.65');
    expect(result['selectionBase'], 10);
  });

  test('Reversed Money with thousand separator comma', () {
    String baseMask = '\$! !9+,999.99';
    String basetest = '1025065A';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 7, true, -1, '', 0);
    print(result);
    expect(result['text'], '\$ 10,250.65');
    expect(result['selectionBase'], 11);
  });

  test('Custom Masks', () {
    String baseMask = '99 AA 999';
    String basetest = '33xyz.@999';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(basetest, 7, false, -1, '', 0);
    print(result);
    expect(result['text'], '33 xy 999');
    expect(result['selectionBase'], 5);
  });

  test('Simple text', () {
    String text = '432516565';
    MagicMask mask = MagicMask.buildMask('\\+99 (99) 99999-9999');
    var res = mask.getMaskedString(text);
    print(res);
  });
}
