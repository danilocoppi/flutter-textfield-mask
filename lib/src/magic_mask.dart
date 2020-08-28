import 'dart:math';

/// This class is used to make all hardwork of making and controll the users cursor.
/// It should be used by TextInputMask, so you dont need to worry about it.
/// If you want you can use it as String masker.
class MagicMask {
  static const String _type = 'type';
  static const String _value = 'value';

  static const String _fixChar = 'fixedChar';
  static const String _token = 'token';
  static const String _tokenOpt = 'optionalToken';
  static const String _multiple = 'multiple';
  static const String _multipleOpt = 'multiple';

  bool _reverse;
  int _charIndex;
  int _tagIndex;
  int _step;
  int _charDeslocation;
  int _cursorPosition;
  String _maskedText;
  String _extraChar;

  List<Map<String, String>> _tags = [];

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
  /// \+ - indicates that must have at least 1 or more repetitions
  ///
  /// \* - indicates that can have 0 or more repetitions
  ///
  /// \ - is used as scape
  void buildMaskTokens(String mask) {
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
      String text, int cursorPosition, bool reverse, int maxLenght) {
    if (text == null || text.isEmpty || _tags.length == 0)
      return _buildResultJson('', 0, maxLenght);

    // Clear any possible readed attribute
    for (Map<String, String> tag in _tags) tag['readed'] = '';
    // Clear all variables
    _reverse = reverse;
    _cursorPosition = cursorPosition;
    _charIndex = reverse ? text.length - 1 : 0;
    _tagIndex = reverse ? _tags.length - 1 : 0;
    _step = reverse ? -1 : 1;
    _charDeslocation = 0;
    _maskedText = '';
    _extraChar = '';

    String currentChar = text[_charIndex] ?? '';
    while (currentChar.isNotEmpty) {
      _applyTagMask(currentChar);
      _charIndex += _step;
      if (_charIndex < 0 || _charIndex >= text.length) break;
      currentChar = text[_charIndex] ?? '';
    }

    if (!_isNotLastMask(0)) {
      _tagIndex += _step;
      while (_tagIndex >= 0 && _tagIndex < _tags.length) {
        var tag = _tags[_tagIndex];
        _appendText(tag[_value]);
        _incrementCharDeslocation(-_step);
        _tagIndex += _step;
      }
    }

    _cursorPosition =
        min(_cursorPosition + _charDeslocation, _maskedText.length);
    return _buildResultJson(_maskedText, _cursorPosition, maxLenght);
  }

  void _applyTagMask(String char) {
    if (_tagIndex < 0 || _tagIndex >= _tags.length) return;
    var tag = _tags[_tagIndex];
    String tagType = tag[_type];
    String tagValue = tag[_value];

    switch (tagType) {
      case _fixChar:
        // _appendText(tagValue);
        _appendExtraChar(tagValue);

        _tagIndex += _step;
        // incrementCharDeslocation(1);
        _applyTagMask(char);
        break;
      case _token:
        if (_match(tagValue, char)) {
          _appendText(char);
          _tagIndex += _step;
        } else {
          _incrementCharDeslocation(-1);
        }
        break;
      case _tokenOpt:
        if (_match(tagValue, char)) {
          _appendText(char);
          _tagIndex += _step;
        } else {
          _tagIndex += _step;
          _applyTagMask(char);
        }
        break;
      case _multiple:
        if (_match(tagValue, char)) {
          _appendText(char);
          tag['readed'] = '1';
        } else if (tag['readed'].isNotEmpty && _isNotLastMask(0)) {
          _tagIndex += _step;
          _applyTagMask(char);
        } else {
          _incrementCharDeslocation(-1);
        }
        break;
      case _multipleOpt:
        if (_match(tagValue, char)) {
          _appendText(char);
        } else if (_isNotLastMask(0)) {
          _tagIndex += _step;
          _applyTagMask(char);
        } else {
          _incrementCharDeslocation(-1);
        }
        break;
      default:
        _incrementCharDeslocation(-1);
    }
  }

  bool _isNotLastMask(int baseStep) {
    if (_tagIndex + _step + baseStep >= 0 &&
        _tagIndex + _step + baseStep < _tags.length) {
      var tag = _tags[_tagIndex + _step + baseStep];
      if (tag[_type] != _fixChar) {
        return true;
      } else {
        return _isNotLastMask(baseStep + _step);
      }
    } else {
      return false;
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
      "selectionBase": cursorPos,
      "selectionExtent": cursorPos
    };
  }
}
