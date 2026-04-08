// To parse this JSON data, do
//
//     final mapListResponseModel = mapListResponseModelFromJson(jsonString);

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
