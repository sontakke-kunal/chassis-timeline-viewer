import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConstants {
  AppConstants._();

  static AppConstants constant = AppConstants._();

  static String zoomBoxName = 'odigo_v3_zoom';

  static const String appName = 'Chassis timeline';

  WidgetRef? globalRef;

  // Timeline configuration
  static const double timelineHeight = 30.0;
  static const double timelineThumbSize = 20.0;
  static const double timelineTrackHeight = 4.0;

  ///Show Log
  showLog(String str) {
    debugPrint('-> $str');
  }

  static bool get isWindows => ((!kIsWeb) && Platform.isWindows);
}

///Show Log
showLog(String str) {
  if (kDebugMode) {
    debugPrint('-> $str');
  }
}
