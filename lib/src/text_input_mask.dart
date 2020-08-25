
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../easy_mask.dart';

class TextInputMask extends TextInputFormatter with MagicMask {
  String mask;
  bool reverse;
  int maxLength;

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
