import 'package:string_normalizer/src/crawler.dart';
import 'package:string_normalizer/src/string_normalizer.dart';
import 'package:test/test.dart';

void main() {
  test('Crawler', () async {
    final crawler = Crawler();
    final crawled = await crawler.crawl();

    expect(crawled, isNotEmpty);
  });

  test('Test static method', () {
    final normalized = StringNormalizer.normalize('Đây là chữ có dấu');

    expect(normalized, equals('Day la chu co dau'));
  });

  test('Test extension', () {
    final normalized = 'Đây là chữ có dấu'.normalize();

    expect(normalized, equals('Day la chu co dau'));
  });

  test('Specific test cases', () {
    final normalized = 'ìáú'.normalize();

    expect(normalized, equals('iau'));
  });
}
