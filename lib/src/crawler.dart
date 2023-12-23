// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

class Crawler {
  /// Crawl the data from trusted sources.
  Crawler();

  Future<Map<String, Set<int>>> crawl() async {
    var unicode = await _fromUnicode();
    final pinyin = await _fromPinyin();

    pinyin.forEach((key, value) {
      if (!unicode.containsKey(key)) {
        unicode[key] = value;
      } else {
        unicode[key]!.addAll(value);
      }
    });

    return unicode;
  }

  /// Convert the crawled data to string of this form:
  ///
  /// {
  ///   'A': {
  ///     0x000041, // A
  ///     0x0000c0, // À
  ///     0x0000c1, // Á
  ///     0x0000c2, // Â
  ///     0x0000c3, // Ã
  ///   },
  ///   ...
  /// }
  String crawledDataToString(Map<String, Set<int>> map) {
    StringBuffer string = StringBuffer();
    string.writeln('{');
    map.forEach((key, value) {
      string.writeln("'$key': {");
      for (var element in value) {
        string.writeln(
            '0x${element.toRadixString(16).padLeft(6, '0')}, // ${String.fromCharCode(element)}');
      }
      string.writeln('},');
    });
    string.writeln('};');

    return string.toString();
  }

  /// Get data from https://www.unicode.org/Public/UNIDATA/NamesList.txt
  Future<Map<String, Set<int>>> _fromUnicode() async {
    String data = await http.read(
        Uri.parse('https://www.unicode.org/Public/UNIDATA/NamesList.txt'));

    final regexps = [
      RegExp(r'LATIN (SMALL|CAPITAL) LETTER (?:.* )?([A-Z]{1,2})(?: .*)?$'),
      RegExp(r'MODIFIER LETTER (SMALL|CAPITAL) (?:.* )?([A-Z]{1,2})(?: .*)?$'),
    ];

    final Map<String, Set<int>> result = {};

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
            result[letter]!.add(char);
          } else {
            result[letter] = {char};
          }

          break;
        }
      }

      // Combining character area
      final emptyChar = '';
      if (tab[1].contains('COMBINING')) {
        if (result.containsKey(emptyChar)) {
          result[emptyChar]!.add(char);
        } else {
          result[emptyChar] = {char};
        }
      }
    }

    return result;
  }

  /// Get data from http://pinyin.info/unicode/diacritics.html
  Future<Map<String, Set<int>>> _fromPinyin() async {
    String data = await http
        .read(Uri.parse('http://pinyin.info/unicode/diacritics.html'));

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

    Map<String, Set<int>> finalResult = {};

    result.forEach((key, value) {
      final parsed = int.tryParse(key, radix: 16);

      if (parsed != null) {
        if (finalResult.containsKey(value)) {
          finalResult[value]!.add(parsed);
        } else {
          finalResult[value] = {parsed};
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
