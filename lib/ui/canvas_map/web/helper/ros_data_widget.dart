import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/text_style.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RosDataWidget extends ConsumerWidget {
  const RosDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);
    final isLaserOk = canvasMapWatch.sensorData?.isLidarOk ?? false;
    final isImuOk = canvasMapWatch.sensorData?.isImuOk ?? false;
    final isEStopPressed = canvasMapWatch.sessionData?.isEmergencyPressed ?? false;

    final pose = canvasMapWatch.selectedRobotOnMap?.pose;
    final positionText = pose == null
        ? '--, --, --'
        : '${pose.x?.toStringAsFixed(2) ?? '--'}, '
              '${pose.y?.toStringAsFixed(2) ?? '--'}, '
              '${pose.theta?.toStringAsFixed(2) ?? '--'}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: ROS header pill (always visible)
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.width * 0.005, vertical: context.height * 0.012),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.22),
                AppColors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.14),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: context.height * 0.038,
                width: context.height * 0.038,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.18),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.settings_solid,
                  size: context.height * 0.019,
                  color: AppColors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(width: context.width * 0.005),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    title: 'ROS Data',
                    style: TextStyles.semiBold.copyWith(
                      color: AppColors.black.withValues(alpha: 0.95),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  CommonText(
                    title: 'Live metrics',
                    style: TextStyles.regular.copyWith(
                      color: AppColors.black.withValues(alpha: 0.70),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(width: context.width * 0.005),
            ],
          ),
        ),
        SizedBox(width: context.width * 0.01),

        // Right: chips in a responsive wrap
        Expanded(
          child: Wrap(
            spacing: context.width * 0.006,
            runSpacing: context.height * 0.006,
            children: [
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'RAM',
                value: canvasMapWatch.systemData?.totalMemory ?? '--',
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'Laser',
                value: isLaserOk ? 'OK' : 'Error',
                backgroundColor: isLaserOk ? AppColors.green13851E.withValues(alpha: 0.2) : AppColors.clrE25001.withValues(alpha: 0.2),
                valueColor: isLaserOk ? AppColors.green13851E : AppColors.clrE25001,
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'Imu',
                value: isImuOk ? 'OK' : 'Error',
                backgroundColor: isImuOk ? AppColors.green13851E.withValues(alpha: 0.2) : AppColors.clrE25001.withValues(alpha: 0.2),
                valueColor: isImuOk ? AppColors.green13851E : AppColors.clrE25001,
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'E-stop',
                value: isEStopPressed ? 'Pressed' : 'Released',
                backgroundColor: isEStopPressed ? AppColors.clrE25001.withValues(alpha: 0.2) : AppColors.green13851E.withValues(alpha: 0.2),
                valueColor: isEStopPressed ? AppColors.clrE25001 : AppColors.green13851E,
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'L-Speed',
                value: canvasMapWatch.speedData?.linearSpeed?.toStringAsFixed(2) ?? '--',
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'A-Speed',
                value: canvasMapWatch.speedData?.angularSpeed?.toStringAsFixed(2) ?? '--',
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'Position',
                value: positionText,
                maxLines: 2,
              ),
              _buildMetricChip(
                context,
                alpha: canvasMapWatch.backgroundAlpha,
                label: 'Version',
                value: canvasMapWatch.versionData?.navigationVersion ?? '--',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required String label,
    required String value,
    required double alpha,
    Color? backgroundColor,
    Color? valueColor,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.width * 0.008,
        vertical: context.height * 0.006,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null
              ? [
                  backgroundColor,
                  backgroundColor.withValues(alpha: (backgroundColor.opacity * 0.72).clamp(0.0, 1.0)),
                ]
              : [
                  AppColors.white.withValues(alpha: (alpha).clamp(0.0, 1.0)),
                  AppColors.white.withValues(alpha: (alpha * 0.72).clamp(0.0, 1.0)),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.07),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.28),
                ),
              ),
              const SizedBox(width: 6),
              CommonText(
                title: label,
                style: TextStyles.medium.copyWith(
                  fontSize: 10,
                  color: AppColors.black.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
          SizedBox(height: context.height * 0.002),
          CommonText(
            title: value,
            maxLines: maxLines,
            style: TextStyles.semiBold.copyWith(
              fontSize: 12,
              color: (valueColor ?? AppColors.black).withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
