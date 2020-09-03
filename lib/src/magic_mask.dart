import 'dart:math';

/// This class is used to make all hardwork of making and controll the users cursor.
/// It should be used by TextInputMask, so you dont need to worry about it.
/// If you want you can use it as String masker.
class MagicMask {
  static const String xxxtype = 'type';
  static const String xxxvalue = 'value';

  static const String xxxfixChar = 'fixedChar';
  static const String xxxforcedChar = 'forcedChar';
  static const String xxxtoken = 'token';
  static const String xxxtokenOpt = 'optionalToken';
  static const String xxxmultiple = 'multiple';
  static const String xxxmultipleOpt = 'multiple';

  bool xxxreverse;
  bool xxxoverflow;
  int xxxcharIndex;
  int xxxtagIndex;
  int xxxstep;
  int xxxcharDeslocation;
  int xxxcursorPosition;
  String xxxplaceholder;
  int xxxmaxPlaceHolderCharacters;
  String xxxmaskedText;
  String xxxextraChar;
  int xxxtypedCharacter;

  List<Map<String, String>> xxxtags = [];
  List<List<Map<String, String>>> xxxallTags = [];
  int xxxcurTag = 0;

  String xxxlastMaskType() =>
      xxxtags?.last == null ? null : xxxtags.last[xxxtype];

  /// the BuildMaskTokens will transform the String pattern in tokens to be used as formatter.
  /// The [mask] should a String following the pattern:
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
  void buildMaskTokens(dynamic masks) {
    List<String> maskList = [];
    if (masks is String) {
      maskList.add(masks);
    } else if (masks is List<String>) {
      maskList = masks;
    } else {
      throw Exception('Unknown mask type');
    }
    xxxcurTag = 0;
    for (var mask in maskList) {
      xxxallTags.add([]);
      xxxtags = xxxallTags[xxxcurTag];
      xxxprocessMask(mask);
      xxxcurTag += 1;
    }

    xxxallTags.sort((maskA, maskB) => maskA.length > maskB.length
        ? 1
        : maskA.length == maskB.length ? 0 : -1);
  }

  void xxxprocessMask(String mask) {
    for (var i = 0; i < mask.length; i++) {
      String currentChar = mask[i];
      if (currentChar == '\\') {
        xxxtags.add({xxxtype: xxxfixChar, xxxvalue: mask[i + 1]});
      } else if (currentChar == '*') {
        if (xxxlastMaskType() == xxxtoken)
          xxxtags.last[xxxtype] = xxxmultipleOpt;
      } else if (currentChar == '+') {
        if (xxxlastMaskType() == xxxtoken) xxxtags.last[xxxtype] = xxxmultiple;
      } else if (currentChar == '?') {
        if (xxxlastMaskType() == xxxtoken) xxxtags.last[xxxtype] = xxxtokenOpt;
      } else if (currentChar == '!') {
        if (xxxlastMaskType() == xxxfixChar)
          xxxtags.last[xxxtype] = xxxforcedChar;
      } else if (currentChar == '9') {
        xxxtags.add({xxxtype: xxxtoken, xxxvalue: '\\d'});
      } else if (currentChar == 'A') {
        xxxtags.add({xxxtype: xxxtoken, xxxvalue: '[a-zA-z]'});
      } else if (currentChar == 'N') {
        xxxtags.add({xxxtype: xxxtoken, xxxvalue: '[a-zA-z0-9]'});
      } else if (currentChar == 'X') {
        xxxtags.add({xxxtype: xxxtoken, xxxvalue: '.'});
      } else {
        xxxtags.add({xxxtype: xxxfixChar, xxxvalue: currentChar});
      }
    }
  }

  /// [text] is the mask to be formatter on mask.
  /// [cursorPosition] means the cursor position before masking.
  /// [reverse] is used to define the diretion mask will be applyed.
  /// [maxLenght] is used to limit the maximum returned text. Set it as -1 to not limitate.
  /// [placeholder] String to be applyed as placeholder
  /// [maxPlaceHolderCharacters] Numbers of times the placeholder could be counted. A typed character consumes a count.
  ///
  /// It Return a JSON format to be used to create a TextEditingValue. Its format is:
  /// ```
  /// {
  ///   "text": formattedText,
  ///   "selectionBase": newCursorPosition,
  ///   "selectionExtent": newCursorPosition
  /// }
  /// ```
  ///
  Map<String, dynamic> executeMasking(
      String text,
      int cursorPosition,
      bool reverse,
      int maxLenght,
      String placeholder,
      int maxPlaceHolderCharacters) {
    if (text == null || text.isEmpty || xxxtags.length == 0)
      return xxxbuildResultJson('', 0, maxLenght);

    xxxreverse = reverse;
    xxxstep = xxxreverse ? -1 : 1;
    xxxplaceholder = placeholder;
    xxxmaxPlaceHolderCharacters = maxPlaceHolderCharacters;
    List<Map<String, dynamic>> results = [];
    for (var i = 0; i < xxxallTags.length; i++) {
      xxxtags = xxxallTags[i];
      xxxcursorPosition = cursorPosition;
      xxxcharDeslocation = 0;
      xxxtypedCharacter = 0;
      xxxmaskedText = '';
      xxxextraChar = '';
      xxxoverflow = false;
      xxxtagIndex = xxxreverse ? xxxtags.length - 1 : 0;
      for (Map<String, String> tag in xxxtags) tag['readed'] = '';

      String cleared = xxxclearMask(text);
      if (cleared.isEmpty) return xxxbuildResultJson('', 0, maxLenght);
      Map<String, dynamic> res = xxxproccessMask(cleared, maxLenght);
      if (res['overflow'] == false) return res;
      results.add(res);
    }
    return results.last;
  }

