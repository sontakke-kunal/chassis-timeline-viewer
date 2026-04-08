// To parse this JSON data, do
//
//     final relocationResponseModel = relocationResponseModelFromJson(jsonString);

import 'dart:convert';

RelocationResponseModel relocationResponseModelFromJson(String str) => RelocationResponseModel.fromJson(json.decode(str));

String relocationResponseModelToJson(RelocationResponseModel data) => json.encode(data.toJson());

class RelocationResponseModel {
  RelocationPoint startPoint;
  RelocationPoint endPoint;
  double theta;

  RelocationResponseModel({
    required this.startPoint,
    required this.endPoint,
    required this.theta,
  });

  factory RelocationResponseModel.fromJson(Map<String, dynamic> json) => RelocationResponseModel(
        startPoint: RelocationPoint.fromJson(json['startPoint']),
        endPoint: RelocationPoint.fromJson(json['endPoint']),
        theta: json['theta'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'startPoint': startPoint.toJson(),
        'endPoint': endPoint.toJson(),
        'theta': theta,
      };
}

class RelocationPoint {
  double x;
  double y;

  RelocationPoint({
    required this.x,
    required this.y,
  });

  factory RelocationPoint.fromJson(Map<String, dynamic> json) => RelocationPoint(
        x: json['x'].toDouble(),
        y: json['y'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}
