import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'macos_window_helper.dart';

class KeyboardShortcutHandler extends StatelessWidget {
  final Widget child;

  const KeyboardShortcutHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(), // must have a focus node
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final isCommandPressed = event.isMetaPressed; // CMD key on macOS
          final key = event.logicalKey.keyLabel.toLowerCase();

          if (isCommandPressed && key == 'n') {
            MacOSWindowHelper().openNewWindow();
          }
        }
      },
      child: child,
    );
  }
}
