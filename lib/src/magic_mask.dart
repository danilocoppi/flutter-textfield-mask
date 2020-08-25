import 'dart:math';

class MagicMask {
  final String type = 'type';
  final String value = 'value';

  static const String fixChar = 'fixedChar';
  static const String token = 'token';
  static const String tokenOpt = 'optionalToken';
  static const String multiple = 'multiple';
  static const String multipleOpt = 'multiple';

  bool _reverse;
  int _charIndex;
  int _tagIndex;
  int _step;
  int _charDeslocation;
  int _cursorPosition;
  String _maskedText;

  List<Map<String, String>> _tags = [];

  String lastMaskType() => _tags?.last == null ? null : _tags.last[type];

  void buildMaskTokens(String mask) {
    for (var i = 0; i < mask.length; i++) {
      String currentChar = mask[i];
      if (currentChar == '\\') {
        _tags.add({type: fixChar, value: mask[i + 1]});
      } else if (currentChar == '*') {
        if (lastMaskType() == token) _tags.last[type] = multipleOpt;
      } else if (currentChar == '+') {
        if (lastMaskType() == token) _tags.last[type] = multiple;
      } else if (currentChar == '?') {
        if (lastMaskType() == token) _tags.last[type] = tokenOpt;
      } else if (currentChar == '9') {
        _tags.add({type: token, value: '\\d'});
      } else if (currentChar == 'A') {
        _tags.add({type: token, value: '[a-zA-z]'});
      } else if (currentChar == 'N') {
        _tags.add({type: token, value: '[a-zA-z0-9]'});
      } else if (currentChar == 'X') {
        _tags.add({type: token, value: '.'});
      } else {
        _tags.add({type: fixChar, value: currentChar});
      }
    }
  }

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
        _appendText(tag[value]);
        incrementCharDeslocation(1);
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
    String tagType = tag[type];
    String tagValue = tag[value];

    switch (tagType) {
      case fixChar:
        _appendText(tagValue);
        _tagIndex += _step;
        incrementCharDeslocation(1);
        _applyTagMask(char);
        break;
      case token:
        if (_match(tagValue, char)) {
          _appendText(char);
          _tagIndex += _step;
        } else {
          incrementCharDeslocation(-1);
        }
        break;
      case tokenOpt:
        if (_match(tagValue, char)) {
          _appendText(char);
          _tagIndex += _step;
        } else {
          _tagIndex += _step;
          _applyTagMask(char);
        }
        break;
      case multiple:
        if (_match(tagValue, char)) {
          _appendText(char);
          tag['readed'] = '1';
        } else if (tag['readed'].isNotEmpty && _isNotLastMask(0)) {
          _tagIndex += _step;
          _applyTagMask(char);
        } else {
          incrementCharDeslocation(-1);
        }
        break;
      case multipleOpt:
        if (_match(tagValue, char)) {
          _appendText(char);
        } else if (_isNotLastMask(0)) {
          _tagIndex += _step;
          _applyTagMask(char);
        } else {
          incrementCharDeslocation(-1);
        }
        break;
      default:
        incrementCharDeslocation(-1);
    }
  }

  bool _isNotLastMask(int baseStep) {
    if (_tagIndex + _step + baseStep >= 0 &&
        _tagIndex + _step + baseStep < _tags.length) {
      var tag = _tags[_tagIndex + _step + baseStep];
      if (tag[type] != fixChar) {
        return true;
      } else {
        return _isNotLastMask(baseStep + _step);
      }
    } else {
      return false;
    }
  }

  void incrementCharDeslocation(int step) {
    if (_charIndex < _cursorPosition) _charDeslocation += step;
  }

  bool _match(String tagValue, String char) => RegExp(tagValue).hasMatch(char);

  void _appendText(String char) {
    _maskedText = _reverse ? '$char$_maskedText' : '$_maskedText$char';
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
