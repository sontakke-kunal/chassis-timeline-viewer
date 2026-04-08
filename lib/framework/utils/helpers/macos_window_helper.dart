import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_keys.dart';
import 'package:chassis_timeline_viewer/ui/routing/stack.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';

class MacOSWindowHelper {
  // ─────────────────────────────────────────────────────────────
  // Singleton setup
  // ─────────────────────────────────────────────────────────────
  MacOSWindowHelper._internal();

  static final MacOSWindowHelper _instance = MacOSWindowHelper._internal();

  factory MacOSWindowHelper() => _instance;

  /// Opens a new native macOS window
  Future<void> openNewWindow() async {
    _openNewWindowWithParser();
  }

  /// Opens a new native macOS window
  Future<void> openNewWindowWithRobot(List<NavigationStackItem> items, {Map additionalArguments = const {}}) async {
    _openNewMapWindow(items, additionalArguments: additionalArguments);
  }

  void _openNewWindowWithParser() async {
    // Create a new window
    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: false, arguments: jsonEncode({'location': NavigationStackKeyMapper.mapper.currentLocation})),
    );
  }

  void _openNewMapWindow(List<NavigationStackItem> items, {required Map additionalArguments}) async {
    String location = NavigationStackKeyMapper.mapper.fetchMainUrl(items);
    print(location);
    Map arguments = {'location': location};
    arguments.addAll(additionalArguments);
    print(arguments);
    /// Create a new window
    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: false, arguments: jsonEncode(arguments)),
    );
  }

  /// You can later add:
  /// - openSettingsWindow()
  /// - openAboutWindow()
  /// - closeAllWindows()
  /// - etc.
}
