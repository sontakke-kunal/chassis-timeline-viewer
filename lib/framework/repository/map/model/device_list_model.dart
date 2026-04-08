// To parse this JSON data, do
//
//     final deviceListResponseModel = deviceListResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:chassis_timeline_viewer/framework/repository/map/model/way_point_list_response_model.dart';


DeviceListResponseModel deviceListResponseModelFromJson(String str) => DeviceListResponseModel.fromJson(json.decode(str));

String deviceListResponseModelToJson(DeviceListResponseModel data) => json.encode(data.toJson());

class DeviceListResponseModel {
  int? pageNumber;
  List<DeviceData>? data;
  bool? hasNextPage;
  int? totalPages;
  bool? hasPreviousPage;
  String? message;
  int? totalCount;
  int? status;

  DeviceListResponseModel({
    this.pageNumber,
    this.data,
    this.hasNextPage,
    this.totalPages,
    this.hasPreviousPage,
    this.message,
    this.totalCount,
    this.status,
  });

  factory DeviceListResponseModel.fromJson(Map<String, dynamic> json) => DeviceListResponseModel(
    pageNumber: json['pageNumber'],
    data: json['data'] == null ? [] : List<DeviceData>.from(json['data']!.map((x) => DeviceData.fromJson(x))),
    hasNextPage: json['hasNextPage'],
    totalPages: json['totalPages'],
    hasPreviousPage: json['hasPreviousPage'],
    message: json['message'],
    totalCount: json['totalCount'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'data': data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    'hasNextPage': hasNextPage,
    'totalPages': totalPages,
    'hasPreviousPage': hasPreviousPage,
    'message': message,
    'totalCount': totalCount,
    'status': status,
  };
}

class DeviceData {
  String? uuid;
  String? serialNumber;
  String? hostName;
  String? navigationVersion;
  String? powerBoardVersion;
  SensorDetails? sensorDetails;
  List<DeviceDetail>? deviceDetails;
  bool? active;
  String? destinationUuid;
  String? destinationName;
  DestinationFloor? destinationFloor;
  bool? inStock;
  bool? isArchive;
  bool? isEmergency;
  dynamic mapsUuid;
  int? lastSequenceReadTime;
  dynamic lastConnected;
  dynamic lastDisconnected;
  String? timeZone;
  bool? isAvailable;
  Pose? pose;
  String color;
  String tag;

  DeviceData({
    this.uuid,
    this.serialNumber,
    this.hostName,
    this.navigationVersion,
    this.powerBoardVersion,
    this.sensorDetails,
    this.deviceDetails,
    this.active,
    this.destinationUuid,
    this.destinationName,
    this.destinationFloor,
    this.inStock,
    this.isArchive,
    this.isEmergency,
    this.mapsUuid,
    this.lastSequenceReadTime,
    this.lastConnected,
    this.lastDisconnected,
    this.timeZone,
    this.isAvailable,
    this.pose,
    this.color = '000000',
    this.tag = '',
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
    uuid: json['uuid'],
    serialNumber: json['serialNumber'],
    tag: json['tag'] ?? json['hostName'] ?? '',
    color: json['colour'] ?? '000000',
    hostName: json['hostName'],
    navigationVersion: json['navigationVersion'],
    powerBoardVersion: json['powerBoardVersion'],
    sensorDetails: json['sensorDetails'] == null ? null : SensorDetails.fromJson(json['sensorDetails']),
    deviceDetails: json['deviceDetails'] == null ? [] : List<DeviceDetail>.from(json['deviceDetails']!.map((x) => DeviceDetail.fromJson(x))),
    active: json['active'],
    destinationUuid: json['destinationUuid'],
    destinationName: json['destinationName'],
    destinationFloor: json['destinationFloor'] == null ? null : DestinationFloor.fromJson(json['destinationFloor']),
    inStock: json['inStock'],
    isArchive: json['isArchive'],
    isEmergency: json['isEmergency'],
    mapsUuid: json['mapsUuid'],
    lastSequenceReadTime: json['lastSequenceReadTime'],
    lastConnected: json['lastConnected'],
    lastDisconnected: json['lastDisconnected'],
    timeZone: json['timeZone'],
    isAvailable: json['isAvailable'],
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'serialNumber': serialNumber,
    'hostName': hostName,
    'navigationVersion': navigationVersion,
    'powerBoardVersion': powerBoardVersion,
    'sensorDetails': sensorDetails?.toJson(),
    'deviceDetails': deviceDetails == null ? [] : List<dynamic>.from(deviceDetails!.map((x) => x.toJson())),
    'active': active,
    'destinationUuid': destinationUuid,
    'destinationName': destinationName,
    'destinationFloor': destinationFloor?.toJson(),
    'inStock': inStock,
    'isArchive': isArchive,
    'isEmergency': isEmergency,
    'mapsUuid': mapsUuid,
    'lastSequenceReadTime': lastSequenceReadTime,
    'lastConnected': lastConnected,
    'lastDisconnected': lastDisconnected,
    'timeZone': timeZone,
    'tag': tag,
    'isAvailable': isAvailable,
    'colour': color,
  };
}

class DestinationFloor {
  String? uuid;
  String? name;
  int? floorNumber;
  bool? active;

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

class DeviceDetail {
  String? uuid;
  String? robotDeviceType;
  String? applicationId;
  String? packageId;
  bool? active;

  DeviceDetail({
    this.uuid,
    this.robotDeviceType,
    this.applicationId,
    this.packageId,
    this.active,
  });

  factory DeviceDetail.fromJson(Map<String, dynamic> json) => DeviceDetail(
    uuid: json['uuid'],
    robotDeviceType: json['robotDeviceType'],
    applicationId: json['applicationId'],
    packageId: json['packageId'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'robotDeviceType': robotDeviceType,
    'applicationId': applicationId,
    'packageId': packageId,
    'active': active,
  };
}

class SensorDetails {
  bool? isImuOk;
  bool? isOdomOk;
  bool? is3DCameraOk;
  bool? isLidarOk;

  SensorDetails({
    this.isImuOk,
    this.isOdomOk,
    this.is3DCameraOk,
    this.isLidarOk,
  });

  factory SensorDetails.fromJson(Map<String, dynamic> json) => SensorDetails(
    isImuOk: json['isImuOk'],
    isOdomOk: json['isOdomOk'],
    is3DCameraOk: json['is3dCameraOk'],
    isLidarOk: json['isLidarOk'],
  );

  Map<String, dynamic> toJson() => {
    'isImuOk': isImuOk,
    'isOdomOk': isOdomOk,
    'is3dCameraOk': is3DCameraOk,
    'isLidarOk': isLidarOk,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
