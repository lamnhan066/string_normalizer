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

  test('parseSeparatedUnicodeData', () async {
    final data = '''
0226	LATIN CAPITAL LETTER A WITH DOT ABOVE
	: 0041 0307
0227	LATIN SMALL LETTER A WITH DOT ABOVE
	* Uralicist usage
	: 0061 0307
03AD	GREEK SMALL LETTER EPSILON WITH TONOS
	: 03B5 0301
0130	LATIN CAPITAL LETTER I WITH DOT ABOVE
	= i dot
	* Turkish, Azerbaijani
	* lowercase is 0069
	x (latin capital letter i - 0049)
	: 0049 0307
''';
    final normalized = await Crawler().parseSeparatedUnicodeData(data);

    expect(
      normalized,
      equals({
        'A': {'Ȧ'},
        'a': {'ȧ'},
        'ε': {'έ'},
        'I': {'İ'}
      }),
    );
  });

  test('Specific test cases', () {
    final text =
        'Thîs Is à Löngêr Strîng Wîth Môre Cõmplicâtêd Cãses Änd Diãcritics. Αυτή είναι η ελληνική φράση με ειδικούς χαρακτήρες! Αυτό είναι το νούμερο 1234. 🄐🄰🅐🅰';
    final expectedText =
        'this is a longer string with more complicated cases and diacritics. αυτη ειναι η ελληνικη φραση με ειδικους χαρακτηρες! αυτο ειναι το νουμερο 1234. aaaa';
    final normalized = StringNormalizer.normalize(text).toLowerCase();
    final normalizedExtension = text.normalize().toLowerCase();
    expect(normalized, equals(expectedText));
    expect(normalizedExtension, equals(expectedText));
  });
}
