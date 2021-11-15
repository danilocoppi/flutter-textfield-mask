import 'package:easy_mask/src/magic_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('Brazilian Cellphone', () {
    String baseMask = '\\+99? (99) 99999 - 9999?';
    String baseTest = '5519981234567';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 3, false, -1, '', 0);
    print(result);
    expect(result['text'], '+55 (19) 98123 - 4567');
    expect(result['selectionBase'], 6);
  });

  test('Brazilian Personal Document', () {
    String baseMask = '999.999.999-99';
    String baseTest = '123123HUM12344';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '123.123.123-44');
    expect(result['selectionBase'], 5);
  });

  test('USA Celphone', () {
    String baseMask = '\\+1 (999) 999 99 99';
    String baseTest = '446667AAAAAA8899';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '+1 (446) 667 88 99');
    expect(result['selectionBase'], 10);
  });

  test('Credit Card', () {
    String baseMask = '9999 9999 9999 9999';
    String baseTest = '1234555@#566667878';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 4, false, -1, '', 0);
    print(result);
    expect(result['text'], '1234 5555 6666 7878');
    expect(result['selectionBase'], 4);
  });

  test('Reversed Money without thousand separator comma', () {
    String baseMask = '\$! !9+.99';
    String baseTest = '1025065';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 7, true, -1, '', 0);
    print(result);
    expect(result['text'], '\$ 10250.65');
    expect(result['selectionBase'], 10);
  });

  test('Reversed Money with thousand separator comma', () {
    String baseMask = '\$! !9+,999.99';
    String baseTest = '1025065A';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 7, true, -1, '', 0);
    print(result);
    expect(result['text'], '\$ 10,250.65');
    expect(result['selectionBase'], 11);
  });

  test('Custom Masks', () {
    String baseMask = '99 AA 999';
    String baseTest = '33xyz.@999';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 7, false, -1, '', 0);
    print(result);
    expect(result['text'], '33 xy 999');
    expect(result['selectionBase'], 5);
  });

  test('Escape Masks', () {
    String baseMask = '\\9! \\A! AAAA';
    String baseTest = 'Test';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 0, false, -1, '', 0);
    print(result);
    expect(result['text'], '9 A Test');
    expect(result['selectionBase'], 0);
  });

  test('Escape Masks(Time Case)', () {
    String baseMask = '99:99 !\\A!M!';
    String baseTest = '12:30';
    MagicMask mm = MagicMask();
    mm.buildMaskTokens(baseMask);
    var result = mm.executeMasking(baseTest, 0, false, -1, '', 0);
    print(result);
    expect(result['text'], '12:30 AM');
    expect(result['selectionBase'], 0);
  });

  test('Simple text', () {
    String text = '432516565';
    MagicMask mask = MagicMask.buildMask('\\+99 (99) 99999-9999');
    var res = mask.getMaskedString(text);
    expect(res, '+43 (25) 16565');
  });
}
