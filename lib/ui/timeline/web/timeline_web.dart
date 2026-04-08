import 'dart:math';
import 'dart:ui';
import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/android_data_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/custom_tool_tip.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/map_information_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/continous_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/map_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/position_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/routes_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/point_type_selector_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/recenter_helper_pill.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/ros_data_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/system_load_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/virtual_wall_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/canvas_map/web/helper/painter/waypoint_painter_widget.dart';
import 'package:chassis_timeline_viewer/ui/timeline/timeline_keybaord_handler.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_anim_loader.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TimelineWeb extends ConsumerStatefulWidget {

  const TimelineWeb({super.key});

  @override
  ConsumerState createState() => _TimelineWebState();
}

class _TimelineWebState extends ConsumerState<TimelineWeb> with TickerProviderStateMixin {
  CanvasMapController? _canvasCtrl;
  VoidCallback? _ctrlListener;

  // Slider hover/drag tooltip
  bool _sliderHovering = false;
  bool _sliderDragging = false;
  int _hoverIndex = 0;
  double _hoverDx = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      final canvasMapWatch = ref.read(canvasMapController);
      canvasMapWatch.speedList = [1, 2, 4, 8, 16, 32, 64, 128];
      canvasMapWatch.speedIndex = 0;
      canvasMapWatch.selectedRobotOnMap = canvasMapWatch.deviceList[canvasMapWatch.mapsUuid]?.where((device) => device.deviceDetails?.firstOrNull?.uuid == canvasMapWatch.robotId).firstOrNull;
      canvasMapWatch.readTimelineFile();
      canvasMapWatch.show3DData = false;
      canvasMapWatch.threeDData = [];
      canvasMapWatch.laserData = [];
      canvasMapWatch.globalPath = null;
      canvasMapWatch.sessionData = null;
      canvasMapWatch.versionData = null;
      canvasMapWatch.sensorData = null;
      canvasMapWatch.systemData = null;
      canvasMapWatch.speedData = null;
      canvasMapWatch.showCameraView = false;
      canvasMapWatch.selectedCamera = null;
      canvasMapWatch.adsDataRes = null;
      canvasMapWatch.isAndroidMemoryDetailsVisible = false;
      canvasMapWatch.isDeviceListVisible = false;
      canvasMapWatch.isDeviceSettingsVisible = false;
      canvasMapWatch.batteryData = {};
      canvasMapWatch.listenToRobotPosition(canvasMapWatch.mapsUuid);
      canvasMapWatch.notifyListeners();
      _canvasCtrl = canvasMapWatch;
    });
    super.initState();
  }

  @override
  void dispose() {
    final c = _canvasCtrl;
    if (c != null && _ctrlListener != null) {
      c.removeListener(_ctrlListener!);
    }
    final canvasMapWatch = AppConstants.constant.globalRef?.read(canvasMapController);
    if (canvasMapWatch?.selectedRobotOnMap != null) {
      canvasMapWatch?.isTimelinePlaying = false;
      canvasMapWatch?.timelineTimer?.cancel();
      canvasMapWatch?.deviceList[canvasMapWatch.mapsUuid] = canvasMapWatch.deviceList[canvasMapWatch.mapsUuid]!.map((device) => device..pose = null).toList();
      canvasMapWatch?.isTimelineScreen = false;
      canvasMapWatch?.show3DData = false;
      canvasMapWatch?.threeDData = [];
      canvasMapWatch?.laserData = [];
      canvasMapWatch?.laserDataResponseModel = null;
      canvasMapWatch?.threeDDataModel = null;
      canvasMapWatch?.globalPath = null;
      canvasMapWatch?.sessionData = null;
      canvasMapWatch?.versionData = null;
      canvasMapWatch?.sensorData = null;
      canvasMapWatch?.systemData = null;
      canvasMapWatch?.speedData = null;
      canvasMapWatch?.showCameraView = false;
      canvasMapWatch?.selectedCamera = null;
      // SocketController.instance.requestUserList(mapsUuid: widget.mapsUuid, destinationUuid: canvasMapWatch?.selectedRobotOnMap?.destinationUuid);
      canvasMapWatch?.refreshContinousData(canvasMapWatch.mapsUuid, isNotify: false);
      Future.delayed(Duration(milliseconds: 150), () => canvasMapWatch?.notifyListeners());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasMapWatch = ref.watch(canvasMapController);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.whiteF7F7FC,
      body: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: context.width * 0.01, vertical: context.height * 0.02),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: AppColors.whiteF7F7FC),
        child: KeyboardKeyListenerWrapper(
          onSpacePressed: (isHold) {
            canvasMapWatch.toggleTimelinePlayPause();
          },
          onRightPressed: (isHold) {
            canvasMapWatch.seekTimeline(1, isKey: true);
          },
          onLeftPressed: (isHold) {
            canvasMapWatch.seekTimeline(-1, isKey: true);
          },
          onDoubleSpacePressed: () {
            canvasMapWatch.toggleSpeed();
          },
          child: bodyWidget(),
        ),
      ),
    );
  }

  Widget bodyWidget() {
    final canvasMapWatch = ref.watch(canvasMapController);
    if (canvasMapWatch.mapVariablesData == null) return Offstage();
    return Stack(
      children: [
        Container(
          height: context.height,
          width: context.width,
          color: AppColors.newMapColor,
          child: InteractiveViewer(
            minScale: 0.2,
            maxScale: 50,
            transformationController: canvasMapWatch.transformationController[canvasMapWatch.mapsUuid]!,
            constrained: false,
            panAxis: PanAxis.free,
            trackpadScrollCausesScale: true,
            panEnabled: ![relocateStr, navigationStr].contains(canvasMapWatch.selectedMode ?? '') && !canvasMapWatch.eraseVirtualWall,
            onInteractionStart: (details) {
              // User started moving/zooming the map -> stop auto recenter.
              if (canvasMapWatch.isRecenter) {
                canvasMapWatch.updateIsRecenter(false);
              }
            },
            onInteractionUpdate: (scaleUpdate) {
              // Get the current transformation matrix
              final Matrix4 currentMatrix = canvasMapWatch.transformationController[canvasMapWatch.mapsUuid]!.value;
              // Extract the scale factor from the transformation matrix
              final double scaleX = currentMatrix.getMaxScaleOnAxis();
              if (canvasMapWatch.scale[canvasMapWatch.mapsUuid] != scaleX) {
                canvasMapWatch.scale[canvasMapWatch.mapsUuid] = scaleX;
                canvasMapWatch.updateBackgroundAlphaForMap(canvasMapWatch.mapsUuid);
                canvasMapWatch.refreshEntireCanvas(canvasMapWatch.mapsUuid);
                canvasMapWatch.currentMapResponseModel.forEach((key, value) {
                  canvasMapWatch.deviceList[key]?.forEach((element) {
                    canvasMapWatch.refreshPositionPainter(key, robot: element, isNotify: true);
                  });
                });
              }
            },
            boundaryMargin: EdgeInsets.symmetric(horizontal: double.infinity, vertical: double.infinity),
            child: Consumer(
              builder: (context, ref, child) {
                return Stack(
                  children: [
                    MapPainterWidget(mapVariables: canvasMapWatch.mapVariablesData!),
                    WaypointPainterWidget(mapVariables: canvasMapWatch.mapVariablesData!),
                    RoutesPainterWidget(mapVariables: canvasMapWatch.mapVariablesData!),
                    VirtualWallPainterWidget(mapVariables: canvasMapWatch.mapVariablesData!),
                    ContinuousPainterWidget(mapVariables: canvasMapWatch.mapVariablesData!),
                    PositionPainterWidget(robotId: canvasMapWatch.robotId, mapVariables: canvasMapWatch.mapVariablesData!),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          top: context.height * 0.015,
          left: context.width * 0.01,
          right: context.width * 0.01,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RosDataWidget(),
                    SizedBox(height: context.height * 0.01),
                    AndroidDataWidget(),
                    if (canvasMapWatch.selectedRobotOnMap != null) ...[
                      SizedBox(height: context.height * 0.01),
                      Row(
                        children: [
                          RecenterHelperPill(mapsUuid: canvasMapWatch.mapsUuid),
                        ],
                      ),
                      SizedBox(height: context.height * 0.01),
                      MapInformationWidget(),
                    ],
                  ],
                ),
              ),
              SizedBox(width: context.width * 0.025),
            ],
          ),
        ),
        if (!canvasMapWatch.isDeviceListVisible && !canvasMapWatch.isDeviceSettingsVisible)
          Positioned(
            right: context.width * 0.01,
            top: context.height * 0.015,
            child: Column(
              children: [
                PointTypeSelectorWidget(mapsUuid:canvasMapWatch.mapsUuid),
                SizedBox(height: context.height * 0.01),
                if (canvasMapWatch.showCameraView || !canvasMapWatch.isDeviceListVisible && !canvasMapWatch.isDeviceSettingsVisible && canvasMapWatch.systemData != null) SystemLoadWidget(),
              ],
            ),
          ),

        if (canvasMapWatch.downloadValue[canvasMapWatch.mapsUuid] != null)
          Builder(
            builder: (context) {
              return CommonAnimLoader(value: canvasMapWatch.downloadValue[canvasMapWatch.mapsUuid]);
            },
          ),

        Positioned(
          left: context.width * 0.05,
          right: context.width * 0.05,
          bottom: 10,
          child: Builder(
            builder: (context) {
              print(canvasMapWatch.timeLineMap.length);
              final keys = canvasMapWatch.timeLineMap.keys.toList();
              final total = keys.length;
              if (total <= 1) return const SizedBox.shrink();

              final currentIndex = canvasMapWatch.timelineTimeIndex.clamp(0, total - 1);
              final firstTime = keys[0];
              final currentTime = keys[currentIndex];
              final endTime = keys[total - 1];
              final showTime = currentTime.subtract(
                Duration(hours: firstTime.hour, minutes: firstTime.minute, seconds: firstTime.second, milliseconds: firstTime.millisecond, microseconds: firstTime.microsecond),
              );
              final showEndTime = endTime.subtract(
                Duration(hours: firstTime.hour, minutes: firstTime.minute, seconds: firstTime.second, milliseconds: firstTime.millisecond, microseconds: firstTime.microsecond),
              );

              // --- GAP/OFFLINE DETECTION ---
              bool isGapFrameAt(int idx) {
                if (idx < 0 || idx >= keys.length) return false;
                final d = canvasMapWatch.timeLineMap[keys[idx]];
                if (d == null) return false;
                return d.containsKey('p') && d['p'] == null && d.containsKey('ld') && d['ld'] == null && d.containsKey('3d') && d['3d'] == null && d.containsKey('gp') && d['gp'] == null;
              }

              final bool isGapFrame = isGapFrameAt(currentIndex);

              int gapStartIdx = currentIndex;
              int gapEndIdx = currentIndex;
              if (isGapFrame) {
                while (gapStartIdx > 0 && isGapFrameAt(gapStartIdx - 1)) {
                  gapStartIdx--;
                }
                while (gapEndIdx < keys.length - 1 && isGapFrameAt(gapEndIdx + 1)) {
                  gapEndIdx++;
                }
              }

              final int gapSeconds = isGapFrame ? max(1, keys[gapEndIdx].difference(keys[gapStartIdx]).inSeconds) : 0;

              final gapRanges = _buildGapRanges(total, isGapFrameAt);

              // Data presence indicators (based on current UI state)
              final bool hasPose = canvasMapWatch.selectedRobotOnMap?.pose != null;
              final bool hasLaser = canvasMapWatch.laserData.isNotEmpty;
              final bool has3d = canvasMapWatch.threeDData.isNotEmpty;
              final bool hasPath = (canvasMapWatch.globalPath?.isNotEmpty ?? false);
              final bool hasBattery = (canvasMapWatch.batteryData[canvasMapWatch.selectedRobotUuid]?.isNotEmpty ?? false);
              final bool hasNetwork = canvasMapWatch.networkEvent[canvasMapWatch.selectedRobotUuid] != null;

              Widget pill(String label, bool on, {IconData? icon}) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: on ? AppColors.black.withValues(alpha: 0.10) : AppColors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: on ? AppColors.black.withValues(alpha: 0.18) : AppColors.black.withValues(alpha: 0.10),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 14,
                          color: on ? AppColors.black.withValues(alpha: 0.85) : AppColors.black.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 6),
                      ],
                      CommonText(
                        title: label,
                        style: TextStyles.medium.copyWith(
                          fontSize: 11,
                          color: on ? AppColors.black.withValues(alpha: 0.85) : AppColors.black.withValues(alpha: 0.45),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }

              Widget iconBtn({
                required IconData icon,
                required VoidCallback onTap,
                String? tooltip,
                bool filled = false,
                double? size,
              }) {
                final s = size ?? (context.height * 0.040);
                final child = Container(
                  height: s,
                  width: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.clr009AF1 : AppColors.white.withValues(alpha: 0.55),
                    border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: context.height * 0.020,
                    color: filled ? AppColors.white : AppColors.black.withValues(alpha: 0.80),
                  ),
                );

                final tappable = InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onTap,
                  child: child,
                );

                return tooltip == null ? tappable : CustomToolTip(message: tooltip, child: tappable);
              }

              final absStamp = DateFormat('dd MMM yyyy • HH:mm:ss.S').format(currentTime);

              String frameStr() => '${(currentIndex + 1).clamp(1, total)} / $total';

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width * 0.012,
                  vertical: context.height * 0.012,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white.withValues(alpha: 0.82),
                      AppColors.white.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.9),
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
                  children: [
                    // --- TOP: Offline chip + pills row ---
                    Row(
                      children: [
                        if (isGapFrame)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.clrFFCC00.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.clrFFCC00.withValues(alpha: 0.35), width: 0.9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_rounded, size: 14, color: AppColors.black.withValues(alpha: 0.75)),
                                const SizedBox(width: 6),
                                CommonText(
                                  title: 'No data • ${gapSeconds}s',
                                  style: TextStyles.bold.copyWith(
                                    fontSize: 11,
                                    color: AppColors.black.withValues(alpha: 0.80),
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        if (isGapFrame) const SizedBox(width: 10),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    robotInfoPill(
                                      serialNumber: canvasMapWatch.selectedRobotOnMap?.serialNumber ?? '-',
                                      hostName: canvasMapWatch.selectedRobotOnMap?.hostName ?? '-',
                                      destinationName: canvasMapWatch.selectedRobotOnMap?.destinationName ?? '-',
                                    ),
                                    networkInfoPill(
                                      isOn: hasNetwork,
                                      androidWifi: canvasMapWatch.sessionData?.androidWifiName ?? '',
                                      hostWifi: canvasMapWatch.sessionData?.hostWifiName ?? '',
                                      hostIp: canvasMapWatch.sessionData?.hostIpAddress ?? '',
                                      upload: canvasMapWatch.networkEvent[canvasMapWatch.selectedRobotUuid]?.upload ?? '-',
                                      download: canvasMapWatch.networkEvent[canvasMapWatch.selectedRobotUuid]?.download ?? '-',
                                      number: canvasMapWatch.simEvent?.number ?? '-',
                                      carrierName: canvasMapWatch.simEvent?.carrierName ?? '-',
                                    ),
                                    Builder(
                                      builder: (context) {
                                        String? adName = canvasMapWatch.adsDataRes?['n'];
                                        String? mediaType = canvasMapWatch.adsDataRes?['m']?.toString().toLowerCase().capitalizeFirstLetterOfSentence;
                                        if (adName == null) return Offstage();
                                        return pill('${adName} (${mediaType})', true, icon: Icons.tv);
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        String? navModePoint = canvasMapWatch.navModeEvent?.point;
                                        if (navModePoint?.isEmpty ?? true) return Offstage();
                                        return pill('${navModePoint}', true, icon: Icons.navigation);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.height * 0.010),

                    // --- MID: Time + frame count + absolute time + end time ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
                          ),
                          child: CommonText(
                            title: DateFormat('HH:mm:ss').format(showTime),
                            style: TextStyles.bold.copyWith(
                              fontSize: 12,
                              color: AppColors.black.withValues(alpha: 0.82),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
                          ),
                          child: CommonText(
                            title: absStamp,
                            style: TextStyles.bold.copyWith(
                              fontSize: 12,
                              color: AppColors.black.withValues(alpha: 0.82),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.black.withValues(alpha: 0.06), width: 0.8),
                          ),
                          child: CommonText(
                            title: frameStr(),
                            style: TextStyles.medium.copyWith(
                              fontSize: 12,
                              color: AppColors.black.withValues(alpha: 0.70),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Spacer(),
                        CommonText(
                          title: DateFormat('HH:mm:ss').format(showEndTime),
                          style: TextStyles.medium.copyWith(
                            fontSize: 12,
                            color: AppColors.black.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),

                    // --- Slider (with gap/gap overlays + tooltip) ---
                    LayoutBuilder(
                      builder: (context, c) {
                        final trackWidth = c.maxWidth;
                        final sliderTheme = SliderTheme.of(context).copyWith(
                          trackHeight: 3.0,
                          activeTrackColor: AppColors.clr009AF1,
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: AppColors.clr009AF1,
                          overlayColor: AppColors.clr009AF1.withValues(alpha: 0.12),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        );
                        final thumbRadius = sliderTheme.thumbShape?.getPreferredSize(true, false).width != null ? sliderTheme.thumbShape!.getPreferredSize(true, false).width / 2 : 0.0;
                        final overlayRadius = sliderTheme.overlayShape?.getPreferredSize(true, false).width != null ? sliderTheme.overlayShape!.getPreferredSize(true, false).width / 2 : 0.0;
                        final horizontalInset = max(thumbRadius, overlayRadius);
                        final effectiveTrackWidth = max(1.0, trackWidth - (horizontalInset * 2));

                        // Tooltip decision: hover uses hoverIndex, dragging uses currentIndex
                        final bool showTip = _sliderHovering || _sliderDragging;
                        final int tipIndex = (_sliderHovering ? _hoverIndex : currentIndex).clamp(0, total - 1);
                        final DateTime tipTime = keys[tipIndex];

                        // Position tooltip near thumb/hover point
                        final double dx = _sliderHovering ? _hoverDx : horizontalInset + ((tipIndex / (total - 1)) * effectiveTrackWidth);
                        final double clampedDx = dx.clamp(16.0, trackWidth - 16.0);

                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
                          children: [
                            SizedBox(
                              height: 26,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: _GapTrackPainter(
                                  total: total,
                                  gaps: gapRanges,
                                  horizontalInset: horizontalInset,
                                ),
                              ),
                            ),

                            // Bookmarks markers on track
                            IgnorePointer(
                              child: SizedBox(
                                height: 26,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _BookmarkTrackPainter(
                                    total: total,
                                    bookmarks: canvasMapWatch.bookmarks,
                                    horizontalInset: horizontalInset,
                                  ),
                                ),
                              ),
                            ),

                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _sliderHovering = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _sliderHovering = false;
                                });
                              },
                              onHover: (e) {
                                final local = (context.findRenderObject() as RenderBox?)?.globalToLocal(e.position);
                                final rawDx = (local?.dx ?? 0).clamp(0.0, trackWidth);
                                final normalizedDx = ((rawDx - horizontalInset) / effectiveTrackWidth).clamp(0.0, 1.0);
                                final idx = (normalizedDx * (total - 1)).round().clamp(0, total - 1);
                                final alignedDx = horizontalInset + (normalizedDx * effectiveTrackWidth);
                                setState(() {
                                  _hoverDx = alignedDx;
                                  _hoverIndex = idx;
                                });
                              },
                              child: SliderTheme(
                                data: sliderTheme,
                                child: Slider(
                                  value: currentIndex.toDouble(),
                                  min: 0,
                                  max: (total - 1).toDouble(),
                                  divisions: max(1, total - 1),
                                  onChangeStart: (_) {
                                    setState(() {
                                      _sliderDragging = true;
                                    });
                                  },
                                  onChangeEnd: (_) {
                                    setState(() {
                                      _sliderDragging = false;
                                    });
                                  },
                                  onChanged: (v) => canvasMapWatch.seekTimeline(v.round()),
                                ),
                              ),
                            ),

                            if (showTip)
                              Positioned(
                                left: clampedDx - 110,
                                top: -62,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.92),
                                            Colors.white.withValues(alpha: 0.80),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          width: 0.9,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.18),
                                            blurRadius: 22,
                                            offset: const Offset(0, 12),
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
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.clr009AF1.withValues(alpha: 0.95),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.clr009AF1.withValues(alpha: 0.22),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: CommonText(
                                                  title: DateFormat('HH:mm:ss.S').format(tipTime),
                                                  style: TextStyles.bold.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.black.withValues(alpha: 0.86),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          CommonText(
                                            title: DateFormat('EEE, dd MMM yyyy').format(tipTime),
                                            style: TextStyles.medium.copyWith(
                                              fontSize: 11,
                                              color: Colors.black.withValues(alpha: 0.62),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    // --- Controls ---
                    Row(
                      children: [
                        iconBtn(
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          tooltip: 'Jump back',
                          onTap: () => canvasMapWatch.seekTimeline(currentIndex - 10),
                        ),
                        const SizedBox(width: 10),
                        iconBtn(
                          icon: Icons.chevron_left_rounded,
                          tooltip: 'Step back',
                          onTap: () => canvasMapWatch.seekTimeline(currentIndex - 1),
                        ),

                        const Spacer(),

                        iconBtn(
                          icon: canvasMapWatch.isTimelinePlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          tooltip: 'Play/Pause (Space)',
                          filled: true,
                          size: context.height * 0.048,
                          onTap: () => canvasMapWatch.toggleTimelinePlayPause(),
                        ),

                        const Spacer(),

                        iconBtn(
                          icon: Icons.chevron_right_rounded,
                          tooltip: 'Step forward',
                          onTap: () => canvasMapWatch.seekTimeline(currentIndex + 1),
                        ),
                        const SizedBox(width: 10),
                        iconBtn(
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          tooltip: 'Jump forward',
                          onTap: () => canvasMapWatch.seekTimeline(currentIndex + 10),
                        ),
                        const SizedBox(width: 14),

                        CustomToolTip(
                          message: 'Speed • Double Space to toggle',
                          child: InkWell(
                            key: _speedKey,
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _openSpeedMenu(context, canvasMapWatch),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.speed_rounded, size: 16, color: AppColors.black.withValues(alpha: 0.70)),
                                  const SizedBox(width: 8),
                                  CommonText(
                                    title: '${canvasMapWatch.speedList[canvasMapWatch.speedIndex]}x',
                                    style: TextStyles.bold.copyWith(
                                      fontSize: 12,
                                      color: AppColors.black.withValues(alpha: 0.82),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(CupertinoIcons.chevron_up_chevron_down, size: 12, color: AppColors.black.withValues(alpha: 0.45)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Bookmark
                        CustomToolTip(
                          message: 'Bookmark this moment',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              if (!canvasMapWatch.bookmarks.contains(currentIndex)) {
                                canvasMapWatch.bookmarks.add(currentIndex);
                                canvasMapWatch.bookmarks.sort();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.9),
                              ),
                              child: Icon(Icons.bookmark_add_rounded, size: 16, color: AppColors.black.withValues(alpha: 0.72)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomToolTip(
                          message: 'Open bookmarks',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              if (canvasMapWatch.bookmarks.isEmpty) return;
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                        child: Container(
                                          width: 420,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.88),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.9),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.18),
                                                blurRadius: 24,
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
                                                  Icon(Icons.bookmarks_rounded, size: 18, color: AppColors.black.withValues(alpha: 0.78)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: CommonText(
                                                      title: 'Bookmarks',
                                                      style: TextStyles.bold.copyWith(fontSize: 14, color: AppColors.black.withValues(alpha: 0.86)),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    borderRadius: BorderRadius.circular(999),
                                                    onTap: () => Navigator.pop(ctx),
                                                    child: Container(
                                                      height: 34,
                                                      width: 34,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 0.9),
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Icon(CupertinoIcons.xmark, size: 16, color: Colors.black.withValues(alpha: 0.70)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              ConstrainedBox(
                                                constraints: const BoxConstraints(maxHeight: 280),
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  itemCount: canvasMapWatch.bookmarks.length,
                                                  separatorBuilder: (_, __) => Divider(color: Colors.black.withValues(alpha: 0.08), height: 14),
                                                  itemBuilder: (_, i) {
                                                    final idx = canvasMapWatch.bookmarks[i];
                                                    final t = keys[idx];
                                                    final stamp = DateFormat('HH:mm:ss.S').format(t);
                                                    return InkWell(
                                                      borderRadius: BorderRadius.circular(12),
                                                      onTap: () {
                                                        Navigator.pop(ctx);
                                                        canvasMapWatch.seekTimeline(idx);
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.black.withValues(alpha: 0.06),
                                                                borderRadius: BorderRadius.circular(999),
                                                                border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 0.9),
                                                              ),
                                                              child: CommonText(
                                                                title: '${idx + 1}',
                                                                style: TextStyles.bold.copyWith(fontSize: 11, color: Colors.black.withValues(alpha: 0.78)),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Expanded(
                                                              child: CommonText(
                                                                title: stamp,
                                                                style: TextStyles.semiBold.copyWith(fontSize: 12, color: Colors.black.withValues(alpha: 0.80)),
                                                              ),
                                                            ),
                                                            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black.withValues(alpha: 0.45)),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(14),
                                                      onTap: () {
                                                        canvasMapWatch.bookmarks.clear();
                                                        canvasMapWatch.notifyListeners();
                                                        Navigator.pop(ctx);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.06),
                                                          borderRadius: BorderRadius.circular(14),
                                                          border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.9),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: CommonText(
                                                          title: 'Clear',
                                                          style: TextStyles.bold.copyWith(fontSize: 12, color: Colors.black.withValues(alpha: 0.76)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(14),
                                                      onTap: () => Navigator.pop(ctx),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.clr009AF1.withValues(alpha: 0.88),
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: CommonText(
                                                          title: 'Close',
                                                          style: TextStyles.bold.copyWith(fontSize: 12, color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.black.withValues(alpha: 0.07), width: 0.9),
                              ),
                              child: Icon(Icons.bookmarks_rounded, size: 16, color: AppColors.black.withValues(alpha: 0.72)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.height * 0.006),

                    // --- subtle keyboard hints ---
                    Row(
                      children: [
                        Icon(Icons.keyboard, size: 14, color: AppColors.black.withValues(alpha: 0.35)),
                        const SizedBox(width: 6),
                        CommonText(
                          title: 'Space: Play/Pause • ←/→: Step • Double Space: Speed • ★: Bookmarks',
                          style: TextStyles.regular.copyWith(
                            fontSize: 10,
                            color: AppColors.black.withValues(alpha: 0.40),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget robotInfoPill({
    required String serialNumber,
    required String hostName,
    required String destinationName,
  }) {
    final sn = serialNumber.isNotEmpty ? serialNumber : '-';
    final hn = hostName.isNotEmpty ? hostName : '-';
    final dn = destinationName.isNotEmpty ? destinationName : '-';

    return CustomToolTip(
      preferBelow: false,
      verticalOffset: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      richMessage: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
        children: [
          const TextSpan(
            text: 'Robot Information\n',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Serial       ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: sn,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Host         ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: hn,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Destination  ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: dn,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: AppColors.black.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 6),
            CommonText(
              title: sn != '-' ? sn : 'Robot',
              style: TextStyles.medium.copyWith(
                fontSize: 11,
                color: AppColors.black.withValues(alpha: 0.85),
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Network info pill, showing WiFi name and upload/download in tooltip.
  Widget networkInfoPill({
    required bool isOn,
    required String androidWifi,
    required String hostWifi,
    required String hostIp,
    required String upload,
    required String download,
    required String number,
    required String carrierName,
  }) {
    final aw = androidWifi.trim().isNotEmpty ? androidWifi.trim() : '-';
    final hw = hostWifi.trim().isNotEmpty ? hostWifi.trim() : '-';
    final ip = hostIp.trim().isNotEmpty ? hostIp.trim() : '-';

    String _fmt(dynamic v) {
      if (v == null) return '-';
      if (v is num) {
        // Treat as already human readable (KB/s, MB/s etc.) if your backend sends it that way.
        // Otherwise it will still show clean numeric.
        if (v.abs() >= 1000) return v.toStringAsFixed(0);
        return v.toStringAsFixed(2);
      }
      return v.toString();
    }

    final up = _fmt(upload);
    final down = _fmt(download);

    return CustomToolTip(
      preferBelow: false,
      verticalOffset: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      richMessage: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
        children: [
          const TextSpan(
            text: 'Network\n',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Android WiFi   ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: aw,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Host WiFi      ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: hw,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Host IP        ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: ip,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Number        ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: number,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Carrier        ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: carrierName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n\n'),
          const TextSpan(
            text: 'Upload         ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: up,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(
            text: 'Download       ',
            style: TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(
            text: down,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isOn ? AppColors.black.withValues(alpha: 0.10) : AppColors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOn ? AppColors.black.withValues(alpha: 0.18) : AppColors.black.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_rounded,
              size: 14,
              color: isOn ? AppColors.black.withValues(alpha: 0.85) : AppColors.black.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            CommonText(
              title: ip,
              style: TextStyles.regular.copyWith(
                fontSize: 10,
                color: isOn ? AppColors.black.withValues(alpha: 0.60) : AppColors.black.withValues(alpha: 0.38),
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Gap painter and helpers ---
class _GapTrackPainter extends CustomPainter {
  final int total;
  final List<_GapRange> gaps;
  final double horizontalInset;

  _GapTrackPainter({
    required this.total,
    required this.gaps,
    required this.horizontalInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 1) return;

    final double trackHeight = 3.0;
    final double y = (size.height / 2) - (trackHeight / 2);
    final double usableWidth = max(0.0, size.width - (horizontalInset * 2));

    // Base track aligned with Slider's actual track rect
    final baseR = RRect.fromRectAndRadius(
      Rect.fromLTWH(horizontalInset, y, usableWidth, trackHeight),
      const Radius.circular(999),
    );
    final basePaint = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawRRect(baseR, basePaint);

    if (gaps.isEmpty || usableWidth <= 0 || total <= 1) return;

    // Gap overlay
    final gapPaint = Paint()..color = const Color(0xFFFF0000).withValues(alpha: 0.60);

    for (final g in gaps) {
      final double sx = horizontalInset + ((g.start / (total - 1)) * usableWidth);
      final double ex = horizontalInset + ((g.end / (total - 1)) * usableWidth);
      final double w = max(2.0, ex - sx);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(sx, y, w, trackHeight),
        const Radius.circular(999),
      );
      canvas.drawRRect(r, gapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GapTrackPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.horizontalInset != horizontalInset || oldDelegate.gaps.length != gaps.length;
  }
}

class _BookmarkTrackPainter extends CustomPainter {
  final int total;
  final List<int> bookmarks;
  final double horizontalInset;

  _BookmarkTrackPainter({
    required this.total,
    required this.bookmarks,
    required this.horizontalInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 1) return;
    if (bookmarks.isEmpty) return;

    // Markers sit centered on the track
    const double trackHeight = 3.0;
    final double y = (size.height / 2);

    final glowPaint = Paint()
      ..color = const Color(0xFF009AF1).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final dotPaint = Paint()..color = const Color(0xFF009AF1).withValues(alpha: 0.95);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF009AF1).withValues(alpha: 0.35);

    // De-duplicate & clamp
    final set = <int>{};
    for (final b in bookmarks) {
      final idx = b.clamp(0, total - 1);
      set.add(idx);
    }

    for (final idx in set) {
      final double usableWidth = max(0.0, size.width - (horizontalInset * 2));
      final double x = horizontalInset + ((idx / (total - 1)) * usableWidth);

      // Glow
      canvas.drawCircle(Offset(x, y), 6.0, glowPaint);

      // Ring + dot
      canvas.drawCircle(Offset(x, y), 3.6, ringPaint);
      canvas.drawCircle(Offset(x, y), 2.3, dotPaint);

      // Small vertical tick to visually sit on track
      final tick = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 2.2, height: trackHeight + 8),
        const Radius.circular(999),
      );
      final tickPaint = Paint()..color = const Color(0xFF009AF1).withValues(alpha: 0.22);
      canvas.drawRRect(tick, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BookmarkTrackPainter oldDelegate) {
    if (oldDelegate.total != total) return true;
    if (oldDelegate.horizontalInset != horizontalInset) return true;
    if (oldDelegate.bookmarks.length != bookmarks.length) return true;
    for (int i = 0; i < min(oldDelegate.bookmarks.length, bookmarks.length); i++) {
      if (oldDelegate.bookmarks[i] != bookmarks[i]) return true;
    }
    return false;
  }
}

class _GapRange {
  final int start;
  final int end;

  const _GapRange(this.start, this.end);
}

List<_GapRange> _buildGapRanges(int total, bool Function(int) isGapAt) {
  final ranges = <_GapRange>[];
  int i = 0;
  while (i < total) {
    if (!isGapAt(i)) {
      i++;
      continue;
    }
    final s = i;
    while (i + 1 < total && isGapAt(i + 1)) {
      i++;
    }
    ranges.add(_GapRange(s, i));
    i++;
  }
  return ranges;
}

// --- Speed dropdown key & menu ---
final GlobalKey _speedKey = GlobalKey();

Future<void> _openSpeedMenu(BuildContext context, CanvasMapController canvasMapWatch) async {
  final ctx = _speedKey.currentContext;
  if (ctx == null) return;
  final box = ctx.findRenderObject() as RenderBox;
  final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
  final pos = box.localToGlobal(Offset.zero, ancestor: overlay);

  final selected = await showMenu<int>(
    context: context,
    color: Colors.white.withValues(alpha: 0.92),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.black.withValues(alpha: 0.10), width: 0.9),
    ),
    position: RelativeRect.fromLTRB(
      pos.dx,
      pos.dy - 8,
      overlay.size.width - (pos.dx + box.size.width),
      overlay.size.height - pos.dy,
    ),
    items: List.generate(canvasMapWatch.speedList.length, (i) {
      final v = canvasMapWatch.speedList[i];
      final isSel = i == canvasMapWatch.speedIndex;
      return PopupMenuItem<int>(
        value: i,
        height: 40,
        child: Row(
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSel ? const Color(0xFF009AF1).withValues(alpha: 0.14) : Colors.black.withValues(alpha: 0.06),
                border: Border.all(
                  color: isSel ? const Color(0xFF009AF1).withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.10),
                  width: 0.9,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                isSel ? Icons.check_rounded : Icons.speed_rounded,
                size: 16,
                color: isSel ? const Color(0xFF009AF1) : Colors.black.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${v}x',
                style: TextStyle(
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black.withValues(alpha: isSel ? 0.85 : 0.75),
                  fontSize: 13,
                ),
              ),
            ),
            if (isSel)
              Text(
                'Current',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF009AF1).withValues(alpha: 0.95),
                  fontSize: 11,
                ),
              ),
          ],
        ),
      );
    }),
  );

  if (selected == null) return;
  canvasMapWatch.speedIndex = selected;
  canvasMapWatch.notifyListeners();
}
