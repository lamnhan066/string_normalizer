# String Normalizer

Helps you remove accents and diacritics from strings. It comes with a built-in crawler feature, which can be made more reliable.

Data source:

- pinyin.info/unicode/diacritics.html
- unicode.org/Public/UNIDATA/NamesList.txt

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

## Contribution

- Run an internal Crawler:

  - Fork the project on github.
  - Run `dart run string_normalizer:crawl`.
  - The crawler will let you know if there is an available update.
  - Open a PR if there is an update.

- Modify [the Crawler](https://github.com/lamnhan066/string_normalizer/tree/main/lib/src/) to get the new data.

- Open an issue or PR.
