// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

import 'utils.dart';

typedef CrawlData = Map<String, Set<String>>;

class Crawler {
  /// Crawl the data from trusted sources.
  Crawler();

  Future<CrawlData> crawl() async {
    CrawlData result = CrawlData();

    String unicodeSource = await http.read(
        Uri.parse('https://www.unicode.org/Public/UNIDATA/NamesList.txt'));

    var unicode = await _fromUnicode(unicodeSource);
    unicode.forEach((key, value) {
      result.putIfAbsent(key, () => {});
      result[key]!.addAll(value);
    });

    String pinyinSource = await http
        .read(Uri.parse('http://pinyin.info/unicode/diacritics.html'));
    final pinyin = await _fromPinyin(pinyinSource);

    pinyin.forEach((key, value) {
      result.putIfAbsent(key, () => {});
      result[key]!.addAll(value);
    });

    var combinedUnicode = await parseSeparatedUnicodeData(unicodeSource);
    var flatted = flatMap(result);
    combinedUnicode.forEach((key, value) {
      final normalizedKey = flatted[key] ?? key;
      result.putIfAbsent(normalizedKey, () => {});
      result[normalizedKey]!.addAll(value);
    });

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
    string.writeln('{');
    map.forEach((key, value) {
      if (key.contains("'")) {
        string.writeln('r"$key": {');
      } else {
        string.writeln("r'$key': {");
      }
      for (var element in value) {
        if (element.contains("'")) {
          string.writeln('r"$element",');
        } else {
          string.writeln("r'$element',");
        }
      }
      string.writeln('},');
    });
    string.writeln('};');

    return string.toString();
  }

  /// Parse data from `unicode.org/Public/UNIDATA/NamesList.txt` from this format:
  ///
  /// ```
  /// 0226	LATIN CAPITAL LETTER A WITH DOT ABOVE
  /// 	: 0041 0307
  /// 0227	LATIN SMALL LETTER A WITH DOT ABOVE
  /// 	* Uralicist usage
  /// 	: 0061 0307
  /// 03AD	GREEK SMALL LETTER EPSILON WITH TONOS
  /// 	: 03B5 0301
  /// 0130	LATIN CAPITAL LETTER I WITH DOT ABOVE
  /// 	= i dot
  /// 	* Turkish, Azerbaijani
  /// 	* lowercase is 0069
  /// 	x (latin capital letter i - 0049)
  /// 	: 0049 0307
  /// ```
  ///
  /// To
  ///
  /// ```
  /// {
  ///   'A': {'Ȧ'},
  ///   'a': {'ȧ'},
  ///   'ε': {'έ'},
  ///   'I': {'İ'}
  /// }
  /// ```
  ///
  /// After that, an unicode will be separated to separated character, so it
  /// will be easier to remove the tone.
  Future<CrawlData> parseSeparatedUnicodeData(String data) async {
    final source = data.replaceAll('\n\t', ' ');
    Map<int, Set<int>> allCombinedData = {};

    for (final text in source.split('\n')) {
      try {
        if (text.contains(':')) {
          final key = text.split('\t')[0];
          final values = text.split(' : ')[1].split(' ');
          if (values.length != 2) continue;
          allCombinedData.addAll({
            int.parse(key, radix: 16):
                values.map((e) => int.parse(e, radix: 16)).toSet()
          });
        }
      } catch (_) {
        /* Skip if there is any value doesn't match the expected result*/
      }
    }

    // Convert to returned type.
    CrawlData result = CrawlData();
    allCombinedData.forEach((key, value) {
      final bestNormalized =
          _getTheBestNormalizedCharacter(key, allCombinedData);
      final char = String.fromCharCode(bestNormalized);
      result.putIfAbsent(char, () => {});
      result[char]!.add(String.fromCharCode(key));
    });

    return result;
  }

  int _getTheBestNormalizedCharacter(
      int codeUnit, Map<int, Set<int>> combinedData) {
    if (combinedData.containsKey(codeUnit)) {
      final normalized = combinedData[codeUnit]!.first;
      return _getTheBestNormalizedCharacter(
        normalized,
        {...combinedData}..remove(codeUnit),
      );
    }

    return codeUnit;
  }