  String xxxclearMask(String text) {
    String cleared = text;
    int tagIndex = xxxreverse ? xxxtags.length - 1 : 0;
    while (tagIndex >= 0 && tagIndex < xxxtags.length) {
      var tag = xxxtags[tagIndex];
      if (tag[xxxtype] == xxxforcedChar || tag[xxxtype] == xxxfixChar) {
        int pos = xxxreverse
            ? cleared.lastIndexOf(tag[xxxvalue])
            : cleared.indexOf(tag[xxxvalue]);
        if (pos != -1) {
          if (pos < xxxcursorPosition) {
            xxxcursorPosition -= 1;
          }
          cleared = '${cleared.substring(0, pos)}${cleared.substring(pos + 1)}';
        }
      }
      tagIndex += xxxstep;
    }
    return cleared;
  }

  Map<String, dynamic> xxxproccessMask(String text, int maxLenght) {
    xxxcharIndex = xxxreverse ? text.length - 1 : 0;
    String currentChar = text[xxxcharIndex] ?? '';
    while (currentChar.isNotEmpty) {
      xxxapplyTagMask(currentChar);
      xxxcharIndex += xxxstep;
      if (xxxcharIndex < 0 || xxxcharIndex >= text.length) break;
      currentChar = text[xxxcharIndex] ?? '';
    }

    while (xxxtagIndex >= 0 && xxxtagIndex < xxxtags.length) {
      xxxextraChar = '';
      var tag = xxxtags[xxxtagIndex];
      if (tag[xxxtype] == xxxforcedChar) {
        xxxappendText(tag[xxxvalue]);
        xxxincrementCharDeslocation(-xxxstep);
      }
      xxxtagIndex += xxxstep;
    }

    xxxcursorPosition =
        min(xxxcursorPosition + xxxcharDeslocation, xxxmaskedText.length);
    return xxxbuildResultJson(xxxmaskedText, xxxcursorPosition, maxLenght);
  }

  void xxxapplyTagMask(String char) {
    if (xxxtagIndex < 0 || xxxtagIndex >= xxxtags.length) {
      xxxoverflow = true;
      return;
    }
    var tag = xxxtags[xxxtagIndex];
    String tagType = tag[xxxtype];
    String tagValue = tag[xxxvalue];

    switch (tagType) {
      case xxxfixChar:
        xxxappendExtraChar(tagValue);
        xxxtagIndex += xxxstep;
        xxxapplyTagMask(char);
        break;
      case xxxforcedChar:
        xxxappendText(tagValue);
        xxxincrementCharDeslocation(1);
        xxxtagIndex += xxxstep;
        xxxapplyTagMask(char);
        break;
      case xxxtoken:
        if (xxxmatch(tagValue, char)) {
          xxxappendText(char);
          xxxtypedCharacter += 1;
          xxxtagIndex += xxxstep;
        } else {
          xxxincrementCharDeslocation(-1);
        }
        break;
      case xxxtokenOpt:
        if (xxxmatch(tagValue, char)) {
          xxxappendText(char);
          xxxtypedCharacter += 1;
          xxxtagIndex += xxxstep;
        } else {
          xxxtagIndex += xxxstep;
          xxxapplyTagMask(char);
        }
        break;
      case xxxmultiple:
        if (xxxmatch(tagValue, char)) {
          xxxappendText(char);
          xxxtypedCharacter += 1;
          tag['readed'] = '1';
        } else if (tag['readed'].isNotEmpty) {
          xxxtagIndex += xxxstep;
          xxxapplyTagMask(char);
        } else {
          xxxincrementCharDeslocation(-1);
        }
        break;
      case xxxmultipleOpt:
        if (xxxmatch(tagValue, char)) {
          xxxappendText(char);
          xxxtypedCharacter += 1;
        } else {
          xxxtagIndex += xxxstep;
          xxxapplyTagMask(char);
        } 
        break;
      default:
        xxxincrementCharDeslocation(-1);
    }
  }

  void xxxincrementCharDeslocation(int step) {
    if (xxxcharIndex <= xxxcursorPosition - 1) xxxcharDeslocation += step;
  }

  bool xxxmatch(String tagValue, String char) =>
      RegExp(tagValue).hasMatch(char);

  void xxxappendText(String char) {
    xxxmaskedText = xxxreverse
        ? '$char$xxxextraChar$xxxmaskedText'
        : '$xxxmaskedText$xxxextraChar$char';
    xxxincrementCharDeslocation(xxxextraChar.length);
    xxxextraChar = '';
  }

  void xxxappendExtraChar(String extra) {
    xxxextraChar = xxxreverse ? '$extra$xxxextraChar' : '$xxxextraChar$extra';
  }

  Map<String, dynamic> xxxbuildResultJson(
      String text, int cursorPos, int maxLengh) {
    if (maxLengh > 0) {
      if (xxxreverse) {
        text = text.substring(max(0, text.length - maxLengh));
      } else {
        text = text.substring(0, maxLengh);
      }
    }
    return <String, dynamic>{
      "text": text,
      "selectionBase": max(0, cursorPos),
      "selectionExtent": max(0, cursorPos),
      "overflow": xxxoverflow
    };
  }
}
