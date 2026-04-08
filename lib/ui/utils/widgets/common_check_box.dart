import 'package:flutter/material.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_svg.dart';

class CommonCheckBox extends StatelessWidget {
  final bool checkValue;

  /// On changed switch value
  final Function(bool?) onChanged;
  final Color? checkColor;
  final Color? activeColor;
  final Color? borderSideColor;
  final double? borderRadius;
  final double? checkBoxSize;
  final VisualDensity? visualDensity;
  final bool? isDisable;

  const CommonCheckBox({
    super.key,
    required this.checkValue,
    required this.onChanged,
    this.checkColor,
    this.activeColor,
    this.borderSideColor,
    this.borderRadius,
    this.checkBoxSize,
    this.visualDensity,
    this.isDisable,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: checkBoxSize ?? 1.05,
      child: AbsorbPointer(
        absorbing: isDisable ?? false,
        child: InkWell(
          onTap: () {
            onChanged.call(!checkValue);
          },
          child: Opacity(
            opacity: isDisable ?? false ? 0.5 : 1,
            child: CommonSVG(
              strIcon: checkValue ? Assets.svgs.svgFilledCheckbox.path : Assets.svgs.svgEmptyCheckbox.path,
            ),
          ),
        ),
      ),
    );
  }
}
