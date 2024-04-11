/// Flat the map
Map<String, String> flatMap(Map<String, Set<String>> map) {
  final result = <String, String>{};
  map.forEach((key, value) {
    for (var element in value) {
      // Priorize the element that the `key` is not empty.
      if (!result.containsKey(element)) {
        result.addAll({element: key});
      } else if (key != '') {
        result.addAll({element: key});
      }
    }
  });

  return result;
}
