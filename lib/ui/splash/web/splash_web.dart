import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';

class SplashWeb extends ConsumerStatefulWidget {
  const SplashWeb({super.key});

  @override
  ConsumerState<SplashWeb> createState() => _SplashWebState();
}

class _SplashWebState extends ConsumerState<SplashWeb> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  ///Build Override
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _bodyWidget());
  }

  ///Body Widget
  Widget _bodyWidget() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        Assets.images.icSplash.path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}
