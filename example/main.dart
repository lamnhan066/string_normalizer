import 'package:string_normalizer/string_normalizer.dart';

void main(List<String> args) {
  final text =
      'Thîs Is à Löngêr Strîng Wîth Môre Cõmplicâtêd Cãses Änd Diãcritics. Αυτή είναι η ελληνική φράση με ειδικούς χαρακτήρες! Αυτό είναι το νούμερο 1234.';
  final expectedText =
      'this is a longer string with more complicated cases and diacritics. αυτη ειναι η ελληνικη φραση με ειδικους χαρακτηρες! αυτο ειναι το νουμερο 1234.';
  final normalized = StringNormalizer.normalize(text).toLowerCase();
  final normalizedExtension = text.normalize().toLowerCase();
  print(normalized == expectedText); // true
  print(normalizedExtension == expectedText); // true
}
