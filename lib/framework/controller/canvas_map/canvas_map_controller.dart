import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:chassis_timeline_viewer/framework/dependency_injection/inject.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/device_list_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/device_state_event.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/laser_data_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_list_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_variables.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/robot_more_info_models.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/virtual_wall_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/way_point_list_response_model.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/graph_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_enums.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:injectable/injectable.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chassis_timeline_viewer/framework/repository/map/model/map_list_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/virtual_wall_response_model.dart';
import 'package:chassis_timeline_viewer/framework/repository/map/model/way_point_list_response_model.dart';
import 'package:chassis_timeline_viewer/ui/routing/delegate.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_toast_widget.dart';
import 'package:clipboard/clipboard.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';

final canvasMapController = ChangeNotifierProvider((ref) => getIt<CanvasMapController>());

@injectable
class CanvasMapController extends ChangeNotifier {

  MapVariables? mapVariablesData;
  String robotId = "";
  String mapsUuid = "";

  Map<String, int> currentMapMode = {};
  Map<String, double> scale = {};
  Map<String, MapListData> currentMapResponseModel = {};
  Map<String, double?> downloadValue = {};

  Map<String, TransformationController> transformationController = {};

  bool isRecenter = true;

  // Smooth recenter animation (controller-only, no vsync needed)
  Timer? _recenterTimer;
  Matrix4? _recenterFrom;
  Matrix4? _recenterTo;
  double _recenterT = 0.0;

  /// Stores current viewport (InteractiveViewer) size per map so we can recenter
  /// without needing a BuildContext inside socket callbacks.
  final Map<String, Size> viewportSize = {};

  /// Call this from the map widget (e.g., in LayoutBuilder) whenever the map viewport
  /// size changes.
  void updateViewportSize(String mapsUuid, Size size) {
    viewportSize[mapsUuid] = size;
  }

  /// Recenters the camera so that [uiX],[uiY] (in canvas/map UI coordinates) stays
  /// at the center of the viewport. Only applies when [isRecenter] is true.
  void _recenterOnUiPoint(String mapsUuid, double uiX, double uiY, {double? forceScale}) {
    if (!isRecenter) return;
    final controller = transformationController[mapsUuid];
    final size = viewportSize[mapsUuid];
    if (controller == null || size == null) return;

    // Keep current scale (prefer the controller matrix if available), or use forced scale if provided
    final currentScale = controller.value.getMaxScaleOnAxis();
    final s = forceScale ?? ((currentScale.isFinite && currentScale > 0) ? currentScale : (scale[mapsUuid] ?? 1.0));

    // Translate first, then scale (so translation isn't multiplied by scale)
    final cx = size.width / 2.0;
    final cy = size.height / 2.0;
    final tx = cx - (uiX * s);
    final ty = cy - (uiY * s);

    final target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(s);

    // Cancel any running animation
    _recenterTimer?.cancel();

    _recenterFrom = controller.value.clone();
    _recenterTo = target;
    _recenterT = 0.0;

    const int durationMs = 150;
    const int frameMs = 16; // ~60fps
    final double step = frameMs / durationMs;

    _recenterTimer = Timer.periodic(const Duration(milliseconds: frameMs), (timer) {
      if (!isRecenter) {
        timer.cancel();
        return;
      }

      _recenterT += step;
      if (_recenterT >= 1.0) {
        controller.value = _recenterTo!;
        timer.cancel();
        return;
      }

      // Smooth ease-out
      final t = 1 - pow(1 - _recenterT, 3).toDouble();

      controller.value = Matrix4Tween(begin: _recenterFrom!, end: _recenterTo!).lerp(t)!;
    });
  }

  /// Recenters camera on a robot pose (pose values are expected to be in Dasher/map
  /// coordinates).
  void recenterOnPose(String mapsUuid, Pose pose) {
    final vars = mapVariablesData;
    if (vars == null) return;

    final uiX = (pose.x ?? 0).convertXFromDasherPoint(vars);
    final uiY = (pose.y ?? 0).convertYFromDasherPoint(vars);

    _recenterOnUiPoint(mapsUuid, uiX, uiY);
  }

  updateIsRecenter(bool isRecenter, {String? mapsUuid}) {
    this.isRecenter = isRecenter;
    if (isRecenter && mapsUuid != null) {
      scale[mapsUuid] = 0.6;
    }
    notifyListeners();
  }

  void resetInitialPosition(String mapsUuid, BuildContext context) {
    // Apply scale first, then translate in logical (unscaled) pixels
    scale[mapsUuid] = 0.6;
    // Save viewport size for future auto-recenter operations.
    updateViewportSize(mapsUuid, Size(context.width, context.height));

    final s = scale[mapsUuid] ?? 0.6;
    transformationController[mapsUuid]!.value = Matrix4.identity()
      ..translate((context.width / 15), 0)
      ..scale(s);
    notifyListeners();
  }

  updateScale(BuildContext context, String mapsUuid, double s) {
    // Update scale will only be done when recenter is ON and we have a pose.
    if (!(isRecenter && selectedRobotOnMap?.pose != null)) return;

    updateViewportSize(mapsUuid, Size(context.width, context.height));
    scale[mapsUuid] = s;

    final vars = mapVariablesData;
    if (vars == null) return;

    final pose = selectedRobotOnMap!.pose!;
    final uiX = (pose.x ?? 0).convertXFromDasherPoint(vars);
    final uiY = (pose.y ?? 0).convertYFromDasherPoint(vars);

    // Smoothly animate to the new zoom level while keeping the robot centered.
    _recenterOnUiPoint(mapsUuid, uiX, uiY, forceScale: s);
    refreshEntireCanvas(mapsUuid);
    notifyListeners();
  }

  double backgroundAlpha = 0.5;

  void updateBackgroundAlphaForMap(String mapsUuid) {
    // Compute how much the map covers the screen (cover = 1.0 means fully covers, 0.0 means not visible)
    final controller = transformationController[mapsUuid];
    final size = viewportSize[mapsUuid];
    if (controller == null || size == null) return;
    final s = controller.value.getMaxScaleOnAxis();
    final vars = mapVariablesData;
    if (vars == null) return;
    // Calculate the map's size in UI pixels
    final mapWidth = vars.width * s;
    final mapHeight = vars.height * s;
    final viewportArea = size.width * size.height;
    final mapArea = mapWidth * mapHeight;
    // "cover" is the fraction of the viewport covered by the map (not clamped)
    final cover = (mapArea / viewportArea);
    // Fade window: start increasing alpha when map begins to cover most of the viewport,
    // and reach maxAlpha when it fully covers (cover >= 1.0).
    const start = 0.80;
    const end = 1.00;
    final t = ((cover - start) / (end - start)).clamp(0.0, 1.0);

    // backgroundAlpha range: 0.5 (map NOT covering) -> 0.9 (map covering)
    const double minAlpha = 0.5;
    const double maxAlpha = 0.9;

    final target = (minAlpha + (maxAlpha - minAlpha) * t).clamp(minAlpha, maxAlpha);

    // Only update if alpha changed enough
    if ((backgroundAlpha - target).abs() >= 0.01) {
      backgroundAlpha = target;
      notifyListeners();
    }
  }

  /// navigation expansion
  bool isNavigationControlExpanded = false;

  void updateNavigationControlExpanded(bool value) {
    isNavigationControlExpanded = value;
    notifyListeners();
  }

  /// Mode selection expansion
  bool isModeSelectorExpanded = false;

  void updateModeSelectorExpanded(bool value) {
    isModeSelectorExpanded = value;
    notifyListeners();
  }

  /// Canvas map expansion
  bool isSystemLoadExpanded = false;

  void updateSystemLoadExpanded(bool value) {
    isSystemLoadExpanded = value;
    notifyListeners();
  }

  /// point types expansion
  bool isPointTypeSelectorExpanded = false;

  void updatePointTypeSelectorExpanded(bool value) {
    isPointTypeSelectorExpanded = value;
    notifyListeners();
  }

  ///Get Current Map
  // Future<void> setMapData(MapListData mapData) async {
  //   deviceList[mapData.uuid!] = [];
  //   downloadValue[mapData.uuid!] = 0;
  //   currentMapMode[mapData.uuid!] = 0;
  //   scale[mapData.uuid!] = 0.6;
  //   selectedPointTypeList[mapData.uuid!] = [];
  //   notifyListeners();
  //   var mapImageUrl = await Dio().get(
  //     mapData.mapsImageUrl ?? '',
  //     onReceiveProgress: (count, total) {
  //       downloadValue[mapData.uuid ?? ''] = count / total;
  //       notifyListeners();
  //     },
  //   );
  //   notifyListeners();
  //   currentMapResponseModel[mapData.uuid!] = mapData;
  //   var currentMap = mapImageUrl.toString();
  //   var originX = currentMapResponseModel[mapData.uuid]?.originX ?? 0.0;
  //   var originY = currentMapResponseModel[mapData.uuid]?.originY ?? 0.0;
  //   var resolution = currentMapResponseModel[mapData.uuid]?.resolution ?? 0.0;
  //   var width = currentMapResponseModel[mapData.uuid]?.width ?? 0.0;
  //   var height = currentMapResponseModel[mapData.uuid]?.height ?? 0.0;
  //   var centerX = (originX / resolution) * -1;
  //   var centerY = (height) - ((originY / resolution) * -1);
  //   globalPath = [];
  //   laserData = [];
  //   threeDData = [];
  //   transformationController[mapData.uuid!] = TransformationController();
  //   mapVariablesData[mapData.uuid!] = MapVariables();
  //   mapVariablesData[mapData.uuid!]?.initializeMapConstants(mapData.uuid!, currentMap, originX, originY, resolution, width, height, centerX, centerY);
  //   if (currentMapMode == 1) {
  //     clearAllData(mapData.uuid!);
  //   }
  //   image[mapData.uuid!] = await mapVariablesData[mapData.uuid!]?.loadImage();
  //   refreshMapPainter(mapData.uuid!);
  // }

