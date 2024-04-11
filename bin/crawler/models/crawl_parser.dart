import 'input_data.dart';
import 'output_data.dart';

typedef CrawlData = Map<String, Set<String>>;

abstract class CrawlParser {
  const CrawlParser();

  Future<List<OutputData>?> parse(InputData data);
}

class LatinParser extends CrawlParser {
  const LatinParser();

  static final regexp =
      RegExp(r'LATIN (SMALL|CAPITAL) LETTER (?:.* )?([A-Z]{1,2})(?: .*)?$');

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!regexp.hasMatch(data.name)) return null;

    final parsed = regexp.firstMatch(data.name)!;

    final cap = parsed.group(1);
    String letter = parsed.group(2)!;

    if (cap == 'SMALL') {
      letter = letter.toLowerCase();
    }

    return [
      OutputData(char: [data.code], normalizedChar: letter)
    ];
  }
}

class ModifierParser extends CrawlParser {
  const ModifierParser();

  static final regexp =
      RegExp(r'MODIFIER LETTER (SMALL|CAPITAL) (?:.* )?([A-Z]{1,2})(?: .*)?$');

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!regexp.hasMatch(data.name)) return null;

    final parsed = regexp.firstMatch(data.name)!;

    final cap = parsed.group(1);
    String letter = parsed.group(2)!;

    if (cap == 'SMALL') {
      letter = letter.toLowerCase();
    }

    return [
      OutputData(char: [data.code], normalizedChar: letter)
    ];
  }
}

class CombiningParser extends CrawlParser {
  const CombiningParser();

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!data.name.startsWith('COMBINING')) return null;

    return [
      OutputData(
        char: [data.code],
        normalizedChar: '',
      ),
    ];
  }
}

class GreekPreParser extends CrawlParser {
  /// Pre-parse to get
  const GreekPreParser();

  static Map<String, int> greekChars = {};

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!data.name.startsWith('GREEK')) return null;

    if (!data.name.contains('WITH')) {
      greekChars.addAll({data.name: data.code});
    }

    return null;
  }
}

class GreekParser extends CrawlParser {
  const GreekParser();

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!data.name.startsWith('GREEK')) return null;

    int normalized = data.code;
    for (final map in GreekPreParser.greekChars.entries) {
      if (data.name.startsWith(map.key)) {
        normalized = map.value;
        break;
      }
    }

    return [
      OutputData(
        char: [data.code],
        normalizedChar: String.fromCharCode(normalized),
      )
    ];
  }
}

class MathematicalParser extends CrawlParser {
  const MathematicalParser();

  static final replacement = {
    'ZERO': '0',
    'ONE': '1',
    'TWO': '2',
    'THREE': '3',
    'FOUR': '4',
    'FIVE': '5',
    'SIX': '6',
    'SEVEN': '7',
    'EIGHT': '8',
    'NINE': '9',
    'NABLA': String.fromCharCode(0x2207),
    'PARTIAL DIFFERENTIAL': String.fromCharCode(0x2202),
    'RISING DIAGONAL': '/',
    'FALLING DIAGONAL': r'\',
    'LEFT WHITE SQUARE BRACKET': String.fromCharCode(0x301A),
    'RIGHT WHITE SQUARE BRACKET': String.fromCharCode(0x301B),
    'LEFT ANGLE BRACKET': String.fromCharCode(0x3008),
    'RIGHT ANGLE BRACKET': String.fromCharCode(0x3009),
    'LEFT DOUBLE ANGLE BRACKET': String.fromCharCode(0x300A),
    'RIGHT DOUBLE ANGLE BRACKET': String.fromCharCode(0x300B),
    'LEFT WHITE TORTOISE SHELL BRACKET': String.fromCharCode(0x3018),
    'RIGHT WHITE TORTOISE SHELL BRACKET': String.fromCharCode(0x3019),
  };

  @override
  Future<List<OutputData>?> parse(InputData data) async {
    if (!data.name.startsWith('MATHEMATICAL')) return null;

    String? char;
    final chars = data.name.split(' ');

    // Single character
    if (chars.last.length == 1) {
      char = chars.last;
      if (data.name.contains('SMALL')) {
        char = char.toLowerCase();
      }
    }

    // Use pre-defined character map with 2 words.
    if (char == null) {
      for (final map in replacement.entries) {
        if (data.name.endsWith(map.key)) {
          char = map.value;
          break;
        }
      }
    }

    // Use data from `GreekPreParser` character map with 2 words.
    if (char == null) {
      for (final map in GreekPreParser.greekChars.entries) {
        final lastTwoWords = chars.sublist(chars.length - 2).join(' ');

        if (map.key.contains(lastTwoWords)) {
          char = String.fromCharCode(map.value);
        }
      }
    }

    // Use data from `GreekPreParser` character map with 1 words.
    if (char == null) {
      for (final map in GreekPreParser.greekChars.entries) {
        final lastWord = chars.last;

        if (map.key.contains(lastWord)) {
          char = String.fromCharCode(map.value);
        }
      }
    }

    if (char == null) {
      return null;
    }

    return [
      OutputData(char: [data.code], normalizedChar: char)
    ];
  }
}
