import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_tool_tip.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RecenterHelperPill extends ConsumerWidget {
  final String mapsUuid;
  final bool isFullScreenMapSelected;

  const RecenterHelperPill({super.key, required this.mapsUuid, this.isFullScreenMapSelected = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);
    return Builder(
      builder: (context) {
        // Recenter / Zoom controls (polished)
        Widget _glassPill({required Widget child}) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: context.width * 0.002, vertical: context.height * 0.008),
            width: isFullScreenMapSelected
                ? canvasMapWatch.isRecenter
                      ? context.width * 0.065
                      : context.width * 0.04
                : !canvasMapWatch.isRecenter
                ? context.width * 0.25
                : null,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white.withValues(alpha: 0.78),
                  AppColors.white.withValues(alpha: 0.42),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
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
            child: child,
          );
        }

        Widget _roundIconBtn({required Widget icon, required VoidCallback onTap, String? tooltip}) {
          final btn = InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              height: context.height * 0.036,
              width: context.height * 0.036,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.black.withValues(alpha: 0.06),
                border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
          );
          return tooltip == null ? btn : CustomToolTip(message: tooltip, child: btn);
        }

        if (!canvasMapWatch.isRecenter) {
          return CustomToolTip(
            message: 'Recenter map (auto follow robot)',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                canvasMapWatch.updateIsRecenter(true, mapsUuid: mapsUuid);
                canvasMapWatch.updateScale(context, mapsUuid, 0.6);
              },
              child: _glassPill(
                child: Container(
                  height: context.height * 0.036,
                  width: context.height * 0.036,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.withValues(alpha: 0.06),
                    border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: isFullScreenMapSelected ? 1 : 2.5,
                    child: CommonSVG(
                      strIcon: Assets.svgs.svgLocationIcon.path,
                      height: context.height * 0.018,
                      colorFilter: ColorFilter.mode(AppColors.black.withValues(alpha: 0.78), BlendMode.srcATop),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Transform.scale(
            scale: !isFullScreenMapSelected ? 2.5 : 1,
            child: _glassPill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundIconBtn(
                    tooltip: 'Zoom in',
                    onTap: () {
                      final currentScale = canvasMapWatch.transformationController!.value.getMaxScaleOnAxis();
                      double scale = double.parse(currentScale.toStringAsFixed(2));
                      const step = 0.1;
                      final next = (scale + step).clamp(0.2, 2.0);
                      canvasMapWatch.updateScale(context, mapsUuid, next);
                    },
                    icon: Icon(CupertinoIcons.zoom_in, size: context.height * 0.019, color: AppColors.black.withValues(alpha: 0.78)),
                  ),
                  SizedBox(width: context.width * 0.006),
                  _roundIconBtn(
                    tooltip: 'Zoom out',
                    onTap: () {
                      final currentScale = canvasMapWatch.transformationController!.value.getMaxScaleOnAxis();
                      double scale = double.parse(currentScale.toStringAsFixed(2));
                      const step = 0.1;
                      final next = (scale - step).clamp(0.2, 2.0);
                      canvasMapWatch.updateScale(context, mapsUuid, next);
                    },
                    icon: Icon(CupertinoIcons.zoom_out, size: context.height * 0.019, color: AppColors.black.withValues(alpha: 0.78)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
