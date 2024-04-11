// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

import 'models/crawl_parser.dart';
import 'models/input_data.dart';

class Crawler {
  /// Crawl the data from trusted sources.
  Crawler();

  Future<CrawlData> crawl() async {
    CrawlData result = await parse(
      preParsers: const [
        GreekPreParser(),
      ],
      parsers: const [
        LatinParser(),
        ModifierParser(),
        CombiningParser(),
        GreekParser(),
        MathematicalParser(),
      ],
    );
    return result;
  }

  /// Convert the crawled data to string of this form:
  ///
  /// {
  ///   'A': {
  ///     A,
  ///     À,
  ///     Á,
  ///     Â,
  ///     Ã,
  ///   },
  ///   ...
  /// }
  String crawledDataToString(CrawlData map) {
    StringBuffer string = StringBuffer();
    string.writeln('<String, Set<String>>{');
    map.forEach((key, value) {
      if (key.contains("'")) {
        string.writeln('r"$key": {');
      } else {
        string.writeln("r'$key': {");
      }
      for (var element in value) {
        if (element == '�') {
          print(key);
        }
        if (element.contains("'")) {
          string.writeln('r"$element",');
        } else {
          string.writeln("r'$element', ");
        }
      }
      string.writeln('},');
    });
    string.writeln('};');

    return string.toString();
  }

  Future<CrawlData> parse({
    List<CrawlParser> preParsers = const [],
    List<CrawlParser> parsers = const [],
    String? testData,
  }) async {
    String data;
    if (testData != null) {
      data = testData;
    } else {
      final url =
          'https://www.unicode.org/Public/UNIDATA/extracted/DerivedName.txt';
      final uri = Uri.parse(url);
      data = await http.read(uri);
    }

    final splitteds = InputData.fromText(data);

    // Pre-parse to create a needed data for later use.
    if (preParsers.isNotEmpty) {
      for (final splitted in splitteds) {
        for (final parser in preParsers) {
          await parser.parse(splitted);
        }
      }
    }

    // Parse and save parsed data to `result`.
    final result = CrawlData();
    for (final splitted in splitteds) {
      for (final parser in parsers) {
        final parseds = await parser.parse(splitted);
        if (parseds == null) {
          continue;
        }

        for (final parsed in parseds) {
          if (String.fromCharCodes(parsed.char) == parsed.normalizedChar) {
            continue;
          }

          result.putIfAbsent(parsed.normalizedChar, () => {});
          result[parsed.normalizedChar]!.add(String.fromCharCodes(parsed.char));
        }
      }
    }
    return result;
  }
}
