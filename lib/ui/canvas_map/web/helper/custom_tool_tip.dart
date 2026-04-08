import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/text_style.dart';
import 'package:flutter/material.dart';


class CustomToolTip extends StatelessWidget {
  final String? message;
  final InlineSpan? richMessage;

  /// When true, prefers showing below the widget.
  final bool? preferBelow;

  /// Distance from the child to the tooltip.
  final double? verticalOffset;

  /// Inner padding for tooltip bubble.
  final EdgeInsetsGeometry? padding;

  /// Outer margin for tooltip bubble.
  final EdgeInsetsGeometry? margin;

  /// Tooltip background decoration.
  final Decoration? decoration;

  /// Tooltip text style.
  final TextStyle? textStyle;

  /// Delay before showing tooltip.
  final Duration? waitDuration;

  /// How long the tooltip stays visible once shown.
  final Duration? showDuration;

  /// How tooltip is triggered (hover, tap, long press).
  final TooltipTriggerMode? triggerMode;

  final Widget child;

  const CustomToolTip({
    super.key,
    required this.child,
    this.richMessage,
    this.message,
    this.preferBelow,
    this.verticalOffset,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    this.waitDuration,
    this.showDuration,
    this.triggerMode,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration =
        decoration ??
        BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.clrFFFFFF.withValues(alpha: 0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        );

    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final effectiveMargin = margin ?? const EdgeInsets.symmetric(horizontal: 10);
    final effectiveVerticalOffset = verticalOffset ?? context.height * 0.035;

    // Use your app typography by default.
    final effectiveTextStyle =
        textStyle ??
        TextStyles.regular.copyWith(
          color: AppColors.clrFFFFFF,
          fontSize: 12,
          height: 1.25,
        );

    return Tooltip(
      message: message,
      richMessage: richMessage,
      preferBelow: preferBelow,
      verticalOffset: effectiveVerticalOffset,
      padding: effectivePadding,
      margin: effectiveMargin,
      decoration: effectiveDecoration,
      textStyle: effectiveTextStyle,
      waitDuration: waitDuration ?? const Duration(milliseconds: 350),
      showDuration: showDuration ?? const Duration(seconds: 4),
      triggerMode: triggerMode ?? TooltipTriggerMode.longPress,
      child: child,
    );
  }
}
