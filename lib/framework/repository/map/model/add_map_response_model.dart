// To parse this JSON data, do
//
//     final addMapResponseModel = addMapResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:odigo_control_room/framework/repository/map/model/map_response_model.dart';

AddMapResponseModel addMapResponseModelFromJson(String str) => AddMapResponseModel.fromJson(json.decode(str));

String addMapResponseModelToJson(AddMapResponseModel data) => json.encode(data.toJson());

class AddMapResponseModel {
  String message;
  MapData? data;
  int status;

  AddMapResponseModel({
    required this.message,
    this.data,
    required this.status,
  });

  factory AddMapResponseModel.fromJson(Map<String, dynamic> json) => AddMapResponseModel(
        message: json["message"],
        data: MapData.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "status": status,
      };
}
