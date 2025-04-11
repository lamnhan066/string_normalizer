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
    final result = StringBuffer();

    // Try to replace a whole character first then replace each code unit of a character.
    for (final char in text.characters) {
      final normalizedChar = data[char];
      if (normalizedChar != null) {
        result.write(normalizedChar);
      } else {
        final codeUnits = char.codeUnits;

        if (codeUnits.length == 1) {
          result.write(char);
        } else {
          for (final unit in codeUnits) {
            final unitChar = String.fromCharCode(unit);
            result.write(data[unitChar] ?? unitChar);
          }
        }
      }
    }

    return result.toString();
  }
}
