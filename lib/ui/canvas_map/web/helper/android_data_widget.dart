import 'dart:math';

import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_tool_tip.dart';
import 'package:chassis_timeline_viewer/ui/utils/anim/slide_right_transition.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/text_style.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AndroidDataWidget extends ConsumerWidget {
  const AndroidDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);

    return Row(
      children: [
        CustomToolTip(
          message: canvasMapWatch.isAndroidMemoryDetailsVisible ? 'Hide Android Memory' : 'Show Android Memory',
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (canvasMapWatch.isAndroidMemoryDetailsVisible) {
                canvasMapWatch.androidMemoryDetailsAnimationController?.reverse().then(
                      (value) => canvasMapWatch.updateIsAndroidMemoryDetailsVisible(false),
                    ) ??
                    canvasMapWatch.updateIsAndroidMemoryDetailsVisible(false);
              } else {
                canvasMapWatch.updateIsAndroidMemoryDetailsVisible(true);
              }
            },
            child: Container(
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
                  // rotating icon
                  AnimatedBuilder(
                    animation: canvasMapWatch.androidMemoryDetailsAnimationController ?? const AlwaysStoppedAnimation<double>(0),
                    builder: (context, child) {
                      final v = canvasMapWatch.androidMemoryDetailsAnimationController?.value ?? 0.0;
                      return Transform.rotate(
                        angle: pi * v * 2,
                        child: child,
                      );
                    },
                    child: Container(
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
                        CupertinoIcons.memories,
                        size: context.height * 0.019,
                        color: AppColors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  SizedBox(width: context.width * 0.005),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        title: 'Android Memory',
                        style: TextStyles.semiBold.copyWith(
                          color: AppColors.black.withValues(alpha: 0.95),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 1),
                      CommonText(
                        title: canvasMapWatch.isAndroidMemoryDetailsVisible ? 'Tap to collapse' : 'Tap to expand',
                        style: TextStyles.regular.copyWith(
                          color: AppColors.black.withValues(alpha: 0.70),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: context.width * 0.005),
                  // rotating chevron
                  AnimatedBuilder(
                    animation: canvasMapWatch.androidMemoryDetailsAnimationController ?? const AlwaysStoppedAnimation<double>(0),
                    builder: (context, child) {
                      final v = canvasMapWatch.androidMemoryDetailsAnimationController?.value ?? 0.0;
                      return Transform.rotate(
                        angle: pi * v,
                        child: child,
                      );
                    },
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.white.withValues(alpha: 0.90),
                      size: context.height * 0.018,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (canvasMapWatch.isAndroidMemoryDetailsVisible) ...[
          SizedBox(width: context.width * 0.006),
          Expanded(
            child: SlideRightTransition(
              offset: const Offset(-0.2, 0.0),
              onAnimationCreated: (androidMemoryDetailsAnimationController) {
                canvasMapWatch.androidMemoryDetailsAnimationController = androidMemoryDetailsAnimationController;
              },
              onAnimationDisposed: () {
                canvasMapWatch.androidMemoryDetailsAnimationController = null;
              },
              child: Wrap(
                spacing: context.width * 0.008,
                runSpacing: context.height * 0.006,
                children: [
                  _buildMemoryChip(
                    context,
                    label: 'App RAM',
                    value: canvasMapWatch.deviceState?.appRamMB ?? '--',
                    alpha: canvasMapWatch.backgroundAlpha,
                  ),
                  _buildMemoryChip(
                    context,
                    label: 'Remaining RAM',
                    value: canvasMapWatch.deviceState?.availRamMB ?? '--',
                    alpha: canvasMapWatch.backgroundAlpha,
                  ),
                  _buildMemoryChip(
                    context,
                    label: 'Used RAM',
                    value: '${canvasMapWatch.deviceState?.usedRamMB ?? '--'} / ${canvasMapWatch.deviceState?.totalRamMB ?? '--'}',
                    alpha: canvasMapWatch.backgroundAlpha,
                  ),
                  _buildMemoryChip(
                    context,
                    label: 'Used Storage',
                    value: '${canvasMapWatch.deviceState?.usedStorageMB ?? '--'} / ${canvasMapWatch.deviceState?.totalStorageMB ?? '--'}',
                    alpha: canvasMapWatch.backgroundAlpha,
                  ),
                  _buildMemoryChip(
                    context,
                    label: 'Apk Version',
                    value: '${canvasMapWatch.sessionData?.apkVersion ?? '-'}',
                    alpha: canvasMapWatch.backgroundAlpha,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemoryChip(
    BuildContext context, {
    required String label,
    required String value,
    required double alpha,
    Color? valueColor,
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
          colors: [
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
            style: TextStyles.semiBold.copyWith(
              fontSize: 12,
              color: valueColor ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
