class InputData {
  /// Unicode code point value.
  final int code;

  /// Range of code point values.
  final int range;

  /// Name property value or pattern.
  final String name;

  InputData({
    required this.code,
    required this.name,
    this.range = 1,
  });

  factory InputData.fromLine(String line) {
    final splitted = line.split(';');
    final codes = splitted[0].trim();
    final name = splitted[1].trim();
    int code;
    int range = 1;
    if (codes.contains('..')) {
      final codeRange = codes.split('..');
      code = int.parse(codeRange[0].trim(), radix: 16);
      final end = int.parse(codeRange[1].trim(), radix: 16);
      range = end - code;
    } else {
      code = int.parse(codes.trim(), radix: 16);
    }
    return InputData(code: code, name: name, range: range);
  }

  static List<InputData> fromText(String text) {
    final data = <InputData>[];
    final lines = text.split('\n');
    for (final line in lines) {
      try {
        data.add(InputData.fromLine(line));
      } catch (_) {
        /* Ignore unparseable line */
      }
    }
    return data;
  }
}
