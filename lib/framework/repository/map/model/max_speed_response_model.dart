// To parse this JSON data, do
//
//     final maxSpeedResponseModel = maxSpeedResponseModelFromJson(jsonString);

import 'dart:convert';

MaxSpeedResponseModel maxSpeedResponseModelFromJson(String str) => MaxSpeedResponseModel.fromJson(json.decode(str));

String maxSpeedResponseModelToJson(MaxSpeedResponseModel data) => json.encode(data.toJson());

class MaxSpeedResponseModel {
  double speed;

  MaxSpeedResponseModel({
    required this.speed,
  });

  factory MaxSpeedResponseModel.fromJson(Map<String, dynamic> json) => MaxSpeedResponseModel(
    speed: json["speed"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "speed": speed,
  };
}
