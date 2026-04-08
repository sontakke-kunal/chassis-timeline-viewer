// To parse this JSON data, do
//
//     final deliveryPointsRequestModel = deliveryPointsRequestModelFromJson(jsonString);

import 'dart:convert';
import 'package:odigo_control_room/framework/repository/ip_map/model/delivery_points_response_model.dart';
import 'package:odigo_control_room/framework/repository/store_mapping/model/way_point_list_response_model.dart';


DeliveryPointsRequestModel deliveryPointsRequestModelFromJson(String str) => DeliveryPointsRequestModel.fromJson(json.decode(str));

String deliveryPointsRequestModelToJson(DeliveryPointsRequestModel data) => json.encode(data.toJson());

class DeliveryPointsRequestModel {
  String? robotUuid;
  String? mapsUuid;
  List<Waypoint>? waypoints;

  DeliveryPointsRequestModel({
    this.waypoints,
    this.robotUuid,
    this.mapsUuid,
  });

  factory DeliveryPointsRequestModel.fromJson(Map<String, dynamic> json) => DeliveryPointsRequestModel(
        waypoints: json['waypoints'] == null ? [] : List<Waypoint>.from(json['waypoints']!.map((x) => Waypoint.fromJson(x))),
        robotUuid: json['robotUuid'] ?? '',
        mapsUuid: json['mapsUuid'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'waypoints': waypoints == null ? [] : List<dynamic>.from(waypoints!.map((x) => x.toJson())),
        'robotUuid': robotUuid,
        'mapsUuid': mapsUuid,
      };
}
