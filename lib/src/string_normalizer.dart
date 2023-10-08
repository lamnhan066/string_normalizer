import 'data/local.dart';

/// StringNormalizer extension
extension StringNormalizerE on String {
  /// Normalizer extension
  ///
  /// Convert all diacritical characters to ASCII characters
  String normalize() => StringNormalizer.normalize(this);

  /// Normalize the [text] shortened extension
  ///
  /// Convert all diacritical characters to ASCII characters
  String get nml => normalize();
}

/// Convert all diacritical characters to ASCII characters
class StringNormalizer {
  StringNormalizer._();

  /// Normalize the [text].
  ///
  /// Convert all diacritical characters to ASCII characters.
  static String normalize(String text) {
    StringBuffer result = StringBuffer();

    for (final charCode in text.codeUnits) {
      result.write(data[charCode] ?? String.fromCharCode(charCode));
    }

    return result.toString();
  }
}
