// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/crawl_parser.dart';
import 'models/input_data.dart';
import 'utils.dart';

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
  ///   'A': 'A',
  ///   'À': 'A'
  ///   'Á': 'A',
  ///   ...
  /// }
  String crawledDataToString(CrawlData map) {
    StringBuffer string = StringBuffer();
    string.writeln('<String, String>');
    final flattedMap = flatMap(map);
    final json = jsonEncode(flattedMap);
    string.write(json);
    string.writeln(';');

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
