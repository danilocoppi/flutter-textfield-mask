import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'magic_mask.dart';

/// TextInputMask extends the TextInputFormatter to make your life better!
/// Just initiate it with the mask as string and it's done.
class TextInputMask extends TextInputFormatter {
  dynamic mask;
  String placeholder;
  bool reverse;
  int maxLength;
  int maxPlaceHolders;
  late MagicMask magicMask;

  /// [mask] is the String or Array of Strings to be used as mask(s).
  /// [reverse] is a bool. When true it will mask on reverse mode, usually to be used on currency fields.
  /// [maxLength] can be used to limit the maximum length. Leave it null or -1 to not limitate
  /// [placeholder] is a string to be applyed on untyped characters.
  /// [maxPlaceHolders] max times a placeholder is counted. Typed characters consumes the counter.
  /// ex placeholder as '0' with max=3 on a text like '3' with mask 9+.99 will be 0.03 not 000000.03
  ///
  /// The allowed patterns to it are:
  ///
  /// 9 - is used to allow a number from 0-9
  ///
  /// A - is used to allow a letter from a-z or A-Z
  ///
  /// N - is used to allow a number or letter from 0-9, a-z or A-Z
  ///
  /// X - is used to allow any character
  ///
  /// **Those tokens 9,A,N and X can be followed by one following modifier**
  ///
  /// \? - indicates that is optional
  ///
  /// \+ - indicates that must have at least 1 or more repetitions
  ///
  /// \* - indicates that can have 0 or more repetitions
  ///
  /// \ - is used as scape
  ///
  /// ** Any character that is interpreted as letter to be placed, can be followed by modifier **
  ///
  /// \! - Used to force print it, when it has at least 1 letter
  ///
  /// When passing an array of String as mask, the first mask applyed is the shortest going to longest.
  /// It will apply the next mask (bigger one, only when the typed text overflow the previous mask)
  TextInputMask(
      {this.mask,
      this.reverse = false,
      this.maxLength = -1,
      this.placeholder = '',
      this.maxPlaceHolders = -1}) {
    magicMask = MagicMask.buildMask(mask);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      return TextEditingValue.fromJSON(magicMask.executeMasking(
          newValue.text,
          newValue.selection.baseOffset,
          reverse,
          maxLength,
          placeholder,
          maxPlaceHolders));
    } catch (e) {
      print(e);
    }
    return newValue;
  }
}
