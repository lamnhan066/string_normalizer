# String Normalizer

Helps you to remove accents and diacritics from strings.

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
