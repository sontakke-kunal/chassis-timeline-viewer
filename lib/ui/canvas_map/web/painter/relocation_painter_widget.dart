import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odigo_control_room/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:odigo_control_room/framework/controller/canvas_map/canvas_painter_controller.dart';
import 'package:odigo_control_room/framework/utils/extension/context_extension.dart';
import 'package:odigo_control_room/ui/utils/theme/theme.dart';
import 'package:odigo_control_room/framework/repository/map/model/map_variables.dart';
import 'dart:ui' as ui;

import 'package:odigo_control_room/ui/utils/widgets/common_confirmation_dialog.dart';

class RelocationPainterWidget extends ConsumerWidget {
  final MapVariables mapVariables;
  const RelocationPainterWidget({super.key, required this.mapVariables});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasPaintWatch = ref.watch(relocationPainterController);
    return CustomPaint(
      painter: canvasPaintWatch.relocationPainterCanvas[mapVariables.mapsUuid],
      size: ui.Size(mapVariables.width, mapVariables.height),
    );
  }
}
