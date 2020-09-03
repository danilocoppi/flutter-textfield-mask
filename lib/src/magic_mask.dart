import 'dart:math';

/// This class is used to make all hardwork of making and controll the users cursor.
/// It should be used by TextInputMask, so you dont need to worry about it.
/// If you want you can use it as String masker.
class MagicMask {
  static const String _type = 'type';
  static const String _value = 'value';

  static const String _fixChar = 'fixedChar';
  static const String _forcedChar = 'forcedChar';
  static const String _token = 'token';
  static const String _tokenOpt = 'optionalToken';
  static const String _multiple = 'multiple';
  static const String _multipleOpt = 'multiple';

  bool _reverse;
  bool _overflow;
  int _charIndex;
  int _tagIndex;
  int _step;
  int _charDeslocation;
  int _cursorPosition;
  String _placeholder;
  int _maxPlaceHolderCharacters;
  String _maskedText;
  String _extraChar;
  int _typedCharacter;

  List<Map<String, String>> _tags = [];
  List<List<Map<String, String>>> _allTags = [];
  int _curTag = 0;

  String _lastMaskType() => _tags?.last == null ? null : _tags.last[_type];

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
  /// \+ - indicates that must have at least 1 or more repetitions (use as last character)
  ///
  /// \* - indicates that can have 0 or more repetitions (use as last character)
  ///
  /// \ - is used as scape
  ///
  ///
  /// ** Any character that is interpreted as letter to be placed, can be followed by modifier **
  ///
  /// \! - Used to force print it, when it has at least 1 letter
  void buildMaskTokens(dynamic masks) {
    List<String> maskList = [];
    if (masks is String) {
      maskList.add(masks);
    } else if (masks is List<String>) {
      maskList = masks;
    } else {
      throw Exception('Unknown mask type');
    }
    _curTag = 0;
    for (var mask in maskList) {
      _allTags.add([]);
      _tags = _allTags[_curTag];
      _processMask(mask);
      _curTag += 1;
    }

    _allTags.sort((maskA, maskB) => maskA.length > maskB.length
        ? 1
        : maskA.length == maskB.length ? 0 : -1);
  }

  void _processMask(String mask) {
    for (var i = 0; i < mask.length; i++) {
      String currentChar = mask[i];
      if (currentChar == '\\') {
        _tags.add({_type: _fixChar, _value: mask[i + 1]});
      } else if (currentChar == '*') {
        if (_lastMaskType() == _token) _tags.last[_type] = _multipleOpt;
      } else if (currentChar == '+') {
        if (_lastMaskType() == _token) _tags.last[_type] = _multiple;
      } else if (currentChar == '?') {
        if (_lastMaskType() == _token) _tags.last[_type] = _tokenOpt;
      } else if (currentChar == '!') {
        if (_lastMaskType() == _fixChar) _tags.last[_type] = _forcedChar;
      } else if (currentChar == '9') {
        _tags.add({_type: _token, _value: '\\d'});
      } else if (currentChar == 'A') {
        _tags.add({_type: _token, _value: '[a-zA-z]'});
      } else if (currentChar == 'N') {
        _tags.add({_type: _token, _value: '[a-zA-z0-9]'});
      } else if (currentChar == 'X') {
        _tags.add({_type: _token, _value: '.'});
      } else {
        _tags.add({_type: _fixChar, _value: currentChar});
      }
    }
  }

  /// [text] is the mask to be formatter on mask.
  /// [cursorPosition] means the cursor position before masking.
  /// [reverse] is used to define the diretion mask will be applyed.
  /// [maxLenght] is used to limit the maximum returned text. Set it as -1 to not limitate.
  /// [placeholder] String character to be applyed as placeholder
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
    if (text == null || text.isEmpty || _tags.length == 0)
      return _buildResultJson('', 0, maxLenght);

