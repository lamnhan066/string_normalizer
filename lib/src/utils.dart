/// Flat the map
Map<int, String> flatMap(Map<String, Set<int>> map) {
  final Map<int, String> data0 = {};
  map.forEach((key, value) {
    for (var element in value) {
      data0.addAll({element: key});
    }
  });

  return data0;
}
