import 'dart:math';
import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_tool_tip.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';



class MapInformationWidget extends ConsumerWidget {

  const MapInformationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);
    // MapListData? map = canvasMapWatch.mapList.where((e) => e.uuid == mapsUuid).firstOrNull;
    // DestinationData? destinationData = ref.read(destinationDetailsController).destinationDetailsState.success?.data;
    String? adName = canvasMapWatch.adsDataRes?['n'];
    String? mediaType = canvasMapWatch.adsDataRes?['m']?.toString().toLowerCase().capitalizeFirstLetterOfSentence;
    String? navMode = canvasMapWatch.navModeEvent?.mode;
    String? navModePoint = canvasMapWatch.navModeEvent?.point;
    return CustomToolTip(
      message:
          // 'Destination: ${destinationData?.name}\nMap: ${map?.name}\nFloor: ${map?.destinationFloor?.name} (${map?.destinationFloor?.floorNumber})${canvasMapWatch.selectedRobotOnMap != null ? '\nRobot: ${canvasMapWatch.selectedRobotOnMap?.hostName}' : ''}${adName != null ? '\n${'Currently Playing: ${adName} (${mediaType})'}' : ''}${(navModePoint?.isNotEmpty ?? false) ? '\n${'${navMode == 'S' ? 'Store' : 'Idle'} Mode ($navModePoint)'}' : ''}',
          'Destination: frfmrk \nMap: fnrfr \nFloor: 2 (ef)${canvasMapWatch.selectedRobotOnMap != null ? '\nRobot: ${canvasMapWatch.selectedRobotOnMap?.hostName}' : ''}${adName != null ? '\n${'Currently Playing: ${adName} (${mediaType})'}' : ''}${(navModePoint?.isNotEmpty ?? false) ? '\n${'${navMode == 'S' ? 'Store' : 'Idle'} Mode ($navModePoint)'}' : ''}',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.width * 0.005, vertical: context.height * 0.010),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white.withValues(alpha: 0.78),
              AppColors.white.withValues(alpha: 0.42),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.06),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          height: context.height * 0.036,
          width: context.height * 0.036,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.black.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: canvasMapWatch.mapInformationAnimationController ?? const AlwaysStoppedAnimation<double>(0),
            builder: (context, child) {
              final v = canvasMapWatch.mapInformationAnimationController?.value ?? 0.0;
              return Transform.rotate(
                angle: pi * v * 2,
                child: child,
              );
            },
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.black.withValues(alpha: 0.80),
              size: context.height * 0.018,
            ),
          ),
        ),
      ),
    );
  }
}
