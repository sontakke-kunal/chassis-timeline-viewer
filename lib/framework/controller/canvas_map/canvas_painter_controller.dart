

import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_painter_canvas.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/painter/continous_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapPainterController = ChangeNotifierProvider((ref) => MapPainterController());

class MapPainterController extends ChangeNotifier {

  MapPainterCanvas? mapPainterCanvas;

  WaypointsPainterCanvas? waypointsPainterCanvas;

  RoutesPainterCanvas? routesPainterCanvas;

  VirtualWallPainterCanvas? virtualWallPainterCanvas;

  ContinousDataCanvas? continuousDataCanvas;

  PositionPainterCanvas? positionPainterCanvas;


}