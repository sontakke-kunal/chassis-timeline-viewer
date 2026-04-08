import 'package:chassis_timeline_viewer/framework/utils/web_view_ui/zoom_aware_mixin.dart';
import 'package:chassis_timeline_viewer/ui/timeline/web/timeline_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';


class Timeline extends ConsumerStatefulWidget {

  const Timeline({super.key});

  @override
  ConsumerState<Timeline> createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<Timeline> with WidgetsBindingObserver, ZoomAwareMixin {

  ///Build Override
  @override
  Widget buildPage(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) {
        return TimelineWeb();
      },
      tablet: (BuildContext context) {
        return TimelineWeb();
      },
      desktop: (BuildContext context) {
        return TimelineWeb();
      },
    );
  }
}
