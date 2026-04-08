// To parse this JSON data, do
//
//     final specialAreaResponseModel = specialAreaResponseModelFromJson(jsonString);

import 'dart:convert';

SpecialAreaResponseModel specialAreaResponseModelFromJson(String str) => SpecialAreaResponseModel.fromJson(json.decode(str));

String specialAreaResponseModelToJson(SpecialAreaResponseModel data) => json.encode(data.toJson());

class SpecialAreaResponseModel {
  List<Polygon> polygons;

  SpecialAreaResponseModel({
    required this.polygons,
  });

  factory SpecialAreaResponseModel.fromJson(Map<String, dynamic> json) => SpecialAreaResponseModel(
        polygons: List<Polygon>.from(json['polygons'].map((x) => Polygon.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'polygons': List<dynamic>.from(polygons.map((x) => x.toJson())),
      };
}

class Polygon {
  String name;
  double speed;
  List<List<double>> polygon;
  int type;

  Polygon({
    required this.name,
    required this.speed,
    required this.polygon,
    required this.type,
  });

  factory Polygon.fromJson(Map<String, dynamic> json) => Polygon(
        name: json['name'],
        speed: json['speed'].toDouble(),
        polygon: List<List<double>>.from(json['polygon'].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'speed': speed,
        'polygon': List<dynamic>.from(polygon.map((x) => List<dynamic>.from(x.map((x) => x)))),
        'type': type,
      };
}
