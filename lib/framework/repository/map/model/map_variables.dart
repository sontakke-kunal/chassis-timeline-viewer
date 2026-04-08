import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as IMG;

class MapVariables {
  double arrowSize = 15;
  static double odigoHeight = 40;
  static double odigoWidth = 40;

  double originX = 0.0;
  double originY = 0.0;
  double resolution = 0.0;
  double width = 0.0;
  double height = 0.0;
  double centerX = 0.0;
  double centerY = 0.0;
  String currentMap = '';
  String mapsUuid = '';

  void initializeMapConstants(String mapsUuid, String currentMap, double originX, double originY, double resolution, double width, double height, double centerX, double centerY) {
    this.mapsUuid = mapsUuid;
    this.currentMap = currentMap;
    this.originX = originX;
    this.originY = originY;
    this.resolution = resolution;
    this.width = width;
    this.height = height;
    this.centerX = centerX;
    this.centerY = centerY;
  }

  Future<ui.Image> loadImage({int? height, int? width, bool doChangeColor = true}) async {
    Uint8List img = base64Decode(currentMap.replaceAll('data:image/png;base64,', ''));
    if (height != null && width != null) {
      final IMG.Image? image = IMG.decodeImage(img);
      if (image != null) {
        final IMG.Image resized = IMG.copyResize(image, width: width, height: height);
        img = IMG.encodePng(resized);
      }
    }
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    if (doChangeColor) {
      return await changeColor(await completer.future);
    }
    return (await completer.future);
  }

  Future<ui.Image> changeColor(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final Uint8List data = byteData!.buffer.asUint8List();

    /// Target color which you want to change in your image
    int targetColor = AppColors.mapColor.value;

    /// New color which you want to replace to target color
    // int newColor = AppColors.clr00D1FF.value;
    int newColor = AppColors.newMapColor.value;

    for (int i = 0; i < data.length; i += 4) {
      int r = data[i];
      int g = data[i + 1];
      int b = data[i + 2];

      /// Check if the pixel color is approximately equal to the target color
      if (_approximateColor(r, g, b, targetColor)) {
        data[i] = (newColor >> 16) & 0xFF; // Red
        data[i + 1] = (newColor >> 8) & 0xFF; // Green
        data[i + 2] = newColor & 0xFF; // Blue
      }
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(buffer, width: image.width, height: image.height, pixelFormat: ui.PixelFormat.rgba8888);
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<Uint8List?> changeColorBytes(Uint8List image) async {
    final Uint8List data = image;

    /// Target color which you want to change in your image
    int targetColor = AppColors.mapColor.value;

    /// New color which you want to replace to target color
    // int newColor = AppColors.clr00D1FF.value;
    int newColor = AppColors.newMapColor.value;

    for (int i = 0; i < data.length; i += 4) {
      int r = data[i];
      int g = data[i + 1];
      int b = data[i + 2];

      /// Check if the pixel color is approximately equal to the target color
      if (_approximateColor(r, g, b, targetColor)) {
        data[i] = (newColor >> 16) & 0xFF; // Red
        data[i + 1] = (newColor >> 8) & 0xFF; // Green
        data[i + 2] = newColor & 0xFF; // Blue
      }
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(buffer, width: 100, height: 100, pixelFormat: ui.PixelFormat.rgba8888);
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData())?.buffer.asUint8List();
  }

  bool _approximateColor(int r1, int g1, int b1, int color) {
    int r2 = (color >> 16) & 0xFF;
    int g2 = (color >> 8) & 0xFF;
    int b2 = color & 0xFF;

    /// Define a tolerance level for color approximation
    int tolerance = 30;

    /// Check if the difference between the RGB values is within the tolerance level
    return (r1 - r2).abs() <= tolerance && (g1 - g2).abs() <= tolerance && (b1 - b2).abs() <= tolerance;
  }
}

class SvgRootLoader {
  SvgRootLoader._();

  static SvgRootLoader svg = SvgRootLoader._();

  Future<PictureInfo> loadSvgRoot(String assetPath) async {
    final rawSvg = await rootBundle.loadString(assetPath);
    final pictureInfo = await vg.loadPicture(SvgStringLoader(rawSvg), null);
    return pictureInfo;
  }
}
