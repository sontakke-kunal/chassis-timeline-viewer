// To parse this JSON data, do
//
//     final mapEditRequestModel = mapEditRequestModelFromJson(jsonString);

import 'dart:convert';

import 'package:odigo_control_room/ui/utils/app_enums.dart';

MapEditRequestModel mapEditRequestModelFromJson(String str) => MapEditRequestModel.fromJson(json.decode(str));

String mapEditRequestModelToJson(MapEditRequestModel data) => json.encode(data.toJson());

class MapEditRequestModel {
  List<MapEdit> mapEdit;

  MapEditRequestModel({
    required this.mapEdit,
  });

  factory MapEditRequestModel.fromJson(Map<String, dynamic> json) => MapEditRequestModel(
        mapEdit: List<MapEdit>.from(json['map_edit'].map((x) => MapEdit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'map_edit': List<dynamic>.from(mapEdit.map((x) => x.toJson())),
      };
}

class MapEdit {
  ModifyMapType type;
  List<List<double>> coordinates;

  MapEdit({
    required this.type,
    required this.coordinates,
  });

  factory MapEdit.fromJson(Map<String, dynamic> json) => MapEdit(
        type: displayModifyMapValues.map[json['type']]!,
        coordinates: List<List<double>>.from(json['coordinates'].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
      );

  Map<String, dynamic> toJson() {
    apiModifyMapValues.reverse;
    return {
      'type': apiModifyMapValues.reverseMap[type],
      'coordinates': List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
    };
  }
}

enum ModifyMapType { EMPTY_AREA, BLOCKED_AREA, UNKNOWN_AREA }

final displayModifyMapValues = EnumValues({
  'Empty Area': ModifyMapType.EMPTY_AREA,
  'Blocked Area': ModifyMapType.BLOCKED_AREA,
  'Unknown Area': ModifyMapType.UNKNOWN_AREA,
});

final apiModifyMapValues = EnumValues({
  'free': ModifyMapType.EMPTY_AREA,
  'obstacle': ModifyMapType.BLOCKED_AREA,
  'unknow': ModifyMapType.UNKNOWN_AREA,
});
