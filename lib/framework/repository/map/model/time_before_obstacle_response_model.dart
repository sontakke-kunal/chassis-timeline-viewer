// To parse this JSON data, do
//
//     final timeBeforeObstacleResponseModel = timeBeforeObstacleResponseModelFromJson(jsonString);

import 'dart:convert';

TimeBeforeObstacleResponseModel timeBeforeObstacleResponseModelFromJson(String str) => TimeBeforeObstacleResponseModel.fromJson(json.decode(str));

String timeBeforeObstacleResponseModelToJson(TimeBeforeObstacleResponseModel data) => json.encode(data.toJson());

class TimeBeforeObstacleResponseModel {
  int time;

  TimeBeforeObstacleResponseModel({
    required this.time,
  });

  factory TimeBeforeObstacleResponseModel.fromJson(Map<String, dynamic> json) => TimeBeforeObstacleResponseModel(
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
  };
}
