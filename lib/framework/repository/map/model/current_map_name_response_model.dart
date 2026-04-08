// To parse this JSON data, do
//
//     final currentMapNameResponseModel = currentMapNameResponseModelFromJson(jsonString);

import 'dart:convert';

CurrentMapNameResponseModel currentMapNameResponseModelFromJson(String str) => CurrentMapNameResponseModel.fromJson(json.decode(str));

String currentMapNameResponseModelToJson(CurrentMapNameResponseModel data) => json.encode(data.toJson());

class CurrentMapNameResponseModel {
  String name;
  String alias;

  CurrentMapNameResponseModel({
    required this.name,
    required this.alias,
  });

  factory CurrentMapNameResponseModel.fromJson(Map<String, dynamic> json) => CurrentMapNameResponseModel(
    name: json['name'] ?? '',
    alias: json['alias'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'alias': alias,
  };
}
