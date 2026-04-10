import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_painter_controller.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_painter_canvas.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

class PositionPainterWidget extends ConsumerStatefulWidget {
  final String robotId;
  final MapVariables mapVariables;

  const PositionPainterWidget({super.key, required this.mapVariables, required this.robotId});

  @override
  ConsumerState<PositionPainterWidget> createState() => _PositionPainterWidgetState();
}

class _PositionPainterWidgetState extends ConsumerState<PositionPainterWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final Map<String, dynamic> _prevPoseByKey = {};

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..value = 1.0;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasPaintWatch = ref.watch(mapPainterController);
    final painter = canvasPaintWatch.positionPainterCanvas;

    if (painter == null) {
      print("is Empty");
      return const SizedBox.shrink();
    }

    final key = '${widget.mapVariables.mapsUuid}_${widget.robotId}';
    final currentPose = painter.robot.pose;

    // If pose changed, capture previous and restart animation
    final prevPose = _prevPoseByKey[key];
    if (currentPose != null && prevPose != currentPose) {
      _prevPoseByKey[key] = currentPose;
      _anim
        ..stop()
        ..value = 0.0
        ..forward();
    }

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          painter: PositionPainterCanvas(
            scale: painter.scale,
            robot: painter.robot,
            mapVariables: painter.mapVariables,
            previousPose: prevPose,
            animationT: _anim.value,
          ),
          size: ui.Size(widget.mapVariables.width, widget.mapVariables.height),
        );
      },
    );
  }
}
