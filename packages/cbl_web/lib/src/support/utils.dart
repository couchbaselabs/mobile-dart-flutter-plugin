import 'dart:math';

import 'package:characters/characters.dart';

String redact(String string) {
  const unredactedChars = 3;
  final chars = string.characters;
  final redactedChars =
      max(chars.length - unredactedChars, min(unredactedChars, chars.length));
  final unredactedCharsStr = chars.getRange(redactedChars);
  return ('*' * redactedChars) + unredactedCharsStr.string;
}