  /// Get data from https://www.unicode.org/Public/UNIDATA/NamesList.txt
  Future<CrawlData> _fromUnicode(String data) async {
    final regexps = [
      RegExp(r'LATIN (SMALL|CAPITAL) LETTER (?:.* )?([A-Z]{1,2})(?: .*)?$'),
      RegExp(r'MODIFIER LETTER (SMALL|CAPITAL) (?:.* )?([A-Z]{1,2})(?: .*)?$'),
    ];

    final result = CrawlData();

    for (final line in data.split('\n')) {
      final tab = line.split('\t');
      final char = int.tryParse(tab[0], radix: 16);

      if (char == null) continue;

      // Regex area
      for (final regexp in regexps) {
        final name = regexp.firstMatch(tab[1]);

        if (name != null) {
          final cap = name.group(1);
          String letter = name.group(2)!;

          if (cap == 'SMALL') {
            letter = letter.toLowerCase();
          }

          if (result.containsKey(letter)) {
            result[letter]!.add(String.fromCharCode(char));
          } else {
            result[letter] = {String.fromCharCode(char)};
          }

          break;
        }
      }

      // Combining character area
      final emptyChar = '';
      if (tab[1].contains('COMBINING')) {
        if (result.containsKey(emptyChar)) {
          result[emptyChar]!.add(String.fromCharCode(char));
        } else {
          result[emptyChar] = {String.fromCharCode(char)};
        }
      }
    }

    return result;
  }

  /// Get data from http://pinyin.info/unicode/diacritics.html
  Future<CrawlData> _fromPinyin(String data) async {
    // Remove \n, tab, space
    data = data.replaceAll('\n', '').replaceAll('\t', '');
    while (data.contains(' ')) {
      data = data.replaceAll(' ', '');
    }

    data = data.substring(data.indexOf('<h3>CAPITALLETTERS</h3>'));

    // Remove misc
    final dataMain = data.substring(0, data.indexOf('<h3>MISC.</h3>'));
    final resultMain = _parsePinyin(dataMain);

    // Change back to real char
    String lastAscii = resultMain.values.elementAt(0);
    for (int i = 0; i < resultMain.length; i++) {
      if (resultMain.values.elementAt(i).length == 1) {
        lastAscii = resultMain.values.elementAt(i);
      } else {
        resultMain[resultMain.keys.elementAt(i)] = lastAscii;
      }
    }

    final dataMisc = data.substring(data.indexOf('<h3>MISC.</h3>'));
    final resultMisc = _parsePinyin(dataMisc);

    // Change back to '' char
    for (int i = 0; i < resultMisc.length; i++) {
      resultMisc[resultMisc.keys.elementAt(i)] = '';
    }

    final result = {...resultMain, ...resultMisc};

    final finalResult = CrawlData();

    result.forEach((key, value) {
      final parsed = int.tryParse(key, radix: 16);

      if (parsed != null) {
        if (finalResult.containsKey(value)) {
          finalResult[value]!.add(String.fromCharCode(parsed));
        } else {
          finalResult[value] = {String.fromCharCode(parsed)};
        }
      }
    });

    return finalResult;
  }

  /// Parser for Pinyin.
  Map<String, String> _parsePinyin(String data) {
    final matchAllPattern = RegExp(r'<tr(.*?)</tr>');
    final tdPattern = RegExp(r'<td>(.*?)</td>');

    final result = <String, String>{};
    final allMatchs = matchAllPattern.allMatches(data);
    for (final match in allMatchs) {
      final tdMatchs = tdPattern.allMatches(match.group(0) ?? '');
      if (tdMatchs.isEmpty) continue;

      result.addAll(
        {
          tdMatchs.elementAt(0).group(1).toString():
              tdMatchs.elementAt(1).group(1) ?? ''
        },
      );
    }

    return result;
  }
}