  void clearAllData(String mapsUuid) {
    waypointsList[mapsUuid]!.clear();
    naviRoutes[mapsUuid]!.clear();
    laserData.clear();
    threeDData.clear();
    virtualWall[mapsUuid]!.clear();
    refreshEntireCanvas(mapsUuid);
  }

  GlobalKey loadingDialogKey = GlobalKey();

  ///Get way points
  // Future<void> getWaypoints(String mapsUuid) async {
  //   virtualWall[mapsUuid] = [];
  //   naviRoutes[mapsUuid] = {};
  //   waypointsList[mapsUuid] = [];
  //   //Get Waypoints, Way Paths, Virtual Walls Data
  //   final resultPoints = await storeMappingRepository.getMapWayPoints(mapsUuid: mapsUuid);
  //   final resultPath = await storeMappingRepository.getMapWayPaths(mapsUuid: mapsUuid);
  //   final resultWalls = await storeMappingRepository.getMapVirtualWalls(mapsUuid: mapsUuid);
  //   resultPoints.when(
  //     success: (data) {
  //       waypointsList[mapsUuid]!.addAll(data.data?.waypoints ?? []);
  //     },
  //     failure: (error) {},
  //   );
  //   resultPath.when(
  //     success: (data) {
  //       naviRoutes[mapsUuid] = (jsonDecode(data.data?.value ?? '') as Map).toRouteMap;
  //     },
  //     failure: (error) {},
  //   );
  //   resultWalls.when(
  //     success: (data) {
  //       (jsonDecode(data.data?.value ?? '') as List).forEach((element) {
  //         virtualWall[mapsUuid]!.add(VirtualWallPoint.fromJson(element));
  //       });
  //     },
  //     failure: (error) {},
  //   );
  //   waypointsList[mapsUuid]!.sort((Waypoint pointName1, Waypoint pointName2) {
  //     return ((pointName1.name)?.toLowerCase() ?? '').compareTo((pointName2.name)?.toLowerCase() ?? '');
  //   });
  //   refreshWaypointsPainter(mapsUuid);
  //   refreshRoutesPainter(mapsUuid);
  //   refreshVirtualWallPainter(mapsUuid);
  //   if (loadingDialogKey.currentContext != null) {
  //     Navigator.pop(loadingDialogKey.currentContext!);
  //   }
  // }

