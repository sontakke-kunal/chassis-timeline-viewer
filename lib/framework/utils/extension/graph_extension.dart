import 'dart:math';
import 'dart:ui';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';

extension GraphExtension on double {
  double convertXToDasherPoint(MapVariables map) {
    return (this - map.centerX) * map.resolution;
  }

  double convertYToDasherPoint(MapVariables map) {
    return (map.centerY - this) * map.resolution;
  }

  double convertXFromDasherPoint(MapVariables map) {
    return (this / map.resolution) + map.centerX;
  }

  double convertYFromDasherPoint(MapVariables map) {
    return map.centerY - (this / map.resolution);
  }

  bool isBetween(double v1, double v2) {
    return (this >= v1 || this <= v2);
  }
}

extension ListExtension on List<dynamic> {
  List<List<double>> get coordinates {
    List<List<double>> allPointsList = [];
    for (var allPoints in this) {
      List<double> pointsList = [];
      for (var points in (allPoints as List<dynamic>)) {
        pointsList.add(double.parse(points.toString()));
      }
      allPointsList.add(pointsList);
    }
    return allPointsList;
  }
}

extension OffsetExtension on Offset {
  ///Calculate distance
  double calculateDistance(Offset end) {
    // Assuming the canvas scale factor is 1 when not zooming
    const double pixelsPerMeter = 1.0;

    // Calculate the distance using the Pythagorean theorem
    final double dx = (end.dx - this.dx) / pixelsPerMeter;
    final double dy = (end.dy - this.dy) / pixelsPerMeter;
    final double distance = sqrt((dx * dx) + (dy * dy));

    return distance;
  }

  double calculateTheta(Offset endPoint) {
    var theta = atan2((endPoint.dx - dx), (endPoint.dy - dy));
    theta = theta * (180 / pi);
    bool isThetaNegative = false;
    if (theta < 0) {
      isThetaNegative = true;
      theta = theta + 360;
    }
    theta -= 90;
    if (isThetaNegative) {
      theta -= 360;
    }

    var calculatedTheta = theta;

    if (calculatedTheta < -180) {
      calculatedTheta += 360;
    }
    calculatedTheta *= (pi / 180);
    return calculatedTheta;
  }
}