    _reverse = reverse;
    _step = _reverse ? -1 : 1;
    _placeholder = placeholder;
    _maxPlaceHolderCharacters = maxPlaceHolderCharacters;
    List<Map<String, dynamic>> results = [];
    for (var i = 0; i < _allTags.length; i++) {
      _tags = _allTags[i];
      _cursorPosition = cursorPosition;
      _charDeslocation = 0;
      _typedCharacter = 0;
      _maskedText = '';
      _extraChar = '';
      _overflow = false;
      _tagIndex = _reverse ? _tags.length - 1 : 0;
      for (Map<String, String> tag in _tags) tag['readed'] = '';

      String cleared = _clearMask(text);
      cleared = _clearPlaceHolder(cleared);
      if (cleared.isEmpty) return _buildResultJson('', 0, maxLenght);
      Map<String, dynamic> res = _proccessMask(cleared, maxLenght);
      if (res['overflow'] == false) return res;
      results.add(res);
    }
    return results.last;
  }

  String _clearPlaceHolder(String text) {
    int index = _reverse ? 0 : text.length - 1;
    while (index >= 0 && index < text.length && text[index] == _placeholder) {
      text = _reverse ? text.substring(1) : text.substring(0, text.length - 1);
      index -= _step;
    }
    return text;
  }

  String _clearMask(String text) {
    String cleared = text;
    int tagIndex = _reverse ? _tags.length - 1 : 0;
    while (tagIndex >= 0 && tagIndex < _tags.length) {
      var tag = _tags[tagIndex];
      if (tag[_type] == _forcedChar || tag[_type] == _fixChar) {
        int pos = _reverse
            ? cleared.lastIndexOf(tag[_value])
            : cleared.indexOf(tag[_value]);
        if (pos != -1) {
          if (pos < _cursorPosition) {
            _cursorPosition -= 1;
          }
          cleared = '${cleared.substring(0, pos)}${cleared.substring(pos + 1)}';
        }
      }
      tagIndex += _step;
    }
    return cleared;
  }

  Map<String, dynamic> _proccessMask(String text, int maxLenght) {
    _charIndex = _reverse ? text.length - 1 : 0;
    String currentChar = text[_charIndex] ?? '';
    while (currentChar.isNotEmpty) {
      _applyTagMask(currentChar, false);
      _charIndex += _step;
      if (_charIndex < 0 || _charIndex >= text.length) break;
      currentChar = text[_charIndex] ?? '';
    }

    int placeHolderCounter = _maxPlaceHolderCharacters - _typedCharacter;
    if (placeHolderCounter > 0) {
      for (int i = 0; i < placeHolderCounter; i++) {
        _applyTagMask(_placeholder, true);
        if (_charIndex <= _cursorPosition - 1) _charDeslocation += 1;
      }
    }

    while (_tagIndex >= 0 && _tagIndex < _tags.length) {
      _extraChar = '';
      var tag = _tags[_tagIndex];
      if (tag[_type] == _forcedChar) {
        _appendText(tag[_value]);
        _incrementCharDeslocation(-_step);
      }
      _tagIndex += _step;
    }

    _cursorPosition =
        min(_cursorPosition + _charDeslocation, _maskedText.length);
    return _buildResultJson(_maskedText, _cursorPosition, maxLenght);
  }

  void _applyTagMask(String char, bool isPlaceHolder) {
    if (_tagIndex < 0 || _tagIndex >= _tags.length) {
      _overflow = true;
      return;
    }
    var tag = _tags[_tagIndex];
    String tagType = tag[_type];
    String tagValue = tag[_value];

    switch (tagType) {
      case _fixChar:
        _appendExtraChar(tagValue);
        _tagIndex += _step;
        _applyTagMask(char, isPlaceHolder);
        break;
      case _forcedChar:
        _appendText(tagValue);
        _incrementCharDeslocation(1);
        _tagIndex += _step;
        _applyTagMask(char, isPlaceHolder);
        break;
      case _token:
        if (_match(tagValue, char) || isPlaceHolder) {
          _appendText(char);
          _typedCharacter += 1;
          _tagIndex += _step;
        } else {
          _incrementCharDeslocation(-1);
        }
        break;
      case _tokenOpt:
        if (_match(tagValue, char) || isPlaceHolder) {
          _appendText(char);
          _typedCharacter += 1;
          _tagIndex += _step;
        } else {
          _tagIndex += _step;
          _applyTagMask(char, isPlaceHolder);
        }
        break;
      case _multiple:
        if (_match(tagValue, char) || isPlaceHolder) {
          _appendText(char);
          _typedCharacter += 1;
          tag['readed'] = '1';
        } else if (tag['readed'].isNotEmpty) {
          _tagIndex += _step;
          _applyTagMask(char, isPlaceHolder);
        } else {
          _incrementCharDeslocation(-1);
        }
        break;
      case _multipleOpt:
        if (_match(tagValue, char) || isPlaceHolder) {
          _appendText(char);
          _typedCharacter += 1;
        } else {
          _tagIndex += _step;
          _applyTagMask(char, isPlaceHolder);
        }
        break;
      default:
        _incrementCharDeslocation(-1);
    }
  }

  void _incrementCharDeslocation(int step) {
    if (_charIndex <= _cursorPosition - 1) _charDeslocation += step;
  }

  bool _match(String tagValue, String char) => RegExp(tagValue).hasMatch(char);

  void _appendText(String char) {
    _maskedText = _reverse
        ? '$char$_extraChar$_maskedText'
        : '$_maskedText$_extraChar$char';
    _incrementCharDeslocation(_extraChar.length);
    _extraChar = '';
  }

  void _appendExtraChar(String extra) {
    _extraChar = _reverse ? '$extra$_extraChar' : '$_extraChar$extra';
  }

  Map<String, dynamic> _buildResultJson(
      String text, int cursorPos, int maxLengh) {
    if (maxLengh > 0) {
      if (_reverse) {
        text = text.substring(max(0, text.length - maxLengh));
      } else {
        text = text.substring(0, maxLengh);
      }
    }
    return <String, dynamic>{
      "text": text,
      "selectionBase": max(0, cursorPos),
      "selectionExtent": max(0, cursorPos),
      "overflow": _overflow
    };
  }
}
