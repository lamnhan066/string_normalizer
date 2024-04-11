import 'package:characters/characters.dart';

import 'data/local.dart';
import 'utils.dart';

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

  /// We do not need to initialize the data if it's not needed to use.
  static Map<String, String>? _data;

  /// Normalize the [text].
  ///
  /// Convert all diacritical characters to ASCII characters.
  static String normalize(String text) {
    _data ??= flatMap(data);

    StringBuffer result = StringBuffer();

    // Try to replace a whole character first then replace each code unit of a character.
    for (final char in text.characters) {
      if (_data!.containsKey(char)) {
        result.write(_data![char]);
      } else {
        final codeUnits = char.codeUnits;
        for (final codeUnit in codeUnits) {
          final char = String.fromCharCode(codeUnit);
          result.write(_data![char] ?? char);
        }
      }
    }

    return result.toString();
  }
}
