import 'dart:ui';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/framework/utils/web_view_ui/zoom_aware.dart';
import 'package:chassis_timeline_viewer/main.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';

mixin ZoomAwareMixin<T extends ConsumerStatefulWidget> on ConsumerState<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (!AppConstants.isWindows) {
      WidgetsBinding.instance.addObserver(this);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        updateFixedSize();
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      if (!AppConstants.isWindows) {
        WidgetsBinding.instance.removeObserver(this);
      }
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) updateFixedSize();
    });
  }

  void updateFixedSize() async {
    if (!mounted) return;

    final view = View.of(context);
    final dpr = view.devicePixelRatio;
    final logicalSize = MediaQuery.sizeOf(context);

    // Logical size from the current view (already accounts for DPR)
    final newFixedWidth = logicalSize.width;
    final newFixedHeight = logicalSize.height;

    final zoom = ZoomAware.zoomAware;
    const double eps = 0.5; // update only if change > 0.5 logical px

    final currentDisplayId = view.display.id;

    // What changed?
    final pixelRatioChanged = zoom.lastDevicePixelRatio != dpr;
    final displayChanged =
        zoom.lastDisplayId != null && zoom.lastDisplayId != currentDisplayId;
    final uninitialized =
        zoom.fixedWidth == 0 ||
        zoom.fixedHeight == 0 ||
        zoom.initialDevicePixelRatio == 0;

    // Track latest display id for next comparisons
    zoom.lastDisplayId = currentDisplayId;

    // If DPR changed, display changed, or we are uninitialized, do a FULL RESET and set fresh dimensions
    if (pixelRatioChanged ||
        displayChanged ||
        uninitialized ||
        staticWindowSize) {
      await ZoomAware.zoomBox.clear();
      setState(() {
        zoom.initialDevicePixelRatio = dpr;
        zoom.lastDevicePixelRatio = dpr;
        zoom.fixedWidth = newFixedWidth;
        zoom.fixedHeight = newFixedHeight;
      });
      return;
    }

    // Otherwise, react only to size increases (never shrink on window reduce)
    final widthIncreased = (newFixedWidth - zoom.fixedWidth) > eps;
    final heightIncreased = (newFixedHeight - zoom.fixedHeight) > eps;
    if (!(widthIncreased || heightIncreased)) return;

    setState(() {
      zoom.fixedWidth = widthIncreased ? newFixedWidth : zoom.fixedWidth;
      zoom.fixedHeight = heightIncreased ? newFixedHeight : zoom.fixedHeight;
    });
  }

  /// Classes using this mixin must implement this
  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyF7F7F7,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            width: ZoomAware.zoomAware.fixedWidth,
            height: ZoomAware.zoomAware.fixedHeight,
            child: buildPage(context),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    // TODO: implement didChangeViewFocus
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    // TODO: implement didRequestAppExit
    throw UnimplementedError();
  }

  @override
  void handleCancelBackGesture() {
    // TODO: implement handleCancelBackGesture
  }

  @override
  void handleCommitBackGesture() {
    // TODO: implement handleCommitBackGesture
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    // TODO: implement handleStartBackGesture
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    // TODO: implement handleUpdateBackGestureProgress
  }
}
