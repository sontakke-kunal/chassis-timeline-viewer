import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_painter_canvas.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapPainterController = ChangeNotifierProvider((ref) => MapPainterController());

class MapPainterController extends ChangeNotifier {

  MapPainterCanvas? mapPainterCanvas;

  ///Refresh Canvas Painter
  void refreshMapPainter(MapVariables mapVariables, {bool isNotify = true}) {

    final  canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);

    if (canvasMapWatch?.image != null) {
      mapPainterCanvas = MapPainterCanvas(image: canvasMapWatch!.image!, scale: canvasMapWatch.scale[mapVariables.mapsUuid]!, mapVariables: mapVariables);
      if (isNotify) notifyListeners();
    }
  }

  /// way Points
  WaypointsPainterCanvas? waypointsPainterCanvas;
  void refreshWaypointsPainter(MapVariables mapVariables, {bool isNotify = true}) {
    final  canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);
    if (canvasMapWatch?.pointTypeList.isNotEmpty??false) {
      waypointsPainterCanvas = WaypointsPainterCanvas(
        chargingPointImage: canvasMapWatch?.chargingPointImage,
        productionPointImage: canvasMapWatch?.productionPointImage,
        deliveryPointImage: canvasMapWatch?.deliveryPointImage,
        wayPoints: canvasMapWatch!.waypointsList[mapVariables.mapsUuid]!,
        scale: canvasMapWatch.scale[mapVariables.mapsUuid]!,
        selectedPointType: canvasMapWatch.selectedPointTypeList[mapVariables.mapsUuid]!,
        mapVariables: mapVariables,
      );
      if (isNotify) notifyListeners();
    }
  }

  /// Routes
  RoutesPainterCanvas? routesPainterCanvas;

  void refreshRoutesPainter(MapVariables mapVariables, {bool isNotify = true}) {
    final  canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);
    routesPainterCanvas = RoutesPainterCanvas(
      pointTypeList: canvasMapWatch!.selectedPointTypeList[mapVariables.mapsUuid]!,
      routeImage: canvasMapWatch.routeImage,
      naviRoutes: canvasMapWatch.naviRoutes[mapVariables.mapsUuid]!,
      scale: canvasMapWatch.scale[mapVariables.mapsUuid]!,
      currentMouseCursorPosition: canvasMapWatch.currentMouseCursorPosition,
      currentlyDrawingRoute: canvasMapWatch.newRoutePoints,
      mapVariables: mapVariables,
    );
    if (isNotify) notifyListeners();
  }


  /// Virtual Wall
  VirtualWallPainterCanvas? virtualWallPainterCanvas;

  void refreshVirtualWallPainter(MapVariables mapVariables, {bool isNotify = true}) {
    final  canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);
    virtualWallPainterCanvas= VirtualWallPainterCanvas(
      virtualWalls: canvasMapWatch!.virtualWall,
      scale: canvasMapWatch.scale[mapVariables.mapsUuid]!,
      drawnVirtualWalls: canvasMapWatch.updatedVirtualWallPoints,
      currentlyDrawingVirtualWall: canvasMapWatch.virtualWallPoint,
      erasedVirtualWallData: canvasMapWatch.eraseVirtualWallPoint,
      mapVariables: mapVariables,
    );
    if (isNotify) notifyListeners();
  }

  /// ContinousDataCanvas Painter
  ContinousDataCanvas? continuousDataCanvas;

  void refreshContinuousData(MapVariables mapVariables, {bool isNotify = true}) {
    final  canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);
    continuousDataCanvas = ContinousDataCanvas(
      laserData: canvasMapWatch!.laserData,
      threeDData: canvasMapWatch.show3DData ? canvasMapWatch.threeDData : [],
      globalPath: canvasMapWatch.globalPath,
      scale: canvasMapWatch.scale[mapVariables.mapsUuid]!,
      mapVariables: mapVariables,
    );
    if (isNotify) notifyListeners();
  }

  PositionPainterCanvas? positionPainterCanvas;


}