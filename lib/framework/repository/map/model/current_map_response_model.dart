// To parse this JSON data, do
//
//     final currentMapResponseModel = currentMapResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:odigo_control_room/framework/repository/map/model/map_response_model.dart';



CurrentMapResponseModel currentMapResponseModelFromJson(String str) => CurrentMapResponseModel.fromJson(json.decode(str));

String currentMapResponseModelToJson(CurrentMapResponseModel data) => json.encode(data.toJson());

class CurrentMapResponseModel {
  String? message;
  MapData? data;
  int? status;

  CurrentMapResponseModel({
    this.message,
    this.data,
    this.status,
  });

  factory CurrentMapResponseModel.fromJson(Map<String, dynamic> json) => CurrentMapResponseModel(
    message: json['message'],
    data: json['data'] == null ? null : MapData.fromJson(json['data']),
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'data': data?.toJson(),
    'status': status,
  };
}
