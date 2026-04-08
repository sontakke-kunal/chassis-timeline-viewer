class MapData {
  String? uuid;
  String? clientUuid;
  String? name;
  String? mapsName;
  String? alias;
  double? width;
  double? height;
  double? resolution;
  double? originX;
  double? originY;
  String? imageUrl;
  bool? isCurrent;
  String? mapsImageUrl;

  MapData({
    this.uuid,
    required this.clientUuid,
    this.name,
    required this.mapsName,
    this.alias,
    this.width,
    this.height,
    this.resolution,
    this.originX,
    this.originY,
    this.imageUrl,
    this.isCurrent,
    this.mapsImageUrl,
  });

  factory MapData.fromJson(Map<String, dynamic> json) => MapData(
    uuid: json['uuid'],
    clientUuid: json['clientUuid'],
    name: json['name'],
    mapsName: json['mapsName'],
    alias: json['alias'],
    width: json['width'],
    height: json['height'],
    resolution: json['resolution']?.toDouble(),
    originX: json['originX']?.toDouble(),
    originY: json['originY']?.toDouble(),
    imageUrl: json['imageUrl'],
    isCurrent: json['isCurrent'],
    mapsImageUrl: json['mapsImageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'clientUuid': clientUuid,
    'name': name,
    'mapsName': mapsName,
    'alias': alias,
    'width': width,
    'height': height,
    'resolution': resolution,
    'originX': originX,
    'originY': originY,
    'imageUrl': imageUrl,
    'isCurrent': isCurrent,
    'mapsImageUrl': mapsImageUrl,
  };
}


class MapData2 {
  String? uuid;
  String? clientUuid;
  String? name;
  String? mapsName;
  String? floorNumber;
  String? alias;
  double? width;
  double? height;
  double? resolution;
  double? originX;
  double? originY;
  String? imageUrl;
  bool? isCurrent;
  String? mapsImageUrl;


  MapData2({
    this.uuid,
    required this.clientUuid,
    this.name,
    required this.mapsName,
    this.floorNumber,
    this.alias,
    this.width,
    this.height,
    this.resolution,
    this.originX,
    this.originY,
    this.imageUrl,
    this.isCurrent,
    this.mapsImageUrl,
  });

  factory MapData2.fromJson(Map<String, dynamic> json) => MapData2(
    uuid: json['uuid'],
    clientUuid: json['clientUuid'],
    name: json['name'],
    mapsName: json['mapsName'],
    floorNumber: json['floorNumber']?.toString(),
    alias: json['alias'],
    width: json['width'],
    height: json['height'],
    resolution: json['resolution']?.toDouble(),
    originX: json['originX']?.toDouble(),
    originY: json['originY']?.toDouble(),
    imageUrl: json['imageUrl'],
    isCurrent: json['isCurrent'],
    mapsImageUrl: json['mapsImageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'clientUuid': clientUuid,
    'name': name,
    'mapsName': mapsName,
    'floorNumber' :floorNumber,
    'alias': alias,
    'width': width,
    'height': height,
    'resolution': resolution,
    'originX': originX,
    'originY': originY,
    'imageUrl': imageUrl,
    'isCurrent': isCurrent,
    'mapsImageUrl': mapsImageUrl,
  };
}