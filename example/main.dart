import 'package:string_normalizer/string_normalizer.dart';

void main(List<String> args) {
  final text = 'Đây là chữ có dấu';
  final normalized = StringNormalizer.normalize(text);
  print(normalized);
  print(text.normalize());
}
