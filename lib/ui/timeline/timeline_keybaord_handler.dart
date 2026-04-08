import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardKeyListenerWrapper extends StatefulWidget {
  final Widget child;

  final void Function(bool isHold)? onRightPressed;
  final void Function(bool isHold)? onLeftPressed;
  final void Function(bool isHold)? onUpPressed;
  final void Function(bool isHold)? onDownPressed;
  final void Function(bool isHold)? onSpacePressed;

  final VoidCallback? onDoubleSpacePressed;
  final VoidCallback? onCommandPlusD;

  const KeyboardKeyListenerWrapper({
    super.key,
    required this.child,
    this.onRightPressed,
    this.onLeftPressed,
    this.onUpPressed,
    this.onDownPressed,
    this.onSpacePressed,
    this.onDoubleSpacePressed,
    this.onCommandPlusD,
  });

  @override
  State<KeyboardKeyListenerWrapper> createState() => _KeyboardKeyListenerWrapperState();
}

class _KeyboardKeyListenerWrapperState extends State<KeyboardKeyListenerWrapper> {
  final FocusNode _focusNode = FocusNode();

  Timer? _holdTimer;
  LogicalKeyboardKey? _activeHoldKey;
  bool _isHoldKeyDown = false;

  DateTime? _lastSpaceTapAt;
  static const Duration _doubleSpaceWindow = Duration(milliseconds: 280);
  static const Duration _holdDelay = Duration(milliseconds: 220);
  static const Duration _repeatEvery = Duration(milliseconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _stopHold();
    _focusNode.dispose();
    super.dispose();
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _activeHoldKey = null;
    _isHoldKeyDown = false;
  }

  void _startHold(LogicalKeyboardKey key) {
    if (_activeHoldKey == key && _holdTimer != null) return;

    _stopHold();
    _activeHoldKey = key;
    _isHoldKeyDown = true;

    _holdTimer = Timer(_holdDelay, () {
      _holdTimer = Timer.periodic(_repeatEvery, (_) {
        if (!_isHoldKeyDown) return;

        if (_activeHoldKey == LogicalKeyboardKey.arrowLeft) {
          widget.onLeftPressed?.call(true);
        } else if (_activeHoldKey == LogicalKeyboardKey.arrowRight) {
          widget.onRightPressed?.call(true);
        } else if (_activeHoldKey == LogicalKeyboardKey.arrowUp) {
          widget.onUpPressed?.call(true);
        } else if (_activeHoldKey == LogicalKeyboardKey.arrowDown) {
          widget.onDownPressed?.call(true);
        } else if (_activeHoldKey == LogicalKeyboardKey.space) {
          widget.onSpacePressed?.call(true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        final key = event.logicalKey;

        // ---- STOP HOLD ----
        if (event is KeyUpEvent) {
          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowUp ||
              key == LogicalKeyboardKey.arrowDown ||
              key == LogicalKeyboardKey.space) {
            _stopHold();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        // ---- KEY DOWN ----
        if (event is KeyDownEvent) {
          // Ignore OS auto-repeat keydown events for keys we handle via our timer.
          if (_isHoldKeyDown && (_activeHoldKey == key)) {
            return KeyEventResult.handled;
          }

          // Command/Meta + D
          final isMetaPressed =
              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) || HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaRight);
          if (key == LogicalKeyboardKey.keyD && isMetaPressed) {
            widget.onCommandPlusD?.call();
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.arrowLeft) {
            widget.onLeftPressed?.call(false);
            _startHold(key);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.arrowRight) {
            widget.onRightPressed?.call(false);
            _startHold(key);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.arrowUp) {
            widget.onUpPressed?.call(false);
            _startHold(key);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.arrowDown) {
            widget.onDownPressed?.call(false);
            _startHold(key);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.space) {
            final now = DateTime.now();
            if (_lastSpaceTapAt != null && now.difference(_lastSpaceTapAt!) <= _doubleSpaceWindow) {
              widget.onDoubleSpacePressed?.call();
              _lastSpaceTapAt = null;
            } else {
              _lastSpaceTapAt = now;
            }

            widget.onSpacePressed?.call(false);
            _startHold(key);
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
