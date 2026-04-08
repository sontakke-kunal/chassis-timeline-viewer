import 'package:flutter/material.dart';
import 'package:chassis_timeline_viewer/framework/utils/web_view_ui/zoom_aware.dart';
import 'package:responsive_builder/responsive_builder.dart';

extension ContextExtension on BuildContext {
  DeviceScreenType get deviceType => getDeviceType(MediaQuery.of(this).size, const ScreenBreakpoints(desktop: 600, tablet: 600, watch: 0));

  bool get isMobileScreen => deviceType == DeviceScreenType.mobile || deviceType == DeviceScreenType.tablet;

  bool get isWebScreen => deviceType == DeviceScreenType.desktop;

  void get hideKeyboard => FocusScope.of(this).unfocus();

  void get nextField => FocusScope.of(this).nextFocus();

  double get width => ZoomAware.zoomAware.fixedWidth;

  double get height => ZoomAware.zoomAware.fixedHeight;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
