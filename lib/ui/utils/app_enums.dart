

enum PointType { CHARGE, DELIVERY, PRODUCTION, ROUTE, ALL, ELEVATOR, STORE }

final pointTypeValues = EnumValues({
  'charge': PointType.CHARGE,
  'delivery': PointType.DELIVERY,
  'production': PointType.PRODUCTION,
  'route': PointType.ROUTE,
  'all': PointType.ALL,
});



class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverse;
  }

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}