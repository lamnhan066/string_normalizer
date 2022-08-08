import 'package:http/http.dart' as http;

void main() async {
  String data = await http.read(Uri.parse(
      'https://docs.oracle.com/cd/E29584_01/webhelp/mdex_basicDev/src/rbdv_chars_mapping.html'));

  data = data.replaceAll('\n', '').replaceAll('\t', '');
  while (data.contains(' ')) {
    data = data.replaceAll(' ', '');
  }
  final isoLatin1Char = RegExp(
      r'(headers="d62541e1055">(.*?)</td>|headers="d62541e86">(.*?)</td>)');
  final ascii1Char = RegExp(
      r'(headers="d62541e1061">(.*?)</td>|headers="d62541e92">(.*?)</td>)');
  final charChar =
      RegExp(r'(headers="d62541e95">(.*?),|headers="d62541e1064">(.*?),)');
  final isoLatin1Matchs = isoLatin1Char.allMatches(data);
  final asciiMatchs = ascii1Char.allMatches(data);
  final chars = charChar.allMatches(data);

  print(isoLatin1Matchs.length);
  print(chars.length);

  print('{');
  for (int i = 0; i < isoLatin1Matchs.length; i++) {
    final isoLatin = isoLatin1Matchs.elementAt(i);
    final ascii = asciiMatchs.elementAt(i);
    final char = chars.elementAt(i);
    // print(
    //     '${int.parse(isoLatin.group(2) ?? isoLatin.group(3) ?? '0')} : \'${ascii.group(2) ?? ascii.group(3)}\',');
    print(
        '${int.parse(isoLatin.group(2) ?? isoLatin.group(3) ?? '0')} : \'${char.group(2)?.toString().split('').last ?? char.group(3)?.toString().split('').last}\',');
  }
  print('}');
}
