import 'dart:async';
import 'package:chassis_timeline_viewer/ui/routing/delegate.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dotted_border/dotted_border.dart';



class UnzipLoadingDialog {
  static bool _isShowing = false;
  static Timer? _timer;

  static final ValueNotifier<double> progress = ValueNotifier(0);

  static Future<void> show() async {
    final BuildContext? context = globalNavigatorKey.currentContext;
    if (context == null) return;
    if (_isShowing) return;

    _isShowing = true;

    // Cancel previous timer
    _timer?.cancel();

    // Auto close after 80 sec + snackbar
    _timer = Timer(const Duration(seconds: 80), () {
      if (_isShowing) {
        close();
        _showTimeoutSnackbar(context);
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _UnzipDialogUI();
      },
    );

    _isShowing = false;
    Future.delayed(Duration(milliseconds: 500),(){
      progress.value = 0;
    });
    _timer?.cancel();
  }

  static void updateProgress(double value) {
    if(!_isShowing) return;
    progress.value = value.clamp(0, 1);
  }

  static void close() {
    final BuildContext? context = globalNavigatorKey.currentContext;
    if (context == null) return;

    if (_isShowing) {
      Navigator.of(context,).maybePop();
      _isShowing = false;
      _timer?.cancel();
    }
  }

  static void _showTimeoutSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unzipping timeout. Please try again."),
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}

class _UnzipDialogUI extends StatelessWidget {
  const _UnzipDialogUI();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(16),
                  dashPattern: const [6, 4],
                  strokeWidth: 1.5,
                  color: Colors.white70,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.blueAccent,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Extracting Files...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<double>(
                valueListenable: UnzipLoadingDialog.progress,
                builder: (context, value, _) {
                  final percent = (value * 100).toStringAsFixed(0);

                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
