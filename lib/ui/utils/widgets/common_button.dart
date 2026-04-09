import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_svg.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';

class CommonButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final String? leftImage;
  final double? leftImageHeight;
  final double? leftImageWidth;
  final double? leftImageHorizontalPadding;
  final Color? leftImageColor;
  final String? rightImage;
  final double? rightImageHeight;
  final double? rightImageWidth;
  final double? rightImageHorizontalPadding;
  final double? fontSize;
  final String? buttonText;
  final int? buttonMaxLine;
  final TextStyle? buttonTextStyle;
  final double? buttonHorizontalPadding;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onValidateTap;
  final TextAlign? buttonTextAlignment;
  final Color? buttonTextColor;
  final bool? isGradient;
  final bool? isPrefixEnable;
  final bool? isLoading;
  final bool isShowLoader;
  final Color? loadingAnimationColor;
  final double? loaderSize;

  const CommonButton({
    Key? key,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.leftImage,
    this.leftImageHeight,
    this.leftImageWidth,
    this.leftImageHorizontalPadding,
    this.leftImageColor,
    this.rightImage,
    this.rightImageHeight,
    this.rightImageWidth,
    this.rightImageHorizontalPadding,
    this.buttonText,
    this.buttonMaxLine,
    this.buttonTextStyle,
    this.buttonHorizontalPadding,
    this.onTap,
    this.onValidateTap,
    this.buttonTextAlignment,
    this.buttonTextColor,
    this.isGradient = true,
    this.isPrefixEnable,
    this.fontSize,
    this.isLoading,
    this.isShowLoader = true,
    this.loadingAnimationColor,
    this.loaderSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      canRequestFocus: false,
      onTap: () {
        if (!(isLoading ?? false)) {
          onTap?.call();
        } else if (!(isLoading ?? false)) {
          onValidateTap?.call();
        }
      },

      child: AbsorbPointer(
        absorbing: isLoading ?? false,
        child: Container(
          height: height ?? context.height * 0.07,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primary,
            borderRadius: borderRadius ?? BorderRadius.circular(9),
            border: Border.all(color: borderColor ?? AppColors.transparent, width: borderWidth ?? 0),
          ),
          child: isShowLoader && (isLoading ?? false)
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: loadingAnimationColor ?? AppColors.white,
                    size: loaderSize ?? 40,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: buttonHorizontalPadding ?? 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leftImage != null)
                        CommonSVG(
                          strIcon: leftImage ?? '',
                          height: leftImageHeight,
                          width: leftImageWidth,
                          colorFilter: leftImageColor != null ? ColorFilter.mode(leftImageColor!, BlendMode.srcIn) : null,
                        ).paddingOnly(right: 5),
                      Flexible(
                        child: CommonText(
                          title: buttonText ?? '',
                          style: buttonTextStyle ?? TextStyles.medium.copyWith(fontSize: fontSize ?? 14, color: buttonTextColor ?? AppColors.white),
                          maxLines: buttonMaxLine ?? 1,
                          textAlign: buttonTextAlignment ?? TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).alignAtCenter(),
        ),
      ),
    );
  }
}

/*
Widget Usage
CommonButton(
          buttonText: "Login",
          onTap: () {

          },
        )
* */
