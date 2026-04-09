import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_button.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_svg.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';

void showSuccessFailureDialogue({required BuildContext context, required String message, String? description, String? buttonText, void Function()? onTap, bool isSuccess = false}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final media = MediaQuery.of(context).size;
      return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: media.width * 0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: context.height * 0.36,
              width: context.width * 0.32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF9FAFB).withAlpha((0.98 * 255).toInt()),
                    const Color(0xFFF2F4F7).withAlpha((0.95 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.black.withAlpha((0.12 * 255).toInt()),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.22 * 255).toInt()),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Consumer(
                  builder: (context, ref, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isSuccess ? AppColors.clr009AF1 : const Color(0xFFEF4444)).withAlpha((0.14 * 255).toInt()),
                                border: Border.all(
                                  color: (isSuccess ? AppColors.clr009AF1 : const Color(0xFFEF4444)).withAlpha((0.22 * 255).toInt()),
                                  width: 0.9,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                                size: 20,
                                color: (isSuccess ? AppColors.clr009AF1 : const Color(0xFFEF4444)).withAlpha((0.95 * 255).toInt()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CommonText(
                                    title: isSuccess ? 'Success' : 'Error',
                                    style: TextStyles.semiBold.copyWith(
                                      fontSize: 13,
                                      color: AppColors.black.withAlpha((0.86 * 255).toInt()),
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 1),
                                  CommonText(
                                    title: isSuccess ? 'Action completed successfully' : 'Something went wrong',
                                    style: TextStyles.regular.copyWith(
                                      fontSize: 10,
                                      color: AppColors.black.withAlpha((0.55 * 255).toInt()),
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                                  border: Border.all(
                                    color: Colors.black.withAlpha((0.08 * 255).toInt()),
                                    width: 0.9,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.black.withAlpha((0.70 * 255).toInt()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.black.withAlpha((0.10 * 255).toInt()), height: 1),
                        const SizedBox(height: 14),

                        // Animation
                        Lottie.asset(
                          isSuccess ? Assets.anim.animSuccess.path : Assets.anim.animErrorJson.path,
                          height: media.height * 0.110,
                          width: media.width * 0.110,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                        const SizedBox(height: 10),

                        // Message
                        CommonText(
                          title: message,
                          textAlign: TextAlign.center,
                          maxLines: 6,
                          style: TextStyles.semiBold.copyWith(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.black.withAlpha((0.86 * 255).toInt()),
                          ),
                        ).paddingSymmetric(horizontal: 10),

                        if ((description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          CommonText(
                            title: description!,
                            textAlign: TextAlign.center,
                            maxLines: 10,
                            style: TextStyles.regular.copyWith(
                              fontSize: 11,
                              height: 1.45,
                              color: AppColors.black.withAlpha((0.62 * 255).toInt()),
                            ),
                          ).paddingSymmetric(horizontal: 12),
                        ],

                        const Spacer(),
                        CommonButton(
                          buttonText: buttonText ?? 'Ok',
                          height: context.height * 0.043,
                          width: context.width * 0.3,
                          borderRadius: BorderRadius.circular(14),
                          backgroundColor: (isSuccess ? AppColors.clr009AF1 : const Color(0xFFEF4444)).withAlpha((0.92 * 255).toInt()),
                          buttonTextStyle: TextStyles.semiBold.copyWith(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                          onTap: onTap ?? () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

bool fileDialogShown = false;

void showFileLoadingDialog(BuildContext context, int totalLen, String timelineFilePath) {
  if (fileDialogShown) return;
  fileDialogShown = true;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final DateTime startedAt = DateTime.now();
      Timer? tickTimer;

      String fmtBytes(int b) {
        if (b < 1024) return '${b} B';
        final kb = b / 1024;
        if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
        final mb = kb / 1024;
        if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
        final gb = mb / 1024;
        return '${gb.toStringAsFixed(2)} GB';
      }

      String fmtDuration(Duration d) {
        String two(int n) => n.toString().padLeft(2, '0');
        final h = d.inHours;
        final m = d.inMinutes.remainder(60);
        final s = d.inSeconds.remainder(60);
        if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
        return '${two(m)}:${two(s)}';
      }

      Widget pill({required IconData icon, required String label, required String value, Color? tint}) {
        final c = tint ?? AppColors.black;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.withValues(alpha: 0.18), width: 0.9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: c.withValues(alpha: 0.85)),
              const SizedBox(width: 6),
              CommonText(
                title: label,
                style: TextStyles.regular.copyWith(
                  fontSize: 10,
                  color: AppColors.black.withValues(alpha: 0.55),
                ),
                maxLines: 1,
              ),
              const SizedBox(width: 6),
              CommonText(
                title: value,
                style: TextStyles.semiBold.copyWith(
                  fontSize: 11,
                  color: AppColors.black.withValues(alpha: 0.84),
                ),
                maxLines: 1,
              ),
            ],
          ),
        );
      }

      return StatefulBuilder(
        builder: (context, setState) {
          // Smoothly tick for speed/eta UI. Cancels on pop.
          tickTimer ??= Timer.periodic(const Duration(milliseconds: 1500), (_) {
            if (!context.mounted) return;
            setState(() {});
          });

          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                tickTimer?.cancel();
                tickTimer = null;
              }
            },
            child: Consumer(
              builder: (context, ref, child) {
                final canvasMapWatch = ref.watch(canvasMapController);

                // NOTE: In your flow, receivedChunks is currently being used as received bytes.
                final int receivedLen = canvasMapWatch.receivedChunks.clamp(0, totalLen);
                final double progress = (receivedLen / totalLen).clamp(0.0, 1.0);
                final String percent = (progress * 100).toStringAsFixed(1);
                final now = DateTime.now();
                final elapsed = now.difference(startedAt);
                // Stop ticking once complete (caller will close dialog)
                if (progress >= 1.0) {
                  tickTimer?.cancel();
                  tickTimer = null;
                }

                final String fileName = (timelineFilePath.isEmpty) ? 'timeline.txt' : timelineFilePath.split(Platform.pathSeparator).last;

                return Dialog(
                  backgroundColor: AppColors.transparent,
                  elevation: 0,
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: context.width * 0.08,
                    vertical: context.height * 0.08,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: min(context.width * 0.42, 540),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.width * 0.02,
                          vertical: context.height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFF9FAFB).withAlpha((0.98 * 255).toInt()),
                              const Color(0xFFF2F4F7).withAlpha((0.95 * 255).toInt()),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.black.withAlpha((0.12 * 255).toInt()),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withAlpha((0.22 * 255).toInt()),
                              blurRadius: 30,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.clr009AF1.withAlpha((0.12 * 255).toInt()),
                                    border: Border.all(color: AppColors.clr009AF1.withAlpha((0.22 * 255).toInt()), width: 1),
                                  ),
                                  child: Icon(
                                    Icons.file_download_rounded,
                                    color: AppColors.clr009AF1.withAlpha((0.95 * 255).toInt()),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: context.width * 0.01),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        title: 'Receiving timeline file',
                                        style: TextStyles.bold.copyWith(
                                          color: AppColors.black.withValues(alpha: 0.90),
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      CommonText(
                                        title: fileName,
                                        style: TextStyles.medium.copyWith(
                                          color: AppColors.black.withValues(alpha: 0.55),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      CommonText(
                                        title: progress >= 0.985 ? 'Finalizing…' : 'Transfer in progress',
                                        style: TextStyles.regular.copyWith(
                                          color: AppColors.black.withValues(alpha: 0.42),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.clr009AF1.withAlpha((0.12 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.clr009AF1.withAlpha((0.22 * 255).toInt()), width: 1),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, anim) => FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim), child: child),
                                    ),
                                    child: CommonText(
                                      key: ValueKey(percent),
                                      title: '$percent%',
                                      style: TextStyles.bold.copyWith(
                                        color: AppColors.clr009AF1.withAlpha((0.95 * 255).toInt()),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: context.height * 0.018),

                            // Progress bar (smooth)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                builder: (context, v, _) {
                                  return LinearProgressIndicator(
                                    value: v,
                                    minHeight: 8,
                                    backgroundColor: AppColors.black.withAlpha((0.10 * 255).toInt()),
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.clr009AF1.withAlpha((0.90 * 255).toInt())),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: context.height * 0.012),

                            // File size progress row
                            Row(
                              children: [
                                CommonText(
                                  title: 'Received: ${fmtBytes(receivedLen)} / ${fmtBytes(totalLen)}',
                                  style: TextStyles.medium.copyWith(
                                    color: AppColors.black.withValues(alpha: 0.65),
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                CommonText(
                                  title: 'Do not close this dialog',
                                  style: TextStyles.regular.copyWith(
                                    color: AppColors.black.withValues(alpha: 0.45),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: context.height * 0.014),

                            pill(
                              icon: Icons.schedule_rounded,
                              label: 'Elapsed',
                              value: fmtDuration(elapsed),
                            ),

                            SizedBox(height: context.height * 0.018),

                            Row(
                              children: [
                                const Spacer(),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: context.height * 0.012),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.clr009AF1.withAlpha((0.90 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.clr009AF1.withAlpha((0.22 * 255).toInt()),
                                        width: 0.9,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withAlpha((0.16 * 255).toInt()),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            value: progress,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CommonText(
                                          title: progress >= 0.985 ? 'Finalizing…' : 'Receiving…',
                                          style: TextStyles.bold.copyWith(
                                            color: AppColors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  ).then((value) => fileDialogShown = false);
}
