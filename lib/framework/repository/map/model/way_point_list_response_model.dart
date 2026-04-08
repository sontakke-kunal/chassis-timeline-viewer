// To parse this JSON data, do
//
//     final wayPointListResponseModel = wayPointListResponseModelFromJson(jsonString);

import 'dart:convert';

WayPointListResponseModel wayPointListResponseModelFromJson(String str) => WayPointListResponseModel.fromJson(json.decode(str));

String wayPointListResponseModelToJson(WayPointListResponseModel data) => json.encode(data.toJson());

class WayPointListResponseModel {
  String? message;
  WayPointData? data;
  int? status;

  WayPointListResponseModel({
    this.message,
    this.data,
    this.status,
  });

  factory WayPointListResponseModel.fromJson(Map<String, dynamic> json) => WayPointListResponseModel(
    message: json['message'],
    data: json['data'] == null ? null : WayPointData.fromJson(json['data']),
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'data': data?.toJson(),
    'status': status,
  };
}

class WayPointData {
  List<Waypoint>? waypoints;

  WayPointData({
    this.waypoints,
  });

  factory WayPointData.fromJson(Map<String, dynamic> json) => WayPointData(
    waypoints: json['waypoints'] == null ? [] : List<Waypoint>.from(json['waypoints']!.map((x) => Waypoint.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'waypoints': waypoints == null ? [] : List<dynamic>.from(waypoints!.map((x) => x.toJson())),
  };
}

class Waypoint {
  String? uuid;
  String? name;
  String? type;
  Pose? pose;

  Waypoint({
    this.uuid,
    this.name,
    this.type,
    this.pose,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    uuid: json['uuid'],
    name: json['name'],
    type: json['type'],
    pose: json['pose'] == null ? null : Pose.fromJson(json['pose']),
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'type': type,
    'pose': pose?.toJson(),
  };
}

class Pose {
  double? x;
  double? y;
  double? theta;

  Pose({
    this.x,
    this.y,
    this.theta,
  });

  factory Pose.fromJson(Map<String, dynamic> json) => Pose(
    x: double.parse(json['x']?.toString() ?? '0'),
    y: double.parse(json['y']?.toString() ?? '0'),
    theta: double.parse(json['theta']?.toString() ?? '0'),
  );

  factory Pose.fromTimelineJson(Map<String, dynamic> json) => Pose(
    x: double.parse(json['x']?.toString() ?? '0'),
    y: double.parse(json['y']?.toString() ?? '0'),
    theta: double.parse(json['t']?.toString() ?? '0'),
  );

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'theta': theta,
  };

  /// Timeline format: [x, y, theta]
  factory Pose.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 3) {
      return Pose(x: 0, y: 0, theta: 0);
    }

    return Pose(
      x: double.tryParse(list[0]?.toString() ?? '0') ?? 0,
      y: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
      theta: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
    );
  }
}
