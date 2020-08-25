import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'magic_mask.dart';

class TextInputMask extends TextInputFormatter with MagicMask {
  String mask;
  bool reverse;
  int maxLength;

  TextInputMask({this.mask, this.reverse = false, this.maxLength = -1}) {
    buildMaskTokens(mask);
  }

  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      TextEditingValue.fromJSON(executeMasking(
          newValue.text, newValue.selection.baseOffset, reverse, maxLength));
}
