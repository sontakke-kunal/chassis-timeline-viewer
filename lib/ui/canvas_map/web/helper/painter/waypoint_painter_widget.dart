import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_painter_controller.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

class WaypointPainterWidget extends ConsumerWidget {
  final MapVariables mapVariables;
  const WaypointPainterWidget({super.key, required this.mapVariables});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasPaintWatch = ref.watch(mapPainterController);
    return CustomPaint(
      painter: canvasPaintWatch.waypointsPainterCanvas,
      size: ui.Size(mapVariables.width, mapVariables.height),
    );
  }
}
