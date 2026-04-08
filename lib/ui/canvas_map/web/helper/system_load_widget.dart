import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_tool_tip.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/text_style.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SystemLoadWidget extends ConsumerWidget {
  const SystemLoadWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);

    final cpu = (canvasMapWatch.systemData?.cpuPercent ?? 0).clamp(0, 100).toDouble();
    final mem = (canvasMapWatch.systemData?.memoryPercent ?? 0).clamp(0, 100).toDouble();
    int battery = (canvasMapWatch.batteryData[canvasMapWatch.selectedRobotUuid]?['battery'] ?? 0);
    bool isCharging = (canvasMapWatch.batteryData[canvasMapWatch.selectedRobotUuid]?['charging'] ?? false);

    final IconData batteryIcon = battery <= 20
        ? CupertinoIcons.battery_0
        : battery <= 50
        ? CupertinoIcons.battery_25
        : CupertinoIcons.battery_100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.005, vertical: context.height * 0.005),
      width: context.width * 0.12,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.80),
            AppColors.white.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.07),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: context.height * 0.036,
                width: context.height * 0.036,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.06),
                  border: Border.all(
                    color: AppColors.black.withValues(alpha: 0.07),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.memory_rounded,
                  size: context.height * 0.018,
                  color: AppColors.black.withValues(alpha: 0.78),
                ),
              ),
              SizedBox(width: context.width * 0.010),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    title: 'System Load',
                    style: TextStyles.semiBold.copyWith(
                      fontSize: 12,
                      color: AppColors.black.withValues(alpha: 0.82),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  CommonText(
                    title: 'CPU & Memory',
                    style: TextStyles.regular.copyWith(
                      fontSize: 10,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.height * 0.010),
          MetricCard(
            title: 'CPU',
            percent: cpu,
            ringColor: AppColors.clrE25001,
            icon: Icons.speed_rounded,
            tooltip: 'CPU Usage • ${cpu.toStringAsFixed(0)}%',
          ),
          SizedBox(height: context.height * 0.005),
          MetricCard(
            title: 'Memory',
            percent: mem,
            ringColor: AppColors.clr0066FF,
            icon: Icons.storage_rounded,
            tooltip: 'Memory Usage • ${mem.toStringAsFixed(0)}%',
          ),

          SizedBox(height: context.height * 0.005),
          MetricCard(
            title: 'Battery',
            percent: (battery / 100) * 100,
            ringColor: AppColors.clr0066FF,
            icon: batteryIcon,
            tooltip: 'Battery Remaining • ${((battery / 100) * 100).toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final double percent;
  final Color ringColor;
  final IconData icon;
  final String? tooltip;
  final double? width;

  const MetricCard({
    super.key,
    required this.title,
    required this.percent,
    required this.ringColor,
    required this.icon,
    this.width,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return CustomToolTip(
      message: tooltip ?? '$title • ${percent.toStringAsFixed(0)}%',
      child: Container(
        width: width ?? context.width * 0.11,
        padding: EdgeInsets.symmetric(horizontal: context.width * 0.005, vertical: context.height * 0.005),
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
            color: AppColors.black.withValues(alpha: 0.07),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: context.height * 0.050,
                  height: context.height * 0.050,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    color: ringColor,
                    value: percent / 100,
                    backgroundColor: AppColors.black.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  height: context.height * 0.036,
                  width: context.height * 0.036,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.07),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: context.height * 0.015,
                    color: AppColors.black.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
            SizedBox(width: context.width * 0.010),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  title: title,
                  style: TextStyles.semiBold.copyWith(
                    fontSize: 12,
                    color: AppColors.black.withValues(alpha: 0.82),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.07),
                      width: 0.8,
                    ),
                  ),
                  child: CommonText(
                    title: '${percent.toStringAsFixed(0)}%',
                    style: TextStyles.bold.copyWith(
                      fontSize: 12,
                      color: AppColors.black.withValues(alpha: 0.82),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
