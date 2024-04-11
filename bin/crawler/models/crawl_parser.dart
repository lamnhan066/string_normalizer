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
