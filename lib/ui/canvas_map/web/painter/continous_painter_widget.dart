import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_painter_controller.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_painter_canvas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ContinuousPainterWidget extends ConsumerStatefulWidget {
  final MapVariables mapVariables;

  const ContinuousPainterWidget({super.key, required this.mapVariables});

  @override
  ConsumerState<ContinuousPainterWidget> createState() => _ContinuousPainterWidgetState();
}

class _ContinuousPainterWidgetState extends ConsumerState<ContinuousPainterWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  // Keep previous/current frames per map to interpolate smoothly.
  final Map<String, List<List<double>>> _lastLaserByMap = {};
  final Map<String, List<List<double>>?> _last3dByMap = {};

  final Map<String, List<List<double>>?> _prevLaserByMap = {};
  final Map<String, List<List<double>>?> _prev3dByMap = {};

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

    final mapId = widget.mapVariables.mapsUuid;

    // This is the “current” painter produced by your controller.
    final currentPainter = canvasPaintWatch.continuousDataCanvas;
    if (currentPainter == null) {
      return const SizedBox.shrink();
    }

    final currentLaser = currentPainter.laserData;
    final current3d = currentPainter.threeDData;

    final lastLaser = _lastLaserByMap[mapId];
    final last3d = _last3dByMap[mapId];

    // Detect a new frame.
    final bool laserChanged = !identical(lastLaser, currentLaser);
    final bool threeDChanged = !identical(last3d, current3d);

    if (laserChanged || threeDChanged) {
      // Move last -> prev, then store new last, then restart animation.
      if (lastLaser != null) {
        _prevLaserByMap[mapId] = lastLaser;
      }
      if (last3d != null) {
        _prev3dByMap[mapId] = last3d;
      }

      _lastLaserByMap[mapId] = currentLaser;
      _last3dByMap[mapId] = current3d;

      _anim
        ..stop()
        ..value = 0.0
        ..forward();
    }

    final prevLaser = _prevLaserByMap[mapId];
    final prev3d = _prev3dByMap[mapId];

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          painter: ContinousDataCanvas(
            scale: currentPainter.scale,
            mapVariables: currentPainter.mapVariables,
            laserData: currentLaser,
            threeDData: current3d,
            globalPath: currentPainter.globalPath,
            previousLaserData: prevLaser,
            previousThreeDData: prev3d,
            animationT: 1 ?? _anim.value,
          ),
          size: ui.Size(widget.mapVariables.width, widget.mapVariables.height),
        );
      },
    );
  }
}
