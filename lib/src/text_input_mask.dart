import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'magic_mask.dart';

/// TextInputMask extends the TextInputFormatter to make your life better!
/// Just initiate it with the mask as string and it's done.
class TextInputMask extends TextInputFormatter with MagicMask {
  String mask;
  bool reverse;
  int maxLength;

  /// [mask] is the String to be used as mask.
  /// [reverse] is a bool. When true it will mask on reverse mode, usually to be used on currency fields.
  /// [maxLength] can be used to limit the maximum length. Leave it null or -1 to not limitate
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
  TextInputMask({this.mask, this.reverse = false, this.maxLength = -1}) {
    buildMaskTokens(mask);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      return TextEditingValue.fromJSON(executeMasking(
          newValue.text, newValue.selection.baseOffset, reverse, maxLength));
    } catch (e) {
      print(e);
    }
    return newValue;
  }
}
