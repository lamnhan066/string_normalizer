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

  /// Normalize the [text]
  ///
  /// Convert all diacritical characters to ASCII characters
  static String normalize(String text) {
    var result = text.toString();
    for (final code in data.keys) {
      result = result.replaceAll(String.fromCharCode(code), data[code]!);
    }

    return result;
  }
}
