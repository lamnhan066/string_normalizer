import 'package:string_normalizer/src/string_normalizer.dart';
import 'package:test/expect.dart';

void main() {
  final normalized = StringNormalizer.normalize('árvíztűrő tükörfúrógép');
  print(normalized);

  expect(normalized, 'Mi muon di choi');
}
