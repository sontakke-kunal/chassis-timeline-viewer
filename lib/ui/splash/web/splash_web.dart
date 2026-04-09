import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashWeb extends ConsumerStatefulWidget {
  const SplashWeb({super.key});

  @override
  ConsumerState<SplashWeb> createState() => _SplashWebState();
}

class _SplashWebState extends ConsumerState<SplashWeb> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  /// Pick File + Call Controller
  Future<void> _pickFile() async {
    setState(() => isLoading = true);

    try {
      await ref.read(canvasMapController).readZipFile();
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => isLoading = false);
  }

  /// Build Override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              Assets.images.icSplash.path,
              fit: BoxFit.cover,
            ),
          ),

          /// Dark overlay for better contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          /// Center Content
          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// App Title
                  const Text(
                    "Chassis Timeline Viewer",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Import your TimeLine file to continue",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 25),

                  /// File Picker Box
                  GestureDetector(
                    onTap: isLoading ? null : _pickFile,
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(16),
                        dashPattern: const [6, 4],
                        strokeWidth: 1.5,
                        color: Colors.white70,
                      ),
                      // color: Colors.white70,
                      // strokeWidth: 1.5,
                      // dashPattern: const [6, 4],
                      // borderType: BorderType.RRect,
                      // radius: const Radius.circular(16),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: isLoading
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Processing...",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_file,
                                size: 40, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              "Click to pick .timeline file",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Button (alternative trigger)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _pickFile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? LoadingAnimationWidget.waveDots(
                        color: Colors.white,
                        size: 30,
                      )
                          : const Text(
                        "Select File",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}