// To parse this JSON data, do
//
//     final laserDataResponseModel = laserDataResponseModelFromJson(jsonString);

import 'dart:convert';

LaserDataResponseModel laserDataResponseModelFromJson(String str) => LaserDataResponseModel.fromJson(json.decode(str));

String laserDataResponseModelToJson(LaserDataResponseModel data) => json.encode(data.toJson());

class LaserDataResponseModel {
  List<List<double>> coordinates;

  LaserDataResponseModel({
    required this.coordinates,
  });

  factory LaserDataResponseModel.fromJson(Map<String, dynamic> json) => LaserDataResponseModel(
        coordinates: List<List<double>>.from(json["coordinates"].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
      );

  Map<String, dynamic> toJson() => {
        "coordinates": List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
