import 'package:string_normalizer/src/string_normalizer.dart';
import 'package:test/test.dart';

void main() {
  final text = 'Đây là chữ có dấu';
  test('Test static method', () {
    final normalized = StringNormalizer.normalize(text);

    expect(normalized, equals('Day la chu co dau'));
  });

  test('Test extension', () {
    final normalized = text.normalize();

    expect(normalized, equals('Day la chu co dau'));
  });
}
