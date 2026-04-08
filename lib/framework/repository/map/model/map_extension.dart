extension MapExtension<T> on Map {
  Map<T, String> get reverse {
    return map((k, v) => MapEntry(v, k));
  }

  Map<String, List<List<double>>> get toRouteMap {
    Map<String, List<List<double>>> routesMap = ({});
    forEach((key, value) {
      List<List<double>> allPointsList = [];
      for (var allPoints in (value as List<dynamic>)) {
        List<double> pointsList = [];
        for (var points in (allPoints as List<dynamic>)) {
          pointsList.add(double.parse(points.toString()));
        }
        allPointsList.add(pointsList);
      }
      routesMap[key] = allPointsList;
    });
    return routesMap;
  }


  Map<String, dynamic> get responseMap {
    Map<String, dynamic> responseMap = {};
    forEach((key, value) {
      responseMap[key.toString()] = value;
    });
    return responseMap;
  }
}
