import 'data/local.dart';

extension StringNormalizerE on String {
  String normalize() => StringNormalizer.normalize(this);
}

class StringNormalizer {
  StringNormalizer._();

  static String normalize(String text) {
    var result = text.toString();
    for (final code in data.keys) {
      result = result.replaceAll(String.fromCharCode(code), data[code]!);
    }

    return result;
  }
}
