// To parse this JSON data, do
//
//     final currentMapResponseModel = currentMapResponseModelFromJson(jsonString);

import 'dart:convert';

CanvasCurrentMapResponseModel canvasCurrentMapResponseModelFromJson(String str) => CanvasCurrentMapResponseModel.fromJson(json.decode(str));

String canvasCurrentMapResponseModelToJson(CanvasCurrentMapResponseModel data) => json.encode(data.toJson());

class CanvasCurrentMapResponseModel {
  double? width;
  double? height;
  double? resolution;
  double? originX;
  double? originY;
  String? imageUrl;

  CanvasCurrentMapResponseModel({
    this.width,
    this.height,
    this.resolution,
    this.originX,
    this.originY,
    this.imageUrl,
  });

  factory CanvasCurrentMapResponseModel.fromJson(Map<String, dynamic> json) => CanvasCurrentMapResponseModel(
        width: json["width"] == null ? null : double.parse(json["width"].toString()),
        height: json["height"] == null ? null : double.parse(json["height"].toString()),
        resolution: json["resolution"]?.toDouble(),
        originX: json["origin_x"]?.toDouble(),
        originY: json["origin_y"]?.toDouble(),
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "resolution": resolution,
        "origin_x": originX,
        "origin_y": originY,
        "image_url": imageUrl,
      };
}
