import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonSVG extends StatelessWidget {
  final String strIcon;
  final ColorFilter? colorFilter;
  final double? height;
  final double? width;
  final BoxFit boxFit;
  final bool isRotate;

  const CommonSVG({Key? key, this.strIcon = '', this.height, this.width, this.boxFit = BoxFit.fill, this.colorFilter, this.isRotate = false,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: isRotate ? pi : 0,
      child: SizedBox(
        height: height,
        width: width,
        child: SvgPicture.asset(strIcon, colorFilter: colorFilter, height: height, width: width, fit: boxFit),
      ),
    );
  }
}
