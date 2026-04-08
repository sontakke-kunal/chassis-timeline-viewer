// To parse this JSON data, do
//
//     final mapListResponseModel = mapListResponseModelFromJson(jsonString);
import 'dart:convert';
class MapData {
  String? name;
  String? alias;
  String? mapsName;
  double? width;
  double? height;
  double? resolution;
  double? originX;
  double? originY;
  String? imageUrl;

  MapData({
    this.name,
    this.alias,
    this.mapsName,
    this.width,
    this.height,
    this.resolution,
    this.originX,
    this.originY,
    this.imageUrl,
  });

  factory MapData.fromJson(Map<String, dynamic> json) => MapData(
    name: json['name'],
    alias: json['alias'],
    mapsName: json['mapsName'],
    width: json['width'],
    height: json['height'],
    resolution: json['resolution'],
    originX: json['origin_x'],
    originY: json['origin_y'],
    imageUrl: json['image_url'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'alias': alias,
    'mapsName': mapsName,
    'width': width,
    'height': height,
    'resolution': resolution,
    'originX': originX,
    'originY': originY,
    'imageUrl': imageUrl,
  };
}


MapListResponseModel mapListResponseModelFromJson(String str) => MapListResponseModel.fromJson(json.decode(str));

String mapListResponseModelToJson(MapListResponseModel data) => json.encode(data.toJson());

class MapListResponseModel {
  final String? message;
  final List<MapListData>? data;
  final int? status;

  MapListResponseModel({
    this.message,
    this.data,
    this.status,
  });

  factory MapListResponseModel.fromJson(Map<String, dynamic> json) => MapListResponseModel(
    message: json['message'],
    data: json['data'] == null ? [] : List<MapListData>.from(json['data']!.map((x) => MapListData.fromJson(x))),
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'data': data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    'status': status,
  };
}

class MapListData {
  final String? uuid;
  final String? name;
  final String? alias;
  final String? mapsName;
  final double? width;
  final double? height;
  final double? resolution;
  final double? originX;
  final double? originY;
  final String? imageUrl;
  final bool? isCurrent;
  final bool? active;
  final String? mapsImageUrl;
  final dynamic destinationFloorUuid;
  final String? destinationUuid;
  final DestinationFloor? destinationFloor;

  MapListData({
    this.uuid,
    this.name,
    this.alias,
    this.mapsName,
    this.width,
    this.height,
    this.resolution,
    this.originX,
    this.originY,
    this.imageUrl,
    this.isCurrent,
    this.active,
    this.mapsImageUrl,
    this.destinationFloorUuid,
    this.destinationUuid,
    this.destinationFloor,
  });

  factory MapListData.fromJson(Map<String, dynamic> json) => MapListData(
    uuid: json['uuid'],
    name: json['name'],
    alias: json['alias'],
    mapsName: json['mapsName'],
    width: json['width'],
    height: json['height'],
    resolution: json['resolution'],
    originX: json['originX'],
    originY: json['originY'],
    imageUrl: json['imageUrl'],
    isCurrent: json['isCurrent'],
    active: json['active'],
    mapsImageUrl: json['mapsImageUrl'],
    destinationFloorUuid: json['destinationFloorUuid'],
    destinationUuid: json['destinationUuid'],
    destinationFloor: json['destinationFloor'] == null ? null : DestinationFloor.fromJson(json['destinationFloor']),
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'alias': alias,
    'mapsName': mapsName,
    'width': width,
    'height': height,
    'resolution': resolution,
    'originX': originX,
    'originY': originY,
    'imageUrl': imageUrl,
    'isCurrent': isCurrent,
    'active': active,
    'mapsImageUrl': mapsImageUrl,
    'destinationFloorUuid': destinationFloorUuid,
    'destinationUuid': destinationUuid,
    'destinationFloor': destinationFloor?.toJson(),
  };
}

class DestinationFloor {
  final String? uuid;
  final String? name;
  final int? floorNumber;
  final bool? active;

  DestinationFloor({
    this.uuid,
    this.name,
    this.floorNumber,
    this.active,
  });

  factory DestinationFloor.fromJson(Map<String, dynamic> json) => DestinationFloor(
    uuid: json['uuid'],
    name: json['name'],
    floorNumber: json['floorNumber'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'floorNumber': floorNumber,
    'active': active,
  };
}
