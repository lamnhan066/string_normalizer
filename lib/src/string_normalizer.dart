import 'package:characters/characters.dart';

import 'data/local.dart';

/// StringNormalizer extension
extension StringNormalizerE on String {
  /// Normalizer extension.
  ///
  /// Convert all diacritical characters to ASCII characters.
  String normalize() => StringNormalizer.normalize(this);

  /// Normalize the [text] shortened extension
  ///
  /// Convert all diacritical characters to ASCII characters.
  String get nml => normalize();
}

/// Convert all diacritical characters to ASCII characters.
class StringNormalizer {
  // Internal.
  StringNormalizer._();

  /// Normalize the [text].
  ///
  /// Convert all diacritical characters to ASCII characters.
  static String normalize(String text) {
    StringBuffer result = StringBuffer();

    // Try to replace a whole character first then replace each code unit of a character.
    for (final char in text.characters) {
      if (data.containsKey(char)) {
        result.write(data[char]);
      } else {
        final codeUnits = char.codeUnits;
        for (final codeUnit in codeUnits) {
          final char = String.fromCharCode(codeUnit);
          result.write(data[char] ?? char);
        }
      }
    }

    return result.toString();
  }
}
