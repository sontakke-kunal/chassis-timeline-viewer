import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class CommonAnimLoader extends StatelessWidget {
  final double? value;
  final double? height;

  const CommonAnimLoader({super.key, this.value, this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(Assets.anim.animLoaderBlue.keyName, height: height ?? context.height * 0.15, width: height ?? context.height * 0.15),
                if (value != null)
                  CommonText(
                    title: '${((value ?? 0) * 100).toStringAsFixed(2)}%',
                  ),
              ],
            ),
            if (value != null)
              SizedBox(
                height: context.height * 0.25,
                width: context.height * 0.25,
                child: CircularProgressIndicator(
                  value: value,
                  color: AppColors.clr009AF1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
