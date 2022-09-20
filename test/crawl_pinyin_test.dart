import 'package:http/http.dart' as http;

void main() async {
  String data =
      await http.read(Uri.parse('http://pinyin.info/unicode/diacritics.html'));

  // Remove \n, tab, space
  data = data.replaceAll('\n', '').replaceAll('\t', '');
  while (data.contains(' ')) {
    data = data.replaceAll(' ', '');
  }

  data = data.substring(data.indexOf('<h3>CAPITALLETTERS</h3>'));

  // Remove misc
  final dataMain = data.substring(0, data.indexOf('<h3>MISC.</h3>'));
  final resultMain = parse(dataMain);

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
  final resultMisc = parse(dataMisc);

  // Change back to '' char
  for (int i = 0; i < resultMisc.length; i++) {
    resultMisc[resultMisc.keys.elementAt(i)] = '';
  }

  final result = {...resultMain, ...resultMisc};

  if (data.length != result.length) {
    print('Available new strings');
  }

  print('{');
  result.forEach((key, value) {
    print('0x$key : \'$value\',');
  });
  print('}');
}

Map<String, String> parse(String data) {
  final matchAllPattern = RegExp(r'<tr(.*?)</tr>');
  final tdPattern = RegExp(r'<td>(.*?)</td>');

  final result = <String, String>{};
  final allMatchs = matchAllPattern.allMatches(data);
  for (final match in allMatchs) {
    final tdMatchs = tdPattern.allMatches(match.group(0) ?? '');
    if (tdMatchs.isEmpty) continue;

    // print(tdMatchs.elementAt(0).group(1));

    result.addAll(
      {
        tdMatchs.elementAt(0).group(1).toString():
            tdMatchs.elementAt(1).group(1) ?? ''
      },
    );
  }

  return result;
}
