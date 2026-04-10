import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_enums.dart';

import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_check_box.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';

class PointTypeSelectorWidget extends ConsumerWidget {
  final String mapsUuid;

  const PointTypeSelectorWidget({super.key, required this.mapsUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasMapWatch = ref.watch(canvasMapController);

    return Container(
      width: context.width * 0.19,
      padding: EdgeInsets.symmetric(
        horizontal: context.width * 0.006,
        vertical: context.height * 0.010,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: canvasMapWatch.backgroundAlpha.clamp(0.6, 0.85)),
            AppColors.white.withValues(alpha: canvasMapWatch.backgroundAlpha.clamp(0.35, 0.55)),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.06),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.width * 0.006,
              vertical: context.height * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.06),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
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
                  child: Icon(
                    Icons.category_rounded,
                    size: context.height * 0.018,
                    color: AppColors.black.withValues(alpha: 0.78),
                  ),
                ),
                SizedBox(width: context.width * 0.006),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        title: 'Point Types',
                        style: TextStyles.semiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.black.withValues(alpha: 0.82),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 1),
                      CommonText(
                        title: '${canvasMapWatch.selectedPointTypeList.length ?? 0} selected • ${canvasMapWatch.pointTypeList.length} total',
                        style: TextStyles.regular.copyWith(
                          fontSize: 10,
                          color: AppColors.black.withValues(alpha: 0.55),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // Quick actions
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    for (final t in canvasMapWatch.pointTypeList) {
                      if (!(canvasMapWatch.selectedPointTypeList.contains(t) ?? false)) {
                        canvasMapWatch.addSelectedPointType(mapsUuid, t);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.8),
                    ),
                    child: CommonText(
                      title: 'All',
                      style: TextStyles.medium.copyWith(
                        fontSize: 11,
                        color: AppColors.black.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    final selected = List<PointType>.from(canvasMapWatch.selectedPointTypeList ?? []);
                    for (final t in selected) {
                      canvasMapWatch.removeSelectedPointType(mapsUuid, t);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.8),
                    ),
                    child: CommonText(
                      title: 'None',
                      style: TextStyles.medium.copyWith(
                        fontSize: 11,
                        color: AppColors.black.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.height * 0.008),

          // Body
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.height * (0.34),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (canvasMapWatch.selectedRobotOnMap != null) ...[
                    // 3D toggle
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        canvasMapWatch.show3DData = !canvasMapWatch.show3DData;
                        canvasMapWatch.threeDData = [];
                        canvasMapWatch.refreshContinousData(mapsUuid, isNotify: true);
                        // SocketController.instance.sendDataInBroadcastData(
                        //   canvasMapWatch.selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!,
                        //   SocketConstant.show3dData,
                        //   data: canvasMapWatch.show3DData,
                        // );
                        canvasMapWatch.notifyListeners();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.width * 0.004,
                          vertical: context.height * 0.004,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.black.withValues(alpha: 0.05),
                              AppColors.black.withValues(alpha: 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.06),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: context.height * 0.028,
                              width: context.height * 0.028,
                              alignment: Alignment.center,
                              child: CommonCheckBox(
                                checkValue: canvasMapWatch.show3DData,
                                onChanged: (value) {
                                  canvasMapWatch.show3DData = value ?? false;
                                  canvasMapWatch.threeDData = [];
                                  canvasMapWatch.refreshContinousData(mapsUuid, isNotify: true);
                                  // SocketController.instance.sendDataInBroadcastData(
                                  //   canvasMapWatch.selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!,
                                  //   SocketConstant.show3dData,
                                  //   data: canvasMapWatch.show3DData,
                                  // );
                                  canvasMapWatch.notifyListeners();
                                },
                              ),
                            ),
                            SizedBox(width: context.width * 0.0025),
                            Expanded(
                              child: Row(
                                children: [
                                  CommonText(
                                    title: '3D Data',
                                    style: TextStyles.medium.copyWith(
                                      color: AppColors.black.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (!(canvasMapWatch.sensorData?.is3dCameraOk ?? true))
                                    Builder(
                                      builder: (context) {
                                        return Container(
                                          margin: EdgeInsets.only(left: context.width * 0.005),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.red.withValues(alpha: 0.35), width: 0.8),
                                          ),
                                          child: CommonText(
                                            title: 'ERR',
                                            style: TextStyles.bold.copyWith(
                                              fontSize: 9,
                                              color: Colors.red.withValues(alpha: 0.85),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.height * 0.007),
                  ],

                  // Point type rows
                  ...List.generate(canvasMapWatch.pointTypeList.length, (index) {
                    final PointType type = canvasMapWatch.pointTypeList[index];
                    final bool isSelected = canvasMapWatch.selectedPointTypeList.contains(type);

                    return Padding(
                      padding: EdgeInsets.only(bottom: context.height * 0.007),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (!isSelected) {
                            canvasMapWatch.addSelectedPointType(mapsUuid, type);
                          } else {
                            canvasMapWatch.removeSelectedPointType(mapsUuid, type);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.width * 0.004,
                            vertical: context.height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.clr009AF1.withValues(alpha: 0.22),
                                      AppColors.clr009AF1.withValues(alpha: 0.08),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.black.withValues(alpha: 0.03),
                                      AppColors.black.withValues(alpha: 0.01),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.clr009AF1.withValues(alpha: 0.32) : AppColors.black.withValues(alpha: 0.06),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Selected indicator bar
                              Container(
                                height: context.height * 0.020,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.clr009AF1.withValues(alpha: 0.90) : AppColors.black.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              SizedBox(width: context.width * 0.006),
                              Container(
                                height: context.height * 0.028,
                                width: context.height * 0.028,
                                alignment: Alignment.center,
                                child: CommonCheckBox(
                                  checkValue: isSelected,
                                  onChanged: (value) {
                                    if (value ?? false) {
                                      canvasMapWatch.addSelectedPointType(mapsUuid, type);
                                    } else {
                                      canvasMapWatch.removeSelectedPointType(mapsUuid, type);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: context.width * 0.004),
                              Expanded(
                                child: CommonText(
                                  title: type.name.toLowerCase().capitalizeFirstLetterOfSentence,
                                  style: TextStyles.medium.copyWith(
                                    color: AppColors.black.withValues(alpha: isSelected ? 0.92 : 0.76),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // subtle count badge placeholder (future)
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
                                  ),
                                  child: CommonText(
                                    title: 'ON',
                                    style: TextStyles.bold.copyWith(
                                      fontSize: 10,
                                      color: AppColors.black.withValues(alpha: 0.70),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
