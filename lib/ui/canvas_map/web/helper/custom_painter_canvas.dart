import 'dart:math';

import 'package:chassis_timeline_viewer/framework/repository/map/model/device_list_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/relocation_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/virtual_wall_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/way_point_list_response_model.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/graph_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_enums.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';

class MapPainterCanvas extends CustomPainter {
  final ui.Image image;
  final double scale;
  final MapVariables mapVariables;

  MapPainterCanvas({
    required this.image,
    required this.scale,
    required this.mapVariables,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    Paint painter = Paint();
    painter.color = AppColors.clrB50000;
    painter.color = AppColors.newMapColor;
    if ((scale) > 3) {
      painter.imageFilter = ui.ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4);
      painter.blendMode = BlendMode.srcOver;
    } else {
      painter = ui.Paint()..color = AppColors.newMapColor;
    }
    canvas.drawImage(image, const Offset(0, 0), painter);
    painter = ui.Paint()..color = AppColors.newMapColor;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PositionPainterCanvas extends CustomPainter {
  final double scale;
  final DeviceData robot;
  final dynamic previousPose;
  final double animationT; // 0..1
  final MapVariables mapVariables;

  PositionPainterCanvas({
    required this.scale,
    required this.robot,
    required this.mapVariables,
    this.previousPose,
    this.animationT = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    drawRobotPose(canvas, size, robot);
  }

  drawRobotPose(Canvas canvas, Size size, DeviceData robot) {
    final currentPosition = robot.pose;
    if (currentPosition == null) return;

    // Interpolate pose to avoid jumps between updates.
    final prev = previousPose;

    double x = (currentPosition.x as num?)?.toDouble() ?? 0.0;
    double y = (currentPosition.y as num?)?.toDouble() ?? 0.0;
    double theta = (currentPosition.theta as num?)?.toDouble() ?? 0.0;

    if (prev != null) {
      final prevX = (prev.x as num?)?.toDouble() ?? x;
      final prevY = (prev.y as num?)?.toDouble() ?? y;
      final prevTheta = (prev.theta as num?)?.toDouble() ?? theta;

      final t = animationT.clamp(0.0, 1.0);
      x = ui.lerpDouble(prevX, x, t) ?? x;
      y = ui.lerpDouble(prevY, y, t) ?? y;
      theta = _lerpTheta(prevTheta, theta, t);
    }

    final xPoint = x.convertXFromDasherPoint(mapVariables);
    final yPoint = y.convertYFromDasherPoint(mapVariables);

    final Offset centerPosition = Offset(MapVariables.odigoWidth / 2, MapVariables.odigoHeight / 2);

    canvas.translate(xPoint - centerPosition.dx, yPoint - centerPosition.dy);
    canvas.translate(centerPosition.dx, centerPosition.dy);

    // Convert theta (radians) to degrees, normalize to 0..360 like before.
    var thetaAngle = theta * (180 / pi);
    if (thetaAngle < 0) {
      thetaAngle += 360;
    }

    canvas.rotate((thetaAngle * (pi / 180)) * -1);

    final double inverseScale = 1.0 / (scale);
    canvas.scale(inverseScale);
    canvas.translate(-centerPosition.dx, -centerPosition.dy);
    canvas.rotate(pi / 2);

    drawMaterialIcon(
      canvas,
      icon: Icons.navigation,
      color: robot.color != null ? robot.color!.colorFromHex : AppColors.black,
      at: Offset(centerPosition.dx, -centerPosition.dy),
      size: 25,
    );

    canvas.scale(1 / inverseScale);
    canvas.translate(-(xPoint - centerPosition.dx), -(yPoint - centerPosition.dy));
  }

  double _lerpTheta(double from, double to, double t) {
    // Lerp angles in radians using the shortest path.
    final double twoPi = 2 * pi;
    double delta = (to - from) % twoPi;
    if (delta > pi) delta -= twoPi;
    if (delta < -pi) delta += twoPi;
    return from + delta * t;
  }

  void drawMaterialIcon(Canvas canvas, {required IconData icon, required Offset at, required double size, required Color color}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the icon around `at`
    final offset = at - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  void drawColoredPicture(Canvas canvas, ui.Picture picture, Color color) {
    final Paint paint = Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);

    canvas.saveLayer(null, paint);
    canvas.drawPicture(picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PositionPainterCanvas oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.robot.pose != robot.pose ||
        oldDelegate.previousPose != previousPose ||
        oldDelegate.animationT != animationT ||
        oldDelegate.mapVariables != mapVariables;
  }
}

class RelocationPainterCanvas extends CustomPainter {
  final double scale;
  final RelocationResponseModel? pose;
  final String? color;
  final MapVariables mapVariables;

  RelocationPainterCanvas({
    required this.scale,
    required this.pose,
    required this.mapVariables,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    drawRobotPose(canvas, size, ui.Paint(), pose);
  }

  drawRobotPose(Canvas canvas, Size size, Paint painter, RelocationResponseModel? currentPosition) {
    if (currentPosition != null) {
      canvas.drawLine(Offset(currentPosition.startPoint.x, currentPosition.startPoint.y), Offset(currentPosition.endPoint.x, currentPosition.endPoint.y), painter);
      final xPoint = currentPosition.startPoint.x;
      final yPoint = currentPosition.startPoint.y;
      final Offset centerPosition = Offset(MapVariables.odigoWidth / 2, MapVariables.odigoHeight / 2);
      canvas.translate(xPoint - centerPosition.dx, yPoint - centerPosition.dy);
      canvas.translate(centerPosition.dx, centerPosition.dy);
      var thetaAngle = currentPosition.theta * (180 / pi);
      if (thetaAngle < 0) {
        thetaAngle += 360;
      }
      canvas.rotate((thetaAngle * (pi / 180)) * -1);
      final double inverseScale = 1.0 / (scale);
      canvas.scale(inverseScale);
      canvas.translate(-centerPosition.dx, -centerPosition.dy);
      canvas.rotate(pi / 2);
      drawMaterialIcon(canvas, icon: Icons.navigation, color: color != null ? color!.colorFromHex : AppColors.black, at: Offset(centerPosition.dx, -centerPosition.dy), size: 25);
      canvas.scale(1 / inverseScale);
      canvas.translate(-(xPoint - centerPosition.dx), -(yPoint - centerPosition.dy));
    }
  }

  void drawMaterialIcon(Canvas canvas, {required IconData icon, required Offset at, required double size, required Color color}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the icon around `at`
    final offset = at - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  void drawColoredPicture(Canvas canvas, ui.Picture picture, Color color) {
    final Paint paint = Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);

    canvas.saveLayer(null, paint);
    canvas.drawPicture(picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaypointsPainterCanvas extends CustomPainter {
  final PictureInfo? chargingPointImage;
  final PictureInfo? productionPointImage;
  final PictureInfo? deliveryPointImage;
  final List<Waypoint>? wayPoints;
  final List<PointType> selectedPointType;
  final MapVariables mapVariables;
  final double scale;

  WaypointsPainterCanvas({
    this.chargingPointImage,
    this.productionPointImage,
    this.deliveryPointImage,
    this.wayPoints,
    required this.scale,
    required this.selectedPointType,
    required this.mapVariables,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    ui.Paint painter = ui.Paint();
    if (wayPoints != null) {
      wayPoints?.forEach((points) {
        if (selectedPointType.contains(pointTypeValues.map[points.type])) {
          drawPoints(canvas, painter, size, double.parse((points.pose?.x).toString()), double.parse((points.pose?.y).toString()), points.name ?? '', pointTypeValues.map[points.type]);
        }
      });
    }
  }

  void drawPoints(ui.Canvas canvas, Paint painter, ui.Size size, double dx, double dy, String name, PointType? type) {
    final xPoint = dx.convertXFromDasherPoint(mapVariables);
    final yPoint = dy.convertYFromDasherPoint(mapVariables);
    Color textColor = Colors.black;
    double desiredWidth = (18 / ((1.2) - 0.5));
    double desiredHeight = (18.0 / ((1.2) - 0.5));
    if ((scale) > 1.25) {
      desiredWidth = (24.0 / ((scale) - 0.5));
      desiredHeight = (24.0 / ((scale) - 0.5));
    }
    canvas.translate(xPoint - (desiredWidth / 2), yPoint - desiredHeight);
    switch (type) {
      case PointType.PRODUCTION:
        textColor = const ui.Color(0xFFAFB42C);
        // Calculate scaling factors
        final scaleX = desiredWidth / productionPointImage!.size.width;
        final scaleY = desiredHeight / productionPointImage!.size.height;
        canvas.scale(scaleX, scaleY);
        canvas.drawPicture(productionPointImage!.picture);
        // productionPointImage!.draw(canvas, Rect.fromPoints(Offset(xPoint, yPoint), Offset.zero));
        canvas.scale((1 / scaleX), (1 / scaleY));
        break;
      case PointType.CHARGE:
        textColor = const ui.Color(0xFF03950C);
        final scaleX = desiredWidth / chargingPointImage!.size.width;
        final scaleY = desiredHeight / chargingPointImage!.size.height;
        canvas.scale(scaleX, scaleY);
        canvas.drawPicture(chargingPointImage!.picture);
        // chargingPointImage!.draw(canvas, Rect.fromPoints(Offset(xPoint, yPoint), Offset.zero));
        canvas.scale((1 / scaleX), (1 / scaleY));
        break;
      default:
        textColor = const ui.Color(0xFF126EEf);
        final scaleX = desiredWidth / deliveryPointImage!.size.width;
        final scaleY = desiredHeight / deliveryPointImage!.size.height;
        canvas.scale(scaleX, scaleY);
        canvas.drawPicture(deliveryPointImage!.picture);
        // deliveryPointImage!.draw(canvas, Rect.fromPoints(Offset(xPoint, yPoint), Offset.zero));
        canvas.scale((1 / scaleX), (1 / scaleY));
        break;
    }
    canvas.translate((xPoint - (desiredWidth / 2)) * -1, (yPoint - (desiredHeight)) * -1);
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: (11 / (scale)), fontWeight: FontWeight.w800))
      ..pushStyle(ui.TextStyle(color: textColor))
      ..addText(name);
    final ui.Paragraph paragraph = paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: (size.width ?? 0)));
    canvas.drawParagraph(paragraph, Offset(xPoint - (paragraph.longestLine / 2), yPoint + (5 / (scale)) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RoutesPainterCanvas extends CustomPainter {
  final PictureInfo? routeImage;
  final Map<String, List<List<double>>>? naviRoutes;
  final List<List<double>>? currentlyDrawingRoute;
  final List<double>? currentMouseCursorPosition;
  final List<PointType> pointTypeList;
  final MapVariables mapVariables;
  final double scale;

  RoutesPainterCanvas({
    this.routeImage,
    this.naviRoutes,
    required this.scale,
    required this.pointTypeList,
    required this.mapVariables,
    this.currentlyDrawingRoute,
    this.currentMouseCursorPosition,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    ui.Paint painter = ui.Paint();
    if (naviRoutes != null && (pointTypeList.contains(PointType.ROUTE))) {
      naviRoutes?.forEach((name, points) {
        drawNaviRoutes(canvas, painter, size, name, points);
      });
    }
    if (currentlyDrawingRoute != null && currentMouseCursorPosition != null) {
      drawCreatingRoute(canvas, painter, size);
    }
  }

  void drawCreatingRoute(ui.Canvas canvas, Paint painter, ui.Size size) {
    painter.color = const ui.Color(0xFF2FB9F8);
    if (currentlyDrawingRoute?.isNotEmpty ?? false) {
      canvas.drawLine(Offset(currentlyDrawingRoute!.last.first, currentlyDrawingRoute!.last.last), Offset(currentMouseCursorPosition!.first, currentMouseCursorPosition!.last), painter);
    }
    painter.color = const ui.Color(0xFF2FB9F8);
    for (var routePath in currentlyDrawingRoute!) {
      canvas.drawCircle(Offset(routePath.first, routePath.last), 4 / (scale ?? 1), painter);
    }
    int routePathIndex = 0;
    for (routePathIndex = 0; routePathIndex < currentlyDrawingRoute!.length; routePathIndex++) {
      double x1Point = currentlyDrawingRoute![routePathIndex].first;
      double y1Point = currentlyDrawingRoute![routePathIndex].last;
      double x2Point = 0;
      double y2Point = 0;
      if (routePathIndex != (currentlyDrawingRoute!.length - 1)) {
        x2Point = currentlyDrawingRoute![routePathIndex + 1].first;
        y2Point = currentlyDrawingRoute![routePathIndex + 1].last;
        Offset end = ui.Offset(x2Point, y2Point);
        Offset start = ui.Offset(x1Point, y1Point);
        canvas.drawLine(start, end, painter);
      }
    }
  }

  void drawNaviRoutes(ui.Canvas canvas, Paint painter, ui.Size size, String name, List<List<double>> route) {
    painter.color = const ui.Color(0xFFBB7F4D);
    painter.strokeWidth = 1;
    for (var routePath in route) {
      canvas.drawCircle(Offset(routePath.first.convertXFromDasherPoint(mapVariables), routePath.last.convertYFromDasherPoint(mapVariables)), 2 / (scale), painter);
    }
    int routePathIndex = 0;
    for (routePathIndex = 0; routePathIndex < route.length; routePathIndex++) {
      double x1Point = route[routePathIndex].first.convertXFromDasherPoint(mapVariables);
      double y1Point = route[routePathIndex].last.convertYFromDasherPoint(mapVariables);
      double x2Point = 0;
      double y2Point = 0;
      if (routePathIndex == (route.length - 1)) {
        x2Point = route[0].first.convertXFromDasherPoint(mapVariables);
        y2Point = route[0].last.convertYFromDasherPoint(mapVariables);
      } else {
        x2Point = route[routePathIndex + 1].first.convertXFromDasherPoint(mapVariables);
        y2Point = route[routePathIndex + 1].last.convertYFromDasherPoint(mapVariables);
        if (routePathIndex == 0) {
          final xPoint = route[routePathIndex].first.convertXFromDasherPoint(mapVariables);
          final yPoint = route[routePathIndex].last.convertYFromDasherPoint(mapVariables);
          Color textColor = Colors.black;
          double desiredWidth = (24.0 / ((1.2) - 0.5));
          double desiredHeight = (24.0 / ((1.2) - 0.5));
          if ((scale) > 1.2) {
            desiredWidth = (24.0 / ((scale) - 0.5));
            desiredHeight = (24.0 / ((scale) - 0.5));
          }
          canvas.translate(xPoint - (desiredWidth / 2), yPoint - desiredHeight);
          textColor = const ui.Color(0xFFBB7F4D);
          final scaleX = desiredWidth / routeImage!.size.width;
          final scaleY = desiredHeight / routeImage!.size.height;
          canvas.scale(scaleX, scaleY);
          canvas.drawPicture(routeImage!.picture);
          // routeImage!.draw(canvas, Rect.fromPoints(Offset(xPoint, yPoint), Offset.zero));
          canvas.scale((1 / scaleX), (1 / scaleY));
          canvas.translate((xPoint - (desiredWidth / 2)) * -1, (yPoint - (desiredHeight)) * -1);
          final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: (11 / (scale)), fontWeight: FontWeight.w800))
            ..pushStyle(ui.TextStyle(color: textColor))
            ..addText(name);
          final ui.Paragraph paragraph = paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: (size.width ?? 0)));
          canvas.drawParagraph(paragraph, Offset(xPoint - (paragraph.longestLine / 2), yPoint + (5 / (scale)) / 2));
        }
        Offset end = ui.Offset(x2Point, y2Point);
        Offset start = ui.Offset(x1Point, y1Point);
        double totalDistance = (end - start).distance;
        double dx = (end.dx - start.dx) / totalDistance;
        double dy = (end.dy - start.dy) / totalDistance;

        double currentDistance = 0;
        double dashLength = 4;
        double dashGap = 2;

        while (currentDistance < totalDistance) {
          final double startX = start.dx + dx * currentDistance;
          final double startY = start.dy + dy * currentDistance;

          currentDistance += dashLength;

          if (currentDistance > totalDistance) {
            currentDistance = totalDistance;
          }

          final double endX = start.dx + dx * currentDistance;
          final double endY = start.dy + dy * currentDistance;

          canvas.drawLine(Offset(startX, startY), Offset(endX, endY), painter);

          currentDistance += dashGap;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VirtualWallPainterCanvas extends CustomPainter {
  final double scale;
  final List<VirtualWallPoint> virtualWalls;
  final List<VirtualWallPoint>? drawnVirtualWalls;
  final VirtualWallPoint? currentlyDrawingVirtualWall;
  final MapVariables mapVariables;
  final EraseVirtualWallPoint? erasedVirtualWallData;

  VirtualWallPainterCanvas({
    required this.virtualWalls,
    required this.scale,
    required this.mapVariables,
    this.drawnVirtualWalls,
    this.currentlyDrawingVirtualWall,
    this.erasedVirtualWallData,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    ui.Paint painter = ui.Paint();
    if (currentlyDrawingVirtualWall != null) {
      drawStartAndEndOfVirtualWall(canvas, painter, currentlyDrawingVirtualWall!.pose);
    }
    for (var walls in virtualWalls) {
      drawVirtualWall(canvas, painter, walls.pose.point1.x, walls.pose.point1.y, walls.pose.point2.x, walls.pose.point2.y);
    }
    for (var walls in (drawnVirtualWalls ?? [])) {
      drawUpdatedVirtualWalls(canvas, painter, walls.pose);
    }
    if (erasedVirtualWallData != null) {
      drawErasedVirtualWall(canvas, painter, erasedVirtualWallData!.pose);
    }
  }

  void drawStartAndEndOfVirtualWall(ui.Canvas canvas, ui.Paint painter, VirtualWallPose virtualWallPose) {
    final wallPoint1X = virtualWallPose.point1.x;
    final wallPoint1Y = virtualWallPose.point1.y;
    final wallPoint2X = virtualWallPose.point2.x;
    final wallPoint2Y = virtualWallPose.point2.y;
    painter.color = Colors.blue;
    canvas.drawCircle(ui.Offset(wallPoint1X, wallPoint1Y), 2 / (scale ?? 1), painter);
    canvas.drawLine(ui.Offset(wallPoint1X, wallPoint1Y), ui.Offset(wallPoint2X, wallPoint2Y), painter);
    canvas.drawCircle(ui.Offset(wallPoint2X, wallPoint2Y), 2 / (scale ?? 1), painter);
  }

  void drawVirtualWall(ui.Canvas canvas, ui.Paint painter, double dx1, double dy1, double dx2, double dy2) {
    final x1Point = dx1.convertXFromDasherPoint(mapVariables);
    final y1Point = dy1.convertYFromDasherPoint(mapVariables);
    final x2Point = dx2.convertXFromDasherPoint(mapVariables);
    final y2Point = dy2.convertYFromDasherPoint(mapVariables);
    painter.color = Colors.red;
    painter.strokeWidth = 2 / scale;
    canvas.drawLine(ui.Offset(x1Point, y1Point), ui.Offset(x2Point, y2Point), painter);
  }

  void drawErasedVirtualWall(ui.Canvas canvas, ui.Paint painter, EraseVirtualWallPose virtualWallPose) {
    final wallPoint1X = virtualWallPose.point1.x;
    final wallPoint1Y = virtualWallPose.point1.y;
    final wallPoint2X = virtualWallPose.point2.x;
    final wallPoint2Y = virtualWallPose.point2.y;
    final wallPoint3X = virtualWallPose.point3.x;
    final wallPoint3Y = virtualWallPose.point3.y;
    final wallPoint4X = virtualWallPose.point4.x;
    final wallPoint4Y = virtualWallPose.point4.y;
    ui.Offset point1 = ui.Offset(wallPoint1X, wallPoint1Y);
    ui.Offset point2 = ui.Offset(wallPoint2X, wallPoint2Y);
    ui.Offset point3 = ui.Offset(wallPoint3X, wallPoint3Y);
    ui.Offset point4 = ui.Offset(wallPoint4X, wallPoint4Y);
    painter.color = Colors.blue;
    canvas.drawCircle(point1, 2, painter);
    canvas.drawCircle(point2, 2, painter);
    canvas.drawCircle(point3, 2, painter);
    canvas.drawCircle(point4, 2, painter);
    painter.strokeWidth = 0.5;
    canvas.drawLine(point1, point2, painter);
    canvas.drawLine(point2, point3, painter);
    canvas.drawLine(point3, point4, painter);
    canvas.drawLine(point4, point1, painter);
    final path = Path()
      ..moveTo(point1.dx, point1.dy)
      ..lineTo(point2.dx, point2.dy)
      ..lineTo(point3.dx, point3.dy)
      ..lineTo(point4.dx, point4.dy)
      ..close();

    // Create a Paint object to represent the border
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void drawUpdatedVirtualWalls(ui.Canvas canvas, ui.Paint painter, VirtualWallPose virtualWallPose) {
    final wallPoint1X = virtualWallPose.point1.x.convertXFromDasherPoint(mapVariables);
    final wallPoint1Y = virtualWallPose.point1.y.convertYFromDasherPoint(mapVariables);
    final wallPoint2X = virtualWallPose.point2.x.convertXFromDasherPoint(mapVariables);
    final wallPoint2Y = virtualWallPose.point2.y.convertYFromDasherPoint(mapVariables);
    painter.strokeWidth = 1;
    painter.color = Colors.green;
    canvas.drawLine(ui.Offset(wallPoint1X, wallPoint1Y), ui.Offset(wallPoint2X, wallPoint2Y), painter);
    painter.color = Colors.blue;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class CurrentMousePositionPainter extends CustomPainter {
//   final double scale;
//   final List<double>? currentMouseCursorPosition;
//   final MapVariables mapVariables;
//
//   CurrentMousePositionPainter({
//     this.currentMouseCursorPosition,
//     required this.scale,
//     required this.mapVariables,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) async {
//     ui.Paint painter = ui.Paint();
//     if (currentMouseCursorPosition != null) {
//       painter.color = Colors.blue;
//       canvas.drawCircle(Offset(currentMouseCursorPosition!.first, currentMouseCursorPosition!.last), 6 / (scale), painter);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

class ContinousDataCanvas extends CustomPainter {
  final double scale;
  final List<List<double>> laserData;
  final List<List<double>>? threeDData;

  // Previous frame data for smooth animation (optional).
  final List<List<double>>? previousLaserData;
  final List<List<double>>? previousThreeDData;

  // 0..1 interpolation value.
  final double animationT;

  final List<List<double>>? globalPath;
  final MapVariables mapVariables;

  ContinousDataCanvas({
    required this.laserData,
    required this.mapVariables,
    this.threeDData,
    this.globalPath,
    required this.scale,
    this.previousLaserData,
    this.previousThreeDData,
    this.animationT = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    ui.Paint painter = ui.Paint();

    final t = animationT.clamp(0.0, 1.0);

    // Laser data (interpolated)
    _drawInterpolatedCloud(
      canvas,
      painter,
      current: laserData,
      previous: previousLaserData,
      onDraw: (x, y) => drawLaserData(canvas, painter, x, y),
      t: t,
    );

    // 3D data (interpolated)
    if (threeDData != null) {
      _drawInterpolatedCloud(
        canvas,
        painter,
        current: threeDData!,
        previous: previousThreeDData,
        onDraw: (x, y) => drawThreeDData(canvas, painter, x, y),
        t: t,
      );
    }

    // Global path stays as-is (no animation for now)
    if (globalPath != null) {
      for (var global in globalPath!) {
        drawGlobalPath(canvas, painter, global.first, global.last);
      }
    }
  }

  void _drawInterpolatedCloud(
    ui.Canvas canvas,
    ui.Paint painter, {
    required List<List<double>> current,
    required List<List<double>>? previous,
    required void Function(double x, double y) onDraw,
    required double t,
  }) {
    // If no previous frame, just draw current.
    if (previous == null || previous.isEmpty) {
      for (final p in current) {
        if (p.length < 2) continue;
        onDraw(p.first, p.last);
      }
      return;
    }

    // Interpolate point-by-point by index.
    // If lengths differ, draw up to the min length interpolated,
    // then draw the remaining current points normally.
    final minLen = current.length < previous.length ? current.length : previous.length;

    for (int i = 0; i < minLen; i++) {
      final c = current[i];
      final p = previous[i];
      if (c.length < 2 || p.length < 2) continue;

      final cx = (c.first as num).toDouble();
      final cy = (c.last as num).toDouble();
      final px = (p.first as num).toDouble();
      final py = (p.last as num).toDouble();

      final x = ui.lerpDouble(px, cx, (cx == px && cy == py) ? 1 : t) ?? cx;
      final y = ui.lerpDouble(py, cy, (cx == px && cy == py) ? 1 : t) ?? cy;
      onDraw(x, y);
    }

    if (current.length > minLen) {
      for (int i = minLen; i < current.length; i++) {
        final c = current[i];
        if (c.length < 2) continue;
        onDraw(c.first, c.last);
      }
    }
  }

  void drawLaserData(ui.Canvas canvas, ui.Paint painter, double dx, double dy) {
    final xPoint = dx.convertXFromDasherPoint(mapVariables);
    final yPoint = dy.convertYFromDasherPoint(mapVariables);
    painter.color = Colors.orange;
    canvas.drawCircle(ui.Offset(xPoint, yPoint), 2 / (scale), painter);
  }

  void drawThreeDData(ui.Canvas canvas, ui.Paint painter, double dx, double dy) {
    final xPoint = dx.convertXFromDasherPoint(mapVariables);
    final yPoint = dy.convertYFromDasherPoint(mapVariables);
    painter.color = Colors.purple;
    canvas.drawCircle(ui.Offset(xPoint, yPoint), 3 / (scale), painter);
  }

  void drawGlobalPath(ui.Canvas canvas, ui.Paint painter, double dx, double dy) {
    final xPoint = dx.convertXFromDasherPoint(mapVariables);
    final yPoint = dy.convertYFromDasherPoint(mapVariables);
    painter.color = Colors.black;
    canvas.drawCircle(ui.Offset(xPoint, yPoint), 2 / (scale), painter);
  }

  @override
  bool shouldRepaint(covariant ContinousDataCanvas oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.mapVariables != mapVariables ||
        oldDelegate.laserData != laserData ||
        oldDelegate.threeDData != threeDData ||
        oldDelegate.previousLaserData != previousLaserData ||
        oldDelegate.previousThreeDData != previousThreeDData ||
        oldDelegate.animationT != animationT ||
        oldDelegate.globalPath != globalPath;
  }
}

