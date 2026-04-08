// To parse this JSON data, do
//
//     final virtualWallResponseModel = virtualWallResponseModelFromJson(jsonString);

import 'dart:convert';

VirtualWallResponseModel virtualWallResponseModelFromJson(String str) => VirtualWallResponseModel.fromJson(json.decode(str));

String virtualWallResponseModelToJson(VirtualWallResponseModel data) => json.encode(data.toJson());

class VirtualWallResponseModel {
  List<VirtualWallPoint> waypoints;

  VirtualWallResponseModel({
    required this.waypoints,
  });

  factory VirtualWallResponseModel.fromJson(Map<String, dynamic> json) => VirtualWallResponseModel(
        waypoints: List<VirtualWallPoint>.from(json["waypoints"].map((x) => VirtualWallPoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
      };
}

class VirtualWallPoint {
  VirtualWallPose pose;

  VirtualWallPoint({
    required this.pose,
  });

  factory VirtualWallPoint.fromJson(Map<String, dynamic> json) => VirtualWallPoint(
        pose: VirtualWallPose.fromJson(json["pose"]),
      );

  Map<String, dynamic> toJson() => {
        "pose": pose.toJson(),
      };
}

class EraseVirtualWallPoint {
  EraseVirtualWallPose pose;

  EraseVirtualWallPoint({
    required this.pose,
  });

  factory EraseVirtualWallPoint.fromJson(Map<String, dynamic> json) => EraseVirtualWallPoint(
        pose: EraseVirtualWallPose.fromJson(json["pose"]),
      );

  Map<String, dynamic> toJson() => {
        "pose": pose.toJson(),
      };
}

class VirtualWallPose {
  Point point1;
  Point point2;

  VirtualWallPose({
    required this.point1,
    required this.point2,
  });

  factory VirtualWallPose.fromJson(Map<String, dynamic> json) => VirtualWallPose(
    point1: Point.fromJson(json["point1"]),
    point2: Point.fromJson(json["point2"]),
  );

  Map<String, dynamic> toJson() => {
    "point1": point1.toJson(),
    "point2": point2.toJson(),
  };
}

class EraseVirtualWallPose {
  Point point1;
  Point point2;
  Point point3;
  Point point4;

  EraseVirtualWallPose({
    required this.point1,
    required this.point2,
    required this.point3,
    required this.point4,
  });

  factory EraseVirtualWallPose.fromJson(Map<String, dynamic> json) => EraseVirtualWallPose(
        point1: Point.fromJson(json["point1"]),
        point2: Point.fromJson(json["point2"]),
        point3: Point.fromJson(json["point3"]),
        point4: Point.fromJson(json["point4"]),
      );

  Map<String, dynamic> toJson() => {
        "point1": point1.toJson(),
        "point2": point2.toJson(),
        "point3": point3.toJson(),
        "point4": point4.toJson(),
      };
}

class Point {
  double x;
  double y;

  Point({
    required this.x,
    required this.y,
  });

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        x: json["x"].toDouble(),
        y: json["y"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
