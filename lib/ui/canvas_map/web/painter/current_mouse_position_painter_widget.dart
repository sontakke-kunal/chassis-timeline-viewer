import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odigo_control_room/framework/controller/canvas_map/canvas_painter_controller.dart';
import 'package:odigo_control_room/ui/utils/theme/theme.dart';
import 'package:odigo_control_room/framework/repository/map/model/map_variables.dart';
import 'dart:ui' as ui;

class CurrentMousePositionPainterWidget extends ConsumerWidget {
  final MapVariables mapVariables;
  const CurrentMousePositionPainterWidget({super.key, required this.mapVariables});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasPaintWatch = ref.watch(currentMousePositionPainterController);
    return CustomPaint(
      painter: canvasPaintWatch.currentMousePositionPainter[mapVariables.mapsUuid],
      size: ui.Size(mapVariables.width, mapVariables.height),
    );
  }
}
