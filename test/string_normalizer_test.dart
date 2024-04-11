import 'package:string_normalizer/src/string_normalizer.dart';
import 'package:test/test.dart';

import '../bin/crawler/crawler.dart';

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

  group('Special test cases -', () {
    test('Vietnam', () {
      final normalized = 'ìáú'.normalize();
      expect(normalized, equals('iau'));
    });

    test('English', () {
      final text =
          'Thîs Is à Löngêr Strîng Wîth Môre Cõmplicâtêd Cãses Änd Diãcritics.';
      final expectedText =
          'this is a longer string with more complicated cases and diacritics.';
      final normalized = StringNormalizer.normalize(text).toLowerCase();
      final normalizedExtension = text.normalize().toLowerCase();
      expect(normalized, equals(expectedText));
      expect(normalizedExtension, equals(expectedText));
    });

    test('Greek', () {
      final text =
          'Αυτή είναι η ελληνική φράση με ειδικούς χαρακτήρες! Αυτό είναι το νούμερο 1234. Όλοι οι άνθρωποι γεννιούνται ελεύθεροι και ίσοι στην αξιοπρέπεια';
      final expectedText =
          'αυτη ειναι η ελληνικη φραση με ειδικους χαρακτηρες! αυτο ειναι το νουμερο 1234. ολοι οι ανθρωποι γεννιουνται ελευθεροι και ισοι στην αξιοπρεπεια';
      final normalized = StringNormalizer.normalize(text).toLowerCase();
      final normalizedExtension = text.normalize().toLowerCase();
      expect(normalized, equals(expectedText));
      expect(normalizedExtension, equals(expectedText));
    });

    test('Symbol', () {
      final text = '🄐🄰🅐🅰';
      final expectedText = 'aaaa';
      final normalized = StringNormalizer.normalize(text).toLowerCase();
      final normalizedExtension = text.normalize().toLowerCase();
      expect(normalized, equals(expectedText));
      expect(normalizedExtension, equals(expectedText));
    });

    test('Mathematical', () {
      final text = '𝐀𝐁𝐂𝐃𝐚𝐛𝐜𝐝𝟘𝟙𝟚𝟛𝟜';
      final expectedText = 'ABCDabcd01234';
      expect(text.normalize(), equals(expectedText));
    });
  });
}
