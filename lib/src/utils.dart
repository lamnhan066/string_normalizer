/// Flat the map
Map<String, String> flatMap(Map<String, Set<String>> map) {
  final data0 = <String, String>{};
  map.forEach((key, value) {
    for (var element in value) {
      data0.addAll({element: key});
    }
  });

  return data0;
}
