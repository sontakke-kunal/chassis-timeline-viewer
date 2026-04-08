import 'dart:convert';
import 'dart:io';

import 'package:chassis_timeline_viewer/framework/dependency_injection/inject.dart';
import 'package:chassis_timeline_viewer/framework/utils/helpers/keyboard_shortcut_helper.dart';
import 'package:chassis_timeline_viewer/ui/routing/delegate.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_keys.dart';
import 'package:chassis_timeline_viewer/ui/routing/parser.dart';
import 'package:chassis_timeline_viewer/ui/routing/stack.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:chassis_timeline_viewer/ui/utils/restart_widget.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/no_thumb_scroll_indicator.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

bool staticWindowSize = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.zoomBoxName);
  await EasyLocalization.ensureInitialized();
  await configureMainDependencies(environment: Env.development);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  setPathUrlStrategy();
  String initialLocation = '';
  if (Platform.isMacOS) {
    // For each window/engine, read its arguments string
    final windowController = await WindowController.fromCurrentEngine();
    final arg = windowController.arguments;
    if (arg.isNotEmpty) {
      initialLocation = jsonDecode(arg)['location'];
      staticWindowSize = jsonDecode(arg)['staticWindowSize'] ?? false;
    }
    // Initialize window_manager
    await windowManager.ensureInitialized();
    // Wait until window is ready, then maximize instead of fullscreen
    if (!staticWindowSize) {
      await windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
        await windowManager.maximize();
        await windowManager.show();
        await windowManager.focus();
      });
    } else {
      await windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
        await windowManager.setSize(Size(500, 300));
        await windowManager.setAlignment(Alignment.bottomLeft, animate: true);
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    RestartApp(
      child: ProviderScope(
        child: EasyLocalization(
          supportedLocales: const <Locale>[Locale('en')],
          useOnlyLangCode: true,
          path: 'assets/lang',
          child: MyApp(initialLocation: initialLocation),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    // WebHelper.setDefaultFavicon();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      AppConstants.constant.globalRef = ref;
      NavigationStackKeyMapper.mapper.currentLocation = widget.initialLocation;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutHandler(
      child: DisplayMetricsWidget(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: ThemeData(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          supportedLocales: EasyLocalization.of(context)!.supportedLocales,
          scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
          localizationsDelegates: context.localizationDelegates,
          locale: EasyLocalization.of(context)!.locale,
          routerDelegate: getIt<MainRouterDelegate>(
            param1: ref.read(navigationStackController),
          ),
          routeInformationParser: getIt<MainRouterInformationParser>(
            param1: ref,
            param2: context,
          ),
        ),
      ),
    );
  }
}
