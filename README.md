# String Normalizer

Helps you remove accents and diacritics from strings. It comes with a built-in crawler feature, which can be made more reliable.

Data source:

- unicode.org/Public/UNIDATA/extracted/DerivedName.txt

Data of this package: [local.dart](https://github.com/lamnhan066/string_normalizer/blob/main/lib/src/data/local.dart)

## Usage

- Static method

```dart
final normalized = StringNormalizer.normalize('Đây là chữ có dấu');
// Result: Day la chu co dau
```

- As an extension

```dart
final normalized = 'Đây là chữ có dấu'.normalize();
// Result: Day la chu co dau
```

- Shorter version

```dart
final normalized = 'Đây là chữ có dấu'.nml;
// Result: Day la chu co dau
```

## Some Test Cases

```dart
group('Special test cases -', () {
  test('Combining characters', () {
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
    final text = 'Αυτή είναι η ελληνική φράση με ειδικούς χαρακτήρες! Αυτό είναι το νούμερο.';
    final expectedText = 'αυτη ειναι η ελληνικη φραση με ειδικους χαρακτηρες! αυτο ειναι το νουμερο.';
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
```

## Contribution

- Run an internal Crawler (The Crawler is also automatically ran weekly by the github-bot):

  - Fork the project on github.
  - Run `dart run tool/crawl.dart`.
  - The crawler will let you know if there is an available update.
  - Open a PR if there is an update.

- Modify [the Crawler](https://github.com/lamnhan066/string_normalizer/tree/main/tool/crawler/) to get the new data.

- Open an issue or PR.
