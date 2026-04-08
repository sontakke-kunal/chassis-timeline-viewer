import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/framework/utils/web_view_ui/zoom_aware_mixin.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart';
import 'package:chassis_timeline_viewer/ui/routing/stack.dart';
import 'package:chassis_timeline_viewer/ui/splash/web/splash_web.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState<Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash>
    with WidgetsBindingObserver, ZoomAwareMixin {
  @override
  void initState() {
    super.initState();
  }

  ///Build Override
  @override
  Widget buildPage(BuildContext context) {
    return ScreenTypeLayout.builder(
      // mobile: (BuildContext context) {
      //   return const SplashMobile();
      // },
      desktop: (BuildContext context) {
        return const SplashWeb();
      },
      tablet: (BuildContext context) {
        return const SplashWeb();
      },
    );
  }
}
