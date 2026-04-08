// To parse this JSON data, do
//
//     final allMapsResponseModel = allMapsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:odigo_control_room/framework/repository/map/model/map_response_model.dart';


AllMapsResponseModel allMapsResponseModelFromJson(String str) => AllMapsResponseModel.fromJson(json.decode(str));

String allMapsResponseModelToJson(AllMapsResponseModel data) => json.encode(data.toJson());

class AllMapsResponseModel {
  String? message;
  List<MapData>? data;
  int? status;

  AllMapsResponseModel({
    this.message,
    this.data,
    this.status,
  });

  factory AllMapsResponseModel.fromJson(Map<String, dynamic> json) => AllMapsResponseModel(
        message: json['message'],
        data: json['data'] == null ? [] : List<MapData>.from(json['data']!.map((x) => MapData.fromJson(x))),
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        'status': status,
      };
}