  showLoadingDialog(BuildContext context, {required String title, required String description}) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            ref.watch(canvasMapController);
            return Dialog(
              key: loadingDialogKey,
              backgroundColor: AppColors.transparent,
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.clrE4E4E7, width: context.width * 0.0005),
                ),
                height: context.height * 0.3,
                width: context.width * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: context.height * 0.03),
                    CircularProgressIndicator(color: AppColors.black),
                    SizedBox(height: context.height * 0.03),
                    CommonText(
                      title: title,
                      style: TextStyles.bold.copyWith(color: AppColors.black, fontSize: 18),
                      maxLines: 10,
                      textAlign: TextAlign.center,
                    ).paddingOnly(bottom: context.height * 0.02, left: context.width * 0.02, right: context.width * 0.02),
                    CommonText(
                      title: description,
                      style: TextStyles.medium.copyWith(color: AppColors.black, fontSize: 12),
                      maxLines: 10,
                      textAlign: TextAlign.center,
                    ).paddingOnly(bottom: context.height * 0.05, left: context.width * 0.02, right: context.width * 0.02),
                    SizedBox(height: context.height * 0.02),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool startContinuousMonitoringMain = false;

  bool get startContinuousMonitoring => startContinuousMonitoringMain;

  // set startContinuousMonitoring(bool value) {
  //   startContinuousMonitoringMain = value;
  //   SocketController.instance.sendDataInBroadcastData(selectedRobotUuid, startContinuousMonitoring ? SocketConstant.startContinuousPositionUpdate : SocketConstant.stopContinuousPositionUpdate);
  //   notifyListeners();
  // }

  ///List of available points
  Map<String, List<Waypoint>> waypointsList = {};

  ///List of navigation routes
  Map<String, Map<String, List<List<double>>>> naviRoutes = {};

  ///List of virtual wall
  Map<String, List<VirtualWallPoint>> virtualWall = {};

  ///Laser Sensor Data
  List<List<double>> laserData = [];

  ///Laser Sensor Data
  List<List<double>> threeDData = [];

  ///Session Data
  SessionData? sessionData;

  ///Sim Data
  SimEvent? simEvent;

  ///Nav Event
  NavModeEvent? navModeEvent;

  updateVolume({double? volume}) {
    if ((volume ?? 0.1) < 0.1) {
      sessionData?.systemVolume = 0.1;
    } else {
      sessionData?.systemVolume = volume ?? 0.1;
    }
    // SocketController.instance.sendDataInBroadcastData(selectedRobotUuid, SocketConstant.changeVolume, data: sessionData?.systemVolume);
    notifyListeners();
  }

  updateNavigationSpeed({double? navigationSpeed}) {
    if ((navigationSpeed ?? 0.1) < 0.1) {
      sessionData?.navigationSpeed = 0.1;
    } else {
      sessionData?.navigationSpeed = navigationSpeed ?? 0.1;
    }
    // SocketController.instance.sendDataInBroadcastData(selectedRobotUuid, SocketConstant.changeNavigationSpeed, data: sessionData?.navigationSpeed);
    notifyListeners();
  }

  updateCruiseSpeed({double? cruiseSpeed}) {
    if ((cruiseSpeed ?? 0.1) < 0.1) {
      sessionData?.cruiseSpeed = 0.1;
    } else {
      sessionData?.cruiseSpeed = cruiseSpeed ?? 0.1;
    }
    // SocketController.instance.sendDataInBroadcastData(selectedRobotUuid, SocketConstant.changeCruiseSpeed, data: sessionData?.cruiseSpeed);
    notifyListeners();
  }

  /// Update Hide Navigation Bar
  void updateHideNavBar(bool value) async {
    // Update local/session state
    sessionData?.hideNavBar = value;

    // Notify robot
    // SocketController.instance.sendDataInBroadcastData(
    //   selectedRobotUuid,
    //   SocketConstant.hideNavBar,
    //   data: value,
    // );

    notifyListeners();
  }

  /// Update Hide Status Bar
  void updateHideStatusBar(bool value) async {
    // Update local state
    sessionData?.hideStatusBar = value;

    // Notify robot
    // SocketController.instance.sendDataInBroadcastData(
    //   selectedRobotUuid,
    //   SocketConstant.hideStatusBar,
    //   data: value,
    // );

    notifyListeners();
  }

  /// Update Slide Show Navigation Bar
  void updateSlideShowNavBar(bool value) async {
    // Update local state
    sessionData?.slideShowNavBar = value;

    // Notify robot
    // SocketController.instance.sendDataInBroadcastData(
    //   selectedRobotUuid,
    //   SocketConstant.slideShowNavigationBar,
    //   data: value,
    // );

    notifyListeners();
  }

  /// Update Slide Show Notification Bar
  void updateSlideShowNotificationBar(bool value) async {
    // Update local state
    sessionData?.slideShowNotificationBar = value;

    // Notify robot
    // SocketController.instance.sendDataInBroadcastData(
    //   selectedRobotUuid,
    //   SocketConstant.slideShowNotificationBar,
    //   data: value,
    // );

    notifyListeners();
  }

  ///Network Event
  Map<String, NetworkEvent?> networkEvent = {};

  ///Session Data
  bool isEmergencyPressed = false;

  ///Version Data
  VersionData? versionData;

  ///Sensor Data
  SensorData? sensorData;

  ///System Data
  SystemData? systemData;

  ///Speed Data
  SpeedData? speedData;

  Map<String, dynamic>? adsDataRes;

  ///Device State
  DeviceStateEvent? deviceState;

  ///Battery
  Map<String, Map<String, dynamic>?> batteryData = {};

  ///Global Path when navigation is started
  List<List<double>>? globalPath;

  Timer? laserTimer;
  LaserDataResponseModel? threeDDataModel;
  LaserDataResponseModel? laserDataResponseModel;

  String? crtImg;
  PictureInfo? odigoImage;
  PictureInfo? chargingPointImage;
  PictureInfo? productionPointImage;
  PictureInfo? deliveryPointImage;
  PictureInfo? routeImage;
  ui.Picture? recyclePoint;

  bool isPointShown = true;
  bool isDialogShown = false;

  void updateIsPointShown(bool isPointShown) {
    this.isPointShown = isPointShown;
    notifyListeners();
  }

  bool isVirtualWallShown = true;

  void updateVirtualWallShown(bool isVirtualWallShown) {
    this.isVirtualWallShown = isVirtualWallShown;
    notifyListeners();
  }

  bool isEditModeSelected = false;

  void updateIsEditModeSelected(bool isEditModeSelected) {
    this.isEditModeSelected = isEditModeSelected;
    notifyListeners();
  }

  bool showCameraView = false;

  bool _showScreenShareView = false;

  bool get showScreenShareView => _showScreenShareView;

  set showScreenShareView(bool value) {
    _showScreenShareView = value;
    notifyListeners();
  }

  int? selectedCamera = null;
  bool isMuted = true;

  void updateIsMuted(bool isMuted) {
    this.isMuted = isMuted;
    // SocketController.instance.sendDataInBroadcastData(
    //   selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!,
    //   SocketConstant.toggleAudio,
    //   data: {'cameraId': selectedCamera == 0 ? 1 : 0, 'toggle': !isMuted},
    // );
    notifyListeners();
  }

  void updateShowCameraView(bool showCameraView) {
    this.showCameraView = showCameraView;
    if (this.showCameraView) {
      selectedCamera = 0;
    } else {
      selectedCamera = null;
    }
    notifyListeners();
  }

  bool isRouteShown = true;

  void updateIsRouteShown(bool isRouteShown) {
    this.isRouteShown = isRouteShown;
    notifyListeners();
  }

  void refreshMapPainter(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(mapPainterController).refreshMapPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  void refreshWaypointsPainter(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(waypointsPainterController).refreshWaypointsPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  // void refreshRelocationPainter(String mapsUuid, {bool isNotify = true, required RelocationResponseModel? pose, String? color}) {
  //   // AppConstants.constant.globalRef?.read(relocationPainterController).refreshRelocationPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify, pose: pose, color: color);
  // }

  void refreshPositionPainter(String mapsUuid, {bool isNotify = true, required DeviceData robot}) {
    // AppConstants.constant.globalRef?.read(positionPainterController).refreshPositionPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify, robot: robot);
  }

  void refreshVirtualWallPainter(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(virtualWallPainterController).refreshVirtualWallPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  void refreshCurrentMousePosition(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(currentMousePositionPainterController).refreshCurrentMousePosition(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  void refreshContinousData(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(continousDataPainterController).refreshContinousData(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  void refreshRoutesPainter(String mapsUuid, {bool isNotify = true}) {
    // AppConstants.constant.globalRef?.read(routesPainterController).refreshRoutesPainter(mapVariablesData[mapsUuid]!, isNotify: isNotify);
  }

  void refreshEntireCanvas(String mapsUuid) {
    refreshVirtualWallPainter(mapsUuid);
    refreshWaypointsPainter(mapsUuid);
    refreshRoutesPainter(mapsUuid);
    refreshContinousData(mapsUuid);
  }

  ///Device Data Api
  /// Device List API
  ///
  ///
  ///
  ///

  Future<void> updateTagForRobot(String robotId, String tag) async {}

  String colorToHex(Color color, {bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  Future<void> updateColorForRobot(String robotId, Color color) async {}

  DeviceData? get selectedRobotOnMap => _selectedRobotOnMap;
  DeviceData? _selectedRobotOnMap;

  set selectedRobotOnMap(DeviceData? selectedRobotOnMap) {
    if (selectedRobotOnMap != null) {
      selectRobotLiveUuid = selectedRobotOnMap.deviceDetails?.firstOrNull?.uuid;
    }
    _selectedRobotOnMap = selectedRobotOnMap;
  }

  String get selectedRobotUuid => selectedRobotOnMap?.deviceDetails?.firstOrNull?.uuid ?? '';

  String? selectRobotLiveUuid;

  Map<String, List<DeviceData>> deviceList = {};

  Future<void> deviceListApi({required String mapsUuid}) async {
    deviceList[mapsUuid] = [];
    selectedRobotOnMap = null;
    selectRobotLiveUuid = null;
    // String request = deviceListRequestModelToJson(
    //   DeviceListRequestModel(
    //     activeRecords: true,
    //     mapsUuid: mapsUuid,
    //   ),
    // );

    // final result = await deviceRepository.deviceListApi(request, 1);
    // result.when(
    //   success: (data) {
    //     deviceList[mapsUuid]!.addAll(data.data ?? []);
    //   },
    //   failure: (error) {},
    // );

    ///Get Robot List
    notifyListeners();
    listenToRobotPosition(mapsUuid);
    notifyListeners();
  }

  Future<void> updateDeviceTagColorApi({required String robotUuid, String? tag, String? color}) async {
    // final result = await deviceRepository.updateDeviceTagColorApi(jsonEncode({'uuid': robotUuid, 'colour': color, 'tag': tag}));
    // result.when(
    //   success: (data) {},
    //   failure: (error) {},
    // );
  }

  List<String> newConnectedRobotList = [];
  List<String> connectedRobotList = [];

  bool isTimelineScreen = false;
  int receivedChunks = 0;

  // Timeline gap handling
  static const int _timelineGapThresholdMs = 2000; // 2s
  static const int _timelineGapInsertStepMs = 1000; // 1s

  Future<void> listenToRobotPosition(String mapsUuid) async {
    connectedRobotList.clear();
    newConnectedRobotList.clear();
    // SocketController.instance.onRobotList = null;
    // SocketController.instance.onContinuosDataReceived = null;
    // SocketController.instance.onRobotPositionReceived = null;
    // SocketController.instance.onFileTransferStarted = null;
    // SocketController.instance.onFileTransferProgress = null;
    // SocketController.instance.onFileTransferCompleted = null;
    // SocketController.instance.onFileTransferFailed = null;
    // SocketController.instance.onFileTransferStarted = (int totalLen, String timelineFilePath) {
    //   notifyListeners();
    //   if (globalNavigatorKey.currentContext != null) {
    //     showFileLoadingDialog(globalNavigatorKey.currentContext!, totalLen, timelineFilePath);
    //   }
    // };
    // SocketController.instance.onFileTransferProgress = (int receivedChunks) {
    //   this.receivedChunks = receivedChunks;
    //   notifyListeners();
    // };
    // SocketController.instance.onFileTransferCompleted = (String filePath) {
    //   if (globalNavigatorKey.currentContext != null) {
    //     Navigator.pop(globalNavigatorKey.currentContext!);
    //     showSuccessFailureDialogue(
    //       context: globalNavigatorKey.currentContext!,
    //       message: 'File transfer Successful',
    //       isSuccess: true,
    //       onTap: () async {
    //         if (filePath.contains('timeline')) {
    //           if (isDeviceListVisible) {
    //             timelineFilePath = filePath;
    //             deviceListAnimationController?.reverse(from: deviceListAnimationController?.value).then((value) async {
    //               updateIsDeviceListVisible(false);
    //               isTimelineScreen = true;
    //               AppConstants.constant.globalRef?.read(navigationStackController).push(NavigationStackItem.timeline(robotId: selectedRobotUuid, mapsUuid: mapsUuid));
    //             });
    //             Navigator.pop(globalNavigatorKey.currentContext!);
    //           }
    //         } else {
    //           logsPath = filePath;
    //           logsPath = filePath;
    //           Navigator.pop(globalNavigatorKey.currentContext!);
    //           deviceListAnimationController?.reverse(from: deviceListAnimationController?.value).then((value) async {
    //             updateIsDeviceListVisible(false);
    //             isTimelineScreen = true;
    //             AppConstants.constant.globalRef?.read(navigationStackController).push(NavigationStackItem.robotLogs(robotId: selectedRobotUuid, mapsUuid: mapsUuid));
    //           });
    //         }
    //       },
    //     );
    //   }
    // };
    // SocketController.instance.onFileTransferFailed = (String error) {
    //   if (globalNavigatorKey.currentContext != null) {
    //     Navigator.pop(globalNavigatorKey.currentContext!);
    //     showSuccessFailureDialogue(
    //       context: globalNavigatorKey.currentContext!,
    //       message: error,
    //       onTap: () {
    //         Navigator.pop(globalNavigatorKey.currentContext!);
    //       },
    //     );
    //   }
    // };
    // SocketController.instance.onRobotList = (robotList) {
    //   isRefreshingRobots = false;
    //   newConnectedRobotList = robotList.where((robot) => !connectedRobotList.contains(robot)).toList();
    //   newConnectedRobotList.forEach((robot) {
    //     Future.delayed(Duration(milliseconds: 200), () {
    //       SocketController.instance.sendDataInBroadcastData(robot, null);
    //     });
    //   });
    //   connectedRobotList = robotList;
    //   if (connectedRobotList.isNotEmpty) {
    //     connectedRobotList.removeWhere((uuid) => !deviceList[mapsUuid]!.any((robot) => robot.deviceDetails?.firstOrNull?.uuid == uuid));
    //   }
    //   if (selectedRobotOnMap == null && selectRobotLiveUuid != null) {
    //     selectedRobotOnMap = deviceList[mapsUuid]?.where((e) => e.deviceDetails?.firstOrNull?.uuid == selectRobotLiveUuid).firstOrNull;
    //     Future.delayed(Duration(milliseconds: 500), () => SocketController.instance.sendDataInBroadcastData(selectedRobotUuid, SocketConstant.startContinuousPositionUpdate));
    //     notifyListeners();
    //   }
    //   deviceList[mapsUuid] = deviceList[mapsUuid]!.map((device) => !connectedRobotList.contains(device.deviceDetails?.firstOrNull?.uuid) ? (device..pose = null) : device).toList();
    //   if (!isTimelineScreen) {
    //     if (selectedRobotOnMap != null && !connectedRobotList.contains(selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!)) {
    //       selectedRobotOnMap = null;
    //       show3DData = false;
    //       threeDData = [];
    //       laserData = [];
    //       globalPath = null;
    //       sessionData = null;
    //       versionData = null;
    //       sensorData = null;
    //       systemData = null;
    //       speedData = null;
    //       showCameraView = false;
    //       selectedCamera = null;
    //       adsDataRes = null;
    //       isDeviceSettingsVisible = false;
    //       batteryData = {};
    //       refreshContinousData(mapsUuid, isNotify: true);
    //     }
    //   }
    //   notifyListeners();
    // };
    // SocketController.instance.onRobotPositionReceived = (robotId, mapsUuid, pose) {
    //   deviceList[mapsUuid] =
    //       deviceList[mapsUuid]?.map((e) {
    //         if (e.deviceDetails?.firstOrNull?.uuid == robotId) {
    //           e.pose = pose;
    //           e.color = e.color;
    //           return e;
    //         }
    //         return e;
    //       }).toList() ??
    //           [];
    //   if (deviceList[mapsUuid]?.isNotEmpty ?? false) {
    //     refreshPositionPainter(mapsUuid, robot: deviceList[mapsUuid]!.firstWhere((element) => element.deviceDetails?.firstOrNull?.uuid == robotId), isNotify: true);
    //   }
    //   if (isRecenter && selectedRobotOnMap != null && selectedRobotUuid == robotId) {
    //     // Keep the robot centered like Google Maps.
    //     recenterOnPose(mapsUuid, pose);
    //   }
    // };
    // SocketController.instance.onContinuosDataReceived = (robotId, mapName, path, threeDData, laserData, simEvent, navModeEvent, sessionData, versionData, sensorData, systemData, speedData, deviceState, networkEvent, batteryData, adsDataRes) {
    //   this.batteryData[robotId] = batteryData;
    //   if (networkEvent != null) {
    //     this.networkEvent[robotId] = networkEvent;
    //   }
    //   if (robotId == selectedRobotUuid) {
    //     globalPath = path;
    //     this.threeDData = threeDData ?? [];
    //     this.laserData = laserData ?? [];
    //     this.sessionData = sessionData;
    //     this.versionData = versionData;
    //     this.sensorData = sensorData;
    //     this.simEvent = simEvent;
    //     this.navModeEvent = navModeEvent;
    //     this.adsDataRes = adsDataRes;
    //     this.systemData = systemData;
    //     this.speedData = speedData;
    //     this.deviceState = deviceState;
    //   }
    //   refreshContinousData(mapsUuid, isNotify: true);
    //   notifyListeners();
    // };
    // // demoSocketData();
  }

  // Waypoint? getPointAtPosition(String mapsUuid, double x, double y) {
  //   Waypoint? tappedPoint;
  //   for (var points in waypointsList[mapsUuid]!) {
  //     if (((points.pose!.x!.convertXFromDasherPoint(mapVariablesData[mapsUuid]!) - x).abs() <= (10 / scale[mapsUuid]!)) && ((points.pose!.y!.convertYFromDasherPoint(mapVariablesData[mapsUuid]!) - y).abs() <= (10 / scale[mapsUuid]!))) {
  //       tappedPoint = points;
  //       break;
  //     }
  //   }
  //   return tappedPoint;
  // }

  MapEntry<String, List<List<double>>>? getRouteOnPosition(String mapsUuid, double x, double y) {
    MapEntry<String, List<List<double>>>? route;
    naviRoutes[mapsUuid]!.forEach((key, value) {
      // if (((value.first.first.convertXFromDasherPoint(mapVariablesData[mapsUuid]!) - x).abs() <= 5) && ((value.first.last.convertYFromDasherPoint(mapVariablesData[mapsUuid]!) - y).abs() <= 5)) {
      //   route = MapEntry(key, value);
      // }
    });
    return route;
  }

  ///Chip Data
  List<PointType> pointTypeList = [PointType.PRODUCTION, PointType.CHARGE, PointType.DELIVERY, PointType.ROUTE];
  Map<String, List<PointType>> selectedPointTypeList = {};

  void addSelectedPointType(String mapsUuid, PointType type) {
    if (selectedPointTypeList[mapsUuid] == null) selectedPointTypeList[mapsUuid] = [];
    selectedPointTypeList[mapsUuid]!.add(type);
    refreshWaypointsPainter(mapsUuid, isNotify: true);
    notifyListeners();
  }

  void removeSelectedPointType(String mapsUuid, PointType type) {
    selectedPointTypeList[mapsUuid]!.remove(type);
    refreshWaypointsPainter(mapsUuid, isNotify: true);
    notifyListeners();
  }

  bool isDeviceSettingsVisible = false;
  AnimationController? deviceSettingsAnimationController;

  updateIsDeviceSettingsVisible(bool isDeviceSettingsVisible) {
    this.isDeviceSettingsVisible = isDeviceSettingsVisible;
    notifyListeners();
  }

  bool isDeviceListVisible = false;
  AnimationController? deviceListAnimationController;

  updateIsDeviceListVisible(bool isDeviceListVisible) {
    this.isDeviceListVisible = isDeviceListVisible;
    notifyListeners();
  }

  bool isRefreshingRobots = false;

  refreshRobots({String? destinationUuid, String? mapsUuid}) {
    isRefreshingRobots = true;
    // SocketController.instance.requestUserList(destinationUuid: destinationUuid, mapsUuid: mapsUuid);
    notifyListeners();
  }

  bool isAndroidMemoryDetailsVisible = false;
  AnimationController? androidMemoryDetailsAnimationController;
  AnimationController? mapInformationAnimationController;
  bool mapInformationVisible = false;

  updateIsMapInformationVisible(bool mapInformationVisible) {
    this.mapInformationVisible = mapInformationVisible;
    notifyListeners();
  }

  updateIsAndroidMemoryDetailsVisible(bool isAndroidMemoryDetailsVisible) {
    this.isAndroidMemoryDetailsVisible = isAndroidMemoryDetailsVisible;
    notifyListeners();
  }
  //
  // List<MapListData> mapList = [];
  // UIState<MapListResponseModel> mapListDataState = UIState<MapListResponseModel>();

  // Future<void> getMapList(String destinationUuid, {String? destinationFloorUuid}) async {
  //   mapList.clear();
  //   mapListDataState.isLoading = true;
  //   notifyListeners();
  //   final result = await storeMappingRepository.getMapsApi(destinationUuid: destinationUuid, destinationFloorUuid: destinationFloorUuid);
  //   result.when(
  //     success: (data) {
  //       mapList.clear();
  //       mapListDataState.isLoading = false;
  //       mapListDataState.success = data as MapListResponseModel?;
  //       mapList.addAll(data.data ?? []);
  //     },
  //     failure: (error) {},
  //   );
  //   notifyListeners();
  // }

  bool show3DData = false;

  List<String> get modeList {
    // if (!isEditModeSelected) {
    //   return [relocateStr, navigationStr];
    // }
    return [relocateStr, navigationStr, virtualWallStr, routeStr];
  }

  Map<String, String> get modeDescriptionList => {
    relocateStr: 'Drag from the robot’s current position in the direction it is facing to relocate it accurately on the map.',
    navigationStr: 'Drag from any position on the map in the direction the robot is facing to send it to that location.',
    virtualWallStr: 'Click once on the map to set the starting point, then drag to the end point to draw a virtual wall.',
    routeStr: 'Click once to set the starting point, then drag through each waypoint to draw the route. Double-click to mark the final point and save the route.',
  };

  String? selectedMode;

  // updateSelectedMode(String mode, String mapName) {
  //   switch (mode) {
  //     case virtualWallStr:
  //       updatedVirtualWallPoints.clear();
  //       eraseVirtualWallPoint = null;
  //       virtualWallPoint = null;
  //       eraseVirtualWall = false;
  //       // getWaypoints(mapName);
  //       break;
  //     case navigationStr:
  //       navigatePose = null;
  //       navigationPoint = null;
  //       break;
  //     case relocateStr:
  //       relocationPoint = null;
  //       break;
  //     case routeStr:
  //       newRoutePoints.clear();
  //       // getWaypoints(mapName);
  //       break;
  //     default:
  //       break;
  //   }
  //   currentMouseCursorPosition = null;
  //   if (selectedMode == mode) {
  //     selectedMode = null;
  //     notifyListeners();
  //   } else {
  //     selectedMode = null;
  //     notifyListeners();
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       selectedMode = mode;
  //       notifyListeners();
  //     });
  //   }
  // }

  ////-------------------------------------- Relocation ----------------------------------------------///

  // RelocationResponseModel? relocationPoint;
  //
  // void markRelocationStartPoint(String mapsUuid, double x, double y) {
  //   relocationPoint = null;
  //   relocationPoint = RelocationResponseModel(
  //     startPoint: RelocationPoint(x: x, y: y),
  //     endPoint: RelocationPoint(x: x, y: y),
  //     theta: 0,
  //   );
  //   notifyListeners();
  //   refreshRelocationPainter(mapsUuid, pose: relocationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  // }
  //
  // void updateRelocationPoint(String mapsUuid, double x, double y) {
  //   relocationPoint?.endPoint.x = x;
  //   relocationPoint?.endPoint.y = y;
  //   if (relocationPoint != null) {
  //     relocationPoint!.theta = Offset(relocationPoint!.startPoint.x, relocationPoint!.startPoint.y).calculateTheta(Offset(relocationPoint!.endPoint.x, relocationPoint!.endPoint.y));
  //   }
  //   notifyListeners();
  //   refreshRelocationPainter(mapsUuid, pose: relocationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  // }
  //
  // void markRelocationEndPoint(String mapsUuid, BuildContext context, {bool relocate = true}) {
  //   if (relocationPoint != null) {
  //     relocationPoint!.theta = Offset(relocationPoint!.startPoint.x, relocationPoint!.startPoint.y).calculateTheta(Offset(relocationPoint!.endPoint.x, relocationPoint!.endPoint.y));
  //     Pose relocatePose = Pose(
  //       x: relocationPoint!.startPoint.x.convertXToDasherPoint(mapVariablesData[mapsUuid]!),
  //       y: relocationPoint!.startPoint.y.convertYToDasherPoint(mapVariablesData[mapsUuid]!),
  //       theta: relocationPoint!.theta,
  //     );
  //     if (relocate) {
  //       setToastMessage('Relocate: x:${relocatePose.x?.toStringAsFixed(2)}, y:${relocatePose.y?.toStringAsFixed(2)}, degree:${relocatePose.theta?.toStringAsFixed(2)}');
  //       SocketController.instance.sendDataInBroadcastData(selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!, SocketConstant.relocate, data: relocatePose.toJson());
  //     }
  //   }
  //   relocationPoint = null;
  //   notifyListeners();
  //   refreshRelocationPainter(mapsUuid, pose: relocationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  // }
  //
  // List<double>? currentMouseCursorPosition;
  //
  // void updateCurrentCursorPosition(String mapsUuid, double x, double y) {
  //   currentMouseCursorPosition = [x, y];
  //   refreshCurrentMousePosition(mapsUuid, isNotify: true);
  //   refreshRoutesPainter(mapsUuid);
  //   notifyListeners();
  // }

  ////-------------------------------------- Navigation ----------------------------------------------///

  // List<double> navigationDoubleTapPoint = [];
  //
  // RelocationResponseModel? navigationPoint;
  //
  // void markNavigationStartPoint(String mapsUuid, double x, double y) {
  //   navigationPoint = null;
  //   navigatePose = null;
  //   navigationPoint = RelocationResponseModel(
  //     startPoint: RelocationPoint(x: x, y: y),
  //     endPoint: RelocationPoint(x: x, y: y),
  //     theta: 0,
  //   );
  //   notifyListeners();
  //   refreshRelocationPainter(mapsUuid, pose: navigationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  // }
  //
  // void updateNavigationPoint(String mapsUuid, double x, double y) {
  //   navigationPoint?.endPoint.x = x;
  //   navigationPoint?.endPoint.y = y;
  //   if (navigationPoint != null) {
  //     navigationPoint!.theta = Offset(navigationPoint!.startPoint.x, navigationPoint!.startPoint.y).calculateTheta(Offset(navigationPoint!.endPoint.x, navigationPoint!.endPoint.y));
  //   }
  //   notifyListeners();
  //   refreshRelocationPainter(mapsUuid, pose: navigationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  // }
  //
  // Pose? navigatePose;
  //
  // void markNavigationEndPoint(String mapsUuid) {
  //   if (navigationPoint != null) {
  //     navigationPoint!.theta = Offset(navigationPoint!.startPoint.x, navigationPoint!.startPoint.y).calculateTheta(Offset(navigationPoint!.endPoint.x, navigationPoint!.endPoint.y));
  //     navigatePose = Pose(
  //       x: navigationPoint!.startPoint.x.convertXToDasherPoint(mapVariablesData[mapsUuid]!),
  //       y: navigationPoint!.startPoint.y.convertYToDasherPoint(mapVariablesData[mapsUuid]!),
  //       theta: navigationPoint!.theta,
  //     );
  //   }
  //   setToastMessage('Navigate to: x:${navigatePose?.x?.toStringAsFixed(2)}, y:${navigatePose?.y?.toStringAsFixed(2)}, degree:${navigatePose?.theta?.toStringAsFixed(2)}');
  //   SocketController.instance.sendDataInBroadcastData(selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!, SocketConstant.navigate, data: navigatePose?.toJson());
  //   navigationPoint = null;
  //   refreshRelocationPainter(mapsUuid, pose: navigationPoint, isNotify: true, color: selectedRobotOnMap?.color);
  //   notifyListeners();
  // }

  ///////// --------------------------- Virtual Wall Screen---------------------------------////////

  // VirtualWallPoint? virtualWallPoint;
  // List<VirtualWallPoint> updatedVirtualWallPoints = [];
  // bool point1Marked = false;
  //
  // void markPoint1(String mapsUuid, double x, double y) {
  //   virtualWallPoint = VirtualWallPoint(
  //     pose: VirtualWallPose(
  //       point1: Point(x: x, y: y),
  //       point2: Point(x: x, y: y),
  //     ),
  //   );
  //   point1Marked = true;
  //   refreshVirtualWallPainter(mapsUuid, isNotify: true);
  // }
  //
  // void updatedMarkPoint(String mapsUuid, double x, double y) {
  //   virtualWallPoint?.pose.point2.x = x;
  //   virtualWallPoint?.pose.point2.y = y;
  //   refreshVirtualWallPainter(mapsUuid, isNotify: true);
  // }
  //
  // void markPoint2(String mapsUuid, double x, double y) {
  //   virtualWallPoint?.pose.point2.x = x;
  //   virtualWallPoint?.pose.point2.y = y;
  //   virtualWallPoint?.pose.point1.x = virtualWallPoint?.pose.point1.x.convertXToDasherPoint(mapVariablesData[mapsUuid]!) ?? 0;
  //   virtualWallPoint?.pose.point1.y = virtualWallPoint?.pose.point1.y.convertYToDasherPoint(mapVariablesData[mapsUuid]!) ?? 0;
  //   virtualWallPoint?.pose.point2.x = virtualWallPoint?.pose.point2.x.convertXToDasherPoint(mapVariablesData[mapsUuid]!) ?? 0;
  //   virtualWallPoint?.pose.point2.y = virtualWallPoint?.pose.point2.y.convertYToDasherPoint(mapVariablesData[mapsUuid]!) ?? 0;
  //   if (virtualWallPoint != null) {
  //     updatedVirtualWallPoints.add(virtualWallPoint!);
  //     virtualWallPoint = VirtualWallPoint(
  //       pose: VirtualWallPose(point1: Point(x: 0, y: 0), point2: Point(x: 0, y: 0)),
  //     );
  //     point1Marked = false;
  //     refreshVirtualWallPainter(mapsUuid, isNotify: true);
  //   }
  // }
  //
  // ///Save changes in virtual wall
  // Future<void> saveVirtualWall(String mapsUuid) async {
  //   List<VirtualWallPoint> finalPoints = virtualWall[mapsUuid]! + updatedVirtualWallPoints;
  //   eraseVirtualWall = false;
  //   updatedVirtualWallPoints.clear();
  //   virtualWallPoint = null;
  //   SocketController.instance.sendDataInBroadcastData(selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!, SocketConstant.saveWalls, data: VirtualWallResponseModel(waypoints: finalPoints).toJson());
  // }
  //
  // ///Save changes in routes
  // Future<void> saveRoutes(String mapsUuid, String routeName) async {
  //   if (selectedPointTypeList[mapsUuid] == null) selectedPointTypeList[mapsUuid] = [];
  //   naviRoutes[mapsUuid]!.addAll({routeName: newRoutePoints});
  //   if (!selectedPointTypeList[mapsUuid]!.contains(PointType.ROUTE)) {
  //     selectedPointTypeList[mapsUuid]!.add(PointType.ROUTE);
  //   }
  //   selectedMode = null;
  //   SocketController.instance.sendDataInBroadcastData(selectedRobotOnMap!.deviceDetails!.firstOrNull!.uuid!, SocketConstant.saveRoutes, data: naviRoutes[mapsUuid]!);
  // }
  //
  bool eraseVirtualWall = false;
  //
  // updateEraseVirtualWall(bool eraseVirtualWall, String mapsUuid) {
  //   this.eraseVirtualWall = eraseVirtualWall;
  //   eraseVirtualWallPoint = null;
  //   virtualWallPoint = null;
  //   updatedVirtualWallPoints.clear();
  //   getWaypoints(mapsUuid);
  //   notifyListeners();
  // }

  EraseVirtualWallPoint? eraseVirtualWallPoint;

  void startUpdateErasedMarkPoint(String mapsUuid, double x, double y) {
    eraseVirtualWallPoint = EraseVirtualWallPoint(
      pose: EraseVirtualWallPose(
        point1: Point(x: 0, y: 0),
        point2: Point(x: 0, y: 0),
        point3: Point(x: 0, y: 0),
        point4: Point(x: 0, y: 0),
      ),
    );
    eraseVirtualWallPoint?.pose.point1.x = x;
    eraseVirtualWallPoint?.pose.point1.y = y;
    eraseVirtualWallPoint?.pose.point2.x = x;
    eraseVirtualWallPoint?.pose.point2.y = y;
    eraseVirtualWallPoint?.pose.point3.x = x;
    eraseVirtualWallPoint?.pose.point3.y = y;
    eraseVirtualWallPoint?.pose.point4.x = x;
    eraseVirtualWallPoint?.pose.point4.y = y;
    refreshVirtualWallPainter(mapsUuid, isNotify: true);
  }

  void updateErasedMarkPoint(String mapsUuid, double x, double y) {
    eraseVirtualWallPoint?.pose.point2.x = x;
    eraseVirtualWallPoint?.pose.point3.x = x;
    eraseVirtualWallPoint?.pose.point3.y = y;
    eraseVirtualWallPoint?.pose.point4.y = y;
    refreshVirtualWallPainter(mapsUuid, isNotify: true);
  }

  void endUpdateErasedMarkPoint(String mapsUuid) {
    final wallPoint1X = eraseVirtualWallPoint!.pose.point1.x.convertXToDasherPoint(mapVariablesData!);
    final wallPoint1Y = eraseVirtualWallPoint!.pose.point1.y.convertYToDasherPoint(mapVariablesData!);
    final wallPoint2X = eraseVirtualWallPoint!.pose.point2.x.convertXToDasherPoint(mapVariablesData!);
    final wallPoint2Y = eraseVirtualWallPoint!.pose.point2.y.convertYToDasherPoint(mapVariablesData!);
    final wallPoint3X = eraseVirtualWallPoint!.pose.point3.x.convertXToDasherPoint(mapVariablesData!);
    final wallPoint3Y = eraseVirtualWallPoint!.pose.point3.y.convertYToDasherPoint(mapVariablesData!);
    final wallPoint4X = eraseVirtualWallPoint!.pose.point4.x.convertXToDasherPoint(mapVariablesData!);
    final wallPoint4Y = eraseVirtualWallPoint!.pose.point4.y.convertYToDasherPoint(mapVariablesData!);
    List<VirtualWallPoint> virtualWallAffectedList = [];
    eraseVirtualWallPoint = null;
    for (var walls in virtualWall[mapsUuid]!) {
      bool lineIntersect = lineIntersectsRectangle(
        Offset(wallPoint1X, wallPoint1Y),
        Offset(wallPoint2X, wallPoint2Y),
        Offset(wallPoint3X, wallPoint3Y),
        Offset(wallPoint4X, wallPoint4Y),
        Offset(walls.pose.point1.x, walls.pose.point1.y),
        Offset(walls.pose.point2.x, walls.pose.point2.y),
      );
      if (lineIntersect) {
        virtualWallAffectedList.add(walls);
      }
    }
    for (var walls in virtualWallAffectedList) {
      virtualWall[mapsUuid]!.removeWhere(
            (element) => (element.pose.point1.x == walls.pose.point1.x) && (element.pose.point1.y == walls.pose.point1.y) && (element.pose.point2.x == walls.pose.point2.x) && (element.pose.point2.y == walls.pose.point2.y),
      );
    }
    refreshVirtualWallPainter(mapsUuid, isNotify: true);
  }

  bool lineIntersectsRectangle(Offset rectPoint1, Offset rectPoint2, Offset rectPoint3, Offset rectPoint4, Offset lineStart, Offset lineEnd) {
    double minX = min(min(min(rectPoint1.dx, rectPoint2.dx), rectPoint3.dx), rectPoint4.dx);
    double maxX = max(max(max(rectPoint1.dx, rectPoint2.dx), rectPoint3.dx), rectPoint4.dx);
    double minY = min(min(min(rectPoint1.dy, rectPoint2.dy), rectPoint3.dy), rectPoint4.dy);
    double maxY = max(max(max(rectPoint1.dy, rectPoint2.dy), rectPoint3.dy), rectPoint4.dy);

    // Check if any endpoint of the line is inside the rectangle
    if ((lineStart.dx >= minX && lineStart.dx <= maxX && lineStart.dy >= minY && lineStart.dy <= maxY) || (lineEnd.dx >= minX && lineEnd.dx <= maxX && lineEnd.dy >= minY && lineEnd.dy <= maxY)) {
      return true;
    }

    // Check if any part of the line intersects with any part of the rectangle
    if (lineStart.dx < minX && lineEnd.dx < minX) {
      return false;
    }
    if (lineStart.dx > maxX && lineEnd.dx > maxX) {
      return false;
    }
    if (lineStart.dy < minY && lineEnd.dy < minY) {
      return false;
    }
    if (lineStart.dy > maxY && lineEnd.dy > maxY) {
      return false;
    }

    // Calculate line equation (y = mx + b)
    double m = (lineEnd.dy - lineStart.dy) / (lineEnd.dx - lineStart.dx);
    double b = lineStart.dy - m * lineStart.dx;

    // Check if any intersection point lies within the rectangle
    if (minX <= lineStart.dx && lineStart.dx <= maxX && minY <= m * minX + b && m * minX + b <= maxY) {
      return true;
    }
    if (minX <= lineEnd.dx && lineEnd.dx <= maxX && minY <= m * maxX + b && m * maxX + b <= maxY) {
      return true;
    }
    if (minY <= lineStart.dy && lineStart.dy <= maxY && minX <= (minY - b) / m && (minY - b) / m <= maxX) {
      return true;
    }
    if (minY <= lineEnd.dy && lineEnd.dy <= maxY && minX <= (maxY - b) / m && (maxY - b) / m <= maxX) {
      return true;
    }

    return false;
  }

  //// ------------------------------- Navi Routes ----------------------------------------///

  void onTapWhileCreatingRoute(double x, double y) async {
    newRoutePoints.add([x, y]);
  }

  // void onDoubleTapWhileCreatingRoute(String mapsUuid, double x, double y) async {
  //   newRoutePoints.add([x, y]);
  //   for (var routePoint in newRoutePoints) {
  //     routePoint.first = routePoint.first.convertXToDasherPoint(mapVariablesData[mapsUuid]!);
  //     routePoint.last = routePoint.last.convertYToDasherPoint(mapVariablesData[mapsUuid]!);
  //   }
  //   currentMouseCursorPosition = null;
  // }

  List<List<double>> newRoutePoints = [];

  String? toastMessage;
  Timer? toastTimer;

  void setToastMessage(String toastMessage) {
    toastTimer?.cancel();
    this.toastMessage = toastMessage;
    notifyListeners();
    toastTimer = Timer(Duration(seconds: 2), () {
      this.toastMessage = null;
      notifyListeners();
    });
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  void dispose() {
    _recenterTimer?.cancel();
    super.dispose();
  }

  Map<String, List> connectedWatchers = {};

  ///Time Line Event Handlers
  Map<DateTime, Map<String, dynamic>> timeLineMap = {};
  Timer? timelineTimer;
  int timelineTimeIndex = 0;

  bool isTimelinePlaying = false;

  List<DateTime> get timelineKeys => timeLineMap.keys.toList();

  void pauseTimeline() {
    isTimelinePlaying = false;
    timelineTimer?.cancel();
    timelineTimer = null;
    notifyListeners();
  }

  void playTimeline() {
    if (timeLineMap.isEmpty) return;
    isTimelinePlaying = true;
    final keys = timeLineMap.keys.toList();
    timelineTimeIndex = (timelineTimeIndex + 1) % keys.length;
    final delta = timeLineMap[keys[timelineTimeIndex]] ?? {};
    final full = _unpruneTimelinePayload(delta);
    loadTimelineData(full);
    startTimelineTimer();
    notifyListeners();
  }

  void toggleTimelinePlayPause() {
    if (isTimelinePlaying) {
      pauseTimeline();
    } else {
      playTimeline();
    }
  }

  void seekTimeline(int index, {bool isKey = false}) {
    if (timelineTimeIndex != 0 || timelineTimeIndex < (timelineKeys.length - 1)) {
      if (index > 0 && timelineTimeIndex < (timelineKeys.length - 1)) {
        timelineTimeIndex = timelineTimeIndex + index;
      } else if (timelineTimeIndex != 0) {
        timelineTimeIndex = timelineTimeIndex + index;
      }
    }

    if (timeLineMap.isEmpty) return;

    // pause while scrubbing
    pauseTimeline();

    final keys = timelineKeys;
    if (!isKey) {
      timelineTimeIndex = index.clamp(0, keys.length - 1);
    }

    // rebuild snapshot from deltas
    _timelineLastFull = {};
    for (int i = 0; i <= timelineTimeIndex; i++) {
      final delta = timeLineMap[keys[i]] ?? {};
      _unpruneTimelinePayload(delta);
    }
    loadTimelineData(Map<String, dynamic>.from(_timelineLastFull));
    notifyListeners();
  }

  /// Holds the last fully reconstructed timeline payload.
  /// Each new timeline item is a delta (pruned map) and is merged into this.
  Map<String, dynamic> _timelineLastFull = {};

  /// Deep-merge [delta] into [base].
  /// - If both old and new values are maps, merges recursively.
  /// - Otherwise, overwrites base[key] with delta[key].
  /// - If delta contains a key with value `null`, it will overwrite with null.
  void _mergeDeltaInto(Map<String, dynamic> base, Map<String, dynamic> delta) {
    delta.forEach((key, newVal) {
      final oldVal = base[key];

      if (oldVal is Map && newVal is Map) {
        final oldMap = Map<String, dynamic>.from(oldVal.map((k, v) => MapEntry(k.toString(), v)));
        final newMap = Map<String, dynamic>.from(newVal.map((k, v) => MapEntry(k.toString(), v)));
        _mergeDeltaInto(oldMap, newMap);
        base[key] = oldMap;
      } else {
        base[key] = newVal;
      }
    });
  }

  /// Applies a pruned (delta) payload over the last snapshot and returns a new full snapshot.
  Map<String, dynamic> _unpruneTimelinePayload(Map<String, dynamic> delta) {
    // Work on a copy to avoid accidental shared references.
    final full = Map<String, dynamic>.from(_timelineLastFull);
    _mergeDeltaInto(full, delta);

    // Persist the latest snapshot for the next delta.
    _timelineLastFull = full;

    // Return a fresh copy so downstream code can't mutate our stored snapshot.
    return Map<String, dynamic>.from(full);
  }

  String? timelineFilePath;
  String? logsPath;

  List<String> deviceLogs = [];

  Future<int> readLogsFile({String? path}) async {
    deviceLogs.clear();
    String res = '';
    if ((path ?? logsPath) != null) {
      res = '[${(await File(path ?? logsPath!).readAsString()).replaceAll(',,]', '.]')}]';
    }
    res = res.replaceAll(', ]', ']');
    if (res.trim().isEmpty) return 0;
    deviceLogs = res.split(':-:-:');
    deviceLogs.removeLast();
    notifyListeners();
    return deviceLogs.length;
  }

  Future<int> readTimelineFile() async {
    if (timeLineData == null) return 0;
    timelineTimer?.cancel();
    timelineTimer = null;
    timeLineMap.clear();
    _timelineLastFull = {};

    String res = timeLineData??"";
    // if ((path ?? timelineFilePath) != null) {
    //   // File is stored as "k,d" objects without top-level array; normalize.
    //   res = '[${(await File(path ?? timelineFilePath!).readAsString()).replaceAll(',,]', '.]')}]';
    // }
    res = res.replaceAll(', ]', ']');
    if (res.trim().isEmpty) return 0;

    //String timelineDate = (path ?? timelineFilePath)!.split('_').last;
    String timelineDate = "08-04-2026";
    timelineDate = timelineDate.split('.json').first;
    final rawList = (jsonDecode(res) as List);
    int totalLen = rawList.length;
    // Parse in order.
    final List<DateTime> parsedTimes = [];
    final List<Map<String, dynamic>> parsedDeltas = [];

    for (final e in rawList) {
      final dt = DateFormat('dd-MM-yyyy HH:mm:ss.S').parse('$timelineDate ${e['k']}');
      parsedTimes.add(dt);
      parsedDeltas.add(Map<String, dynamic>.from((e['d'] ?? {}) as Map));
    }

    // Build expanded timeline with synthetic gap frames.
    // NOTE: We reconstruct full snapshots while iterating so we always know current ru/mu.
    final Map<DateTime, Map<String, dynamic>> expanded = {};
    _timelineLastFull = {};

    for (int i = 0; i < parsedTimes.length; i++) {
      final currentTime = parsedTimes[i];
      final currentDelta = parsedDeltas[i];

      expanded[currentTime] = currentDelta;

      // Update snapshot so ru/mu become available for gap frames.
      final currentFull = _unpruneTimelinePayload(currentDelta);
      final robotId = (currentFull['ru'] ?? '').toString();
      final mapsUuid = (currentFull['mu'] ?? '').toString();

      if (i == parsedTimes.length - 1) break;

      final nextTime = parsedTimes[i + 1];
      final gapMs = nextTime.difference(currentTime).inMilliseconds;

      // If there is a big gap, insert a synthetic frame every 1 second in between.
      if (gapMs > _timelineGapThresholdMs && robotId.isNotEmpty && mapsUuid.isNotEmpty) {
        // Start inserting at +1s, stop before nextTime.
        int insertOffset = _timelineGapInsertStepMs;
        while (insertOffset < gapMs) {
          final t = currentTime.add(Duration(milliseconds: insertOffset));

          expanded[t] = {
            'ru': robotId,
            'mu': mapsUuid,
            // Everything else explicitly null to force UI clear.
            'p': null,
            'gp': null,
            '3d': null,
            'ld': null,
            'ssd': null,
            'bd': null,
            'ne': null,
            'vd': null,
            'snd': null,
            'si': null,
            'ds': null,
            'sd': null,
          };

          insertOffset += _timelineGapInsertStepMs;
        }

        // IMPORTANT: after inserting gap frames, reset snapshot back to currentFull
        // because the above call to _unpruneTimelinePayload already advanced it.
        _timelineLastFull = Map<String, dynamic>.from(currentFull);
      }
    }

    // Replace timeline with expanded and reset playback state.
    // Ensure keys are in chronological order.
    final sortedKeys = expanded.keys.toList()..sort();
    timeLineMap = {for (final k in sortedKeys) k: expanded[k] ?? {}};
    timelineTimeIndex = 0;

    // Reset snapshot to the first frame's full payload.
    _timelineLastFull = {};
    final firstDelta = timeLineMap[timeLineMap.keys.first] ?? {};
    final firstFull = _unpruneTimelinePayload(firstDelta);
    loadTimelineData(firstFull);
    return totalLen;
  }

  List<int> speedList = [];

  int speedIndex = 0;

  toggleSpeed() {
    speedIndex = (speedIndex + 1) % speedList.length;
    notifyListeners();
  }

  startTimelineTimer() {
    // Nothing to play.
    if (timeLineMap.isEmpty) return;

    final keys = timeLineMap.keys.toList();
    timelineTimer?.cancel();
    var timerMilliseconds = keys[timelineTimeIndex].difference(keys[timelineTimeIndex < timeLineMap.length ? timelineTimeIndex + 1 : 0]).inMilliseconds.abs();
    timelineTimer = Timer(
      Duration(
        milliseconds: (timerMilliseconds / speedList[speedIndex]).round(),
      ),
          () {
        // Defensive clamp in case map size changed.
        if (timelineTimeIndex < 0) timelineTimeIndex = 0;
        if (timelineTimeIndex >= keys.length) timelineTimeIndex = 0;

        final delta = timeLineMap[keys[timelineTimeIndex]] ?? {};
        final full = _unpruneTimelinePayload(delta);
        loadTimelineData(full);

        // Move forward and wrap around.
        timelineTimeIndex = (timelineTimeIndex + 1) % keys.length;
        startTimelineTimer();
      },
    );
  }

  loadTimelineData(Map<String, dynamic> response) {
    String robotId = response['ru'];
    String mapsUuid = response['mu'];

    // If this is a synthetic gap frame (all major payload keys are explicitly null),
    // clear UI state so we don't show stale pose/path during offline gaps.
    final bool isGapFrame = response.containsKey('p') && response['p'] == null && response.containsKey('ld') && response['ld'] == null && response.containsKey('3d') && response['3d'] == null && response.containsKey('gp') && response['gp'] == null;
    if (isGapFrame) {
      // Clear pose for this robot on the map.
      if ((deviceList[mapsUuid]?.isNotEmpty ?? false)) {
        deviceList[mapsUuid] = deviceList[mapsUuid]!.map((e) => (e.deviceDetails?.firstOrNull?.uuid == robotId) ? (e..pose = null) : e).toList();
        try {
          refreshPositionPainter(mapsUuid, robot: deviceList[mapsUuid]!.firstWhere((el) => el.deviceDetails?.firstOrNull?.uuid == robotId), isNotify: true);
        } catch (_) {}
      }
      // SocketController.instance.onContinuosDataReceived?.call(robotId, mapsUuid, <List<double>>[], <List<double>>[], <List<double>>[], null, null, null, null, null, null, null, null, null, null, null);
      return;
    }
    double? robotX;
    double? robotY;
    if (response['p'] != null) {
      final poseJson = response['p'];
      Pose pose = Pose.fromTimelineJson(poseJson);
      // SocketController.instance.onRobotPositionReceived?.call(robotId, mapsUuid, pose);
      selectedRobotOnMap?.pose = pose;
      // final xy = SocketController.instance.extractPoseXY(poseJson);
      // robotX = xy.$1;
      // robotY = xy.$2;
    }
    List<List<double>>? globalPath;
    var globalPathRes = response['gp'];
    if (globalPathRes != null && globalPathRes != 'null') {
      globalPath ??= [];
      try {
        List<double> globalPathUnPolished = [];
        (globalPathRes as List).forEach((element) {
          globalPathUnPolished.add(element);
        });
        // globalPath = LaserPathPolisher.instance.polish(globalPathUnPolished);

        // Remove path points that are already behind the robot (keep only the remaining forward path)
        if (robotX != null && robotY != null && (globalPath.isNotEmpty ?? false)) {
          // globalPath = SocketController.instance.trimPathBehindRobot(globalPath, robotX, robotY);
        }
      } catch (e) {}
    }
    List<List<double>>? threeDData;
    var threeDDataRes = response['3d'];
    if (threeDDataRes != null) {
      threeDData ??= [];
      (threeDDataRes as List).forEach((element) {
        threeDData?.add((element as List).map((e) => double.parse(e.toString())).toList());
      });
    }
    List<List<double>>? laserData;
    var laserDataDataRes = response['ld'];
    if (laserDataDataRes != null) {
      laserData ??= [];
      (laserDataDataRes as List).forEach((element) {
        laserData?.add((element as List).map((e) => double.parse(e.toString())).toList());
      });
    }

    ///Session Data
    SessionData? sessionData;
    var sessionDataRes = response['ssd'];
    if (sessionDataRes != null) {
      sessionData = SessionData.fromTimelineJson(sessionDataRes);
    }

    ///Sim Info
    SimEvent? simEvent;
    var simEventRes = response['sim'];
    if (simEventRes != null) {
      simEvent = SimEvent.fromJson(simEventRes);
    }

    ///Mode Data Res
    NavModeEvent? navModeEvent;
    try {
      print("response['cm']: ${response['cm']}");
      Map<String, dynamic>? modeDataRes = response['cm'];
      if (modeDataRes != null) {
        navModeEvent = NavModeEvent.fromJson(modeDataRes);
      }
    } catch (e) {}

    ///Battery Data
    Map<String, dynamic>? batteryData;
    var batteryDataRes = response['bd'];
    if (batteryDataRes != null) {
      if (batteryData is Map) {
        batteryData = batteryDataRes;
      }
    }

    ///Network Data
    ///Sensor Data
    NetworkEvent? networkEvent;
    var networkEventRes = response['ne'];
    if (networkEventRes != null) {
      networkEvent = NetworkEvent.fromTimelineJson(networkEventRes);
    }

    // if (AppConstants.constant.globalRef?.read(canvasMapController).selectedRobotUuid == robotId) {
    //   if (sessionData?.isEmergencyPressed != null) {
    //     // AppConstants.constant.globalRef?.read(canvasMapController).isEmergencyPressed = sessionData?.isEmergencyPressed ?? true;
    //     // AppConstants.constant.globalRef?.read(canvasMapController).notifyListeners();
    //   }
    // }

    ///Version Data
    VersionData? versionData;
    var versionDataRes = response['vd'];
    if (versionDataRes != null) {
      versionData = VersionData.fromTimelineJson(versionDataRes);
    }

    ///Sensor Data
    SensorData? sensorData;
    var sensorDataRes = response['snd'];
    if (sensorDataRes != null) {
      sensorData = SensorData.fromTimelineJson(sensorDataRes);
    }

    ///System Data
    SystemData? systemData;
    var systemDataRes = response['si'];
    if (systemDataRes != null) {
      systemData = SystemData.fromTimelineJson(systemDataRes);
    }

    ///Device State
    // DeviceStateEvent? deviceState;
    // var deviceStatsRes = response['ds'];
    // if (deviceStatsRes != null) {
    //   deviceState = DeviceStateEvent.fromTimelineJson(deviceStatsRes);
    // }

    ///Speed Data
    SpeedData? speedData;
    var speedDataRes = response['sd'];
    if (speedDataRes != null) {
      speedData = SpeedData.fromTimelineJson(speedDataRes);
    }

    ///Ads Data
    Map<String, dynamic>? adsDataRes = response['ad'];

    // SocketController.instance.onContinuosDataReceived?.call(
    //   robotId,
    //   mapsUuid,
    //   globalPath,
    //   threeDData,
    //   laserData,
    //   simEvent,
    //   navModeEvent,
    //   sessionData,
    //   versionData,
    //   sensorData,
    //   systemData,
    //   speedData,
    //   deviceState,
    //   networkEvent,
    //   batteryData,
    //   adsDataRes,
    // );
  }

  final List<int> bookmarks = [];



  ///import file


  Future<File?> get _pickZipFile async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    String? filePath=result?.files.firstOrNull?.path;
    if(filePath==null) return null;
    return File(filePath);
  }
  final ZipDecoder _zipDecoder=ZipDecoder();

  Future<List<ZipEntryData>?> _unZipInMemory(File zipFile) async {
    try{
      final Uint8List bytes=await zipFile.readAsBytes();
      final Archive archive = _zipDecoder.decodeBytes(bytes);
      final List<ZipEntryData> result = [];
      for (final ArchiveFile file in archive) {
        if (file.isFile) {
          result.add(
            ZipEntryData(
              file.name,
              Uint8List.fromList(file.content as List<int>),
            ),
          );
        }
      }
      return result;
    }catch(e){
      showErrorToast(msg: "Unzipping failed");
    }
  }

  String? timeLineData;
  String? timeLineDate;


  Future<void> readZipFile() async {
    File? file=await _pickZipFile;
    if(file==null) return;
    List<ZipEntryData>? list= await _unZipInMemory(file);
    if(list==null || list.isEmpty){
      //showErrorToast(msg:"File not picked");
      return ;
    }
    int jsonFileCnt=0;
    for(ZipEntryData file in list){
      String ext=p.extension(file.name);
      if(ext.contains("json")){
        jsonFileCnt++;
      }
    }
    if(jsonFileCnt!=2){
      showErrorToast(msg: "Valid json files not found");
      return;
    }

    final ZipEntryData? metaDataFile=list.firstWhereOrNull((obj)=>obj.name.endsWith("_metadata.json"));
    final ZipEntryData? compressedFile=list.firstWhereOrNull((obj)=>obj.name.endsWith("_compressed.json"));
    if(metaDataFile==null || compressedFile==null){
      showErrorToast(msg: "Json file name invlaid");
      return;
    }

    try {
      final String? timeLineData =await _parseCompressedJson(compressedFile.data);
      this.timeLineData=timeLineData;

      final Map<String, dynamic> metaData = jsonDecode(utf8.decode(metaDataFile.data));
      String? mapUuid=metaData["mapsUuid"];
      String? deviceUuid=metaData["deviceUuid"];
      if(mapUuid==null || deviceUuid==null) return;
      //String? mapUuid=metaData["mapsUuid"];
      WayPointData wayPointData=WayPointData.fromJson(metaData);
      VirtualWallResponseModel virtualWallResponseModel=VirtualWallResponseModel.fromJson(metaData);
      //DestinationData destinationData=DestinationData.fromJson(metaData["destination"]);
      MapListData mapData=MapListData.fromJson(metaData["maps"]);
      String? mapImgData=metaData["mapsImage"];
      this.timeLineDate=metaData["exportedAt"];

      this.virtualWall[mapUuid]=virtualWallResponseModel.waypoints;
      this.mapsUuid=mapUuid;
      this.waypointsList[mapUuid]=wayPointData.waypoints??[];
      Map<String,List<List<double>>>? routes=metaData["routes"];
      this.naviRoutes= {"routes":routes??{}};//TODO

      this.crtImg=mapImgData;


    } catch (e) {
      showErrorToast(msg:"JSON parse error: $e");
    }

  }
  Future<String?> _parseCompressedJson(Uint8List data) async {
    try{
      final String base64Str = utf8.decode(data);

      final Uint8List compressedBytes = base64Decode(base64Str);

      final Uint8List decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
      String str=utf8.decode(decompressedBytes);
      return str;
    }catch(e){
      showErrorToast(msg: "Timeline file formatting failed");
      return null;
    }
  }

  void showErrorToast({required String msg}){
    final BuildContext? context=globalNavigatorKey.currentContext;
    if(context==null) return;
    showToast(context: context,message: msg,isSuccess: false);
  }

}

class ZipEntryData {
  final String name;
  final Uint8List data;

  ZipEntryData(this.name, this.data);
}


const String relocateStr = 'Relocate';
const String navigationStr = 'Navigation';
const String virtualWallStr = 'Virtual Wall';
const String routeStr = 'Route';