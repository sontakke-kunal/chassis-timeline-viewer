import 'dart:async';

import 'package:chassis_timeline_viewer/ui/utils/anim/animation_extension.dart';
import 'package:flutter/material.dart';

class SlideRightTransition extends StatefulWidget {
  final Widget child;
  final int? delay;
  final int? duration;
  final Offset? offset;
  final Function(AnimationController animationController)? onAnimationCreated;
  final Function()? onAnimationDisposed;

  const SlideRightTransition({super.key, required this.child, this.delay, this.duration, this.onAnimationCreated, this.offset, this.onAnimationDisposed});

  @override
  State<SlideRightTransition> createState() => _SlideRightTransitionState();
}

class _SlideRightTransitionState extends State<SlideRightTransition> with TickerProviderStateMixin {
  AnimationController? _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration ?? 300));
    if (_animController != null) {
      widget.onAnimationCreated?.call(_animController!);
      final curve = CurvedAnimation(curve: Curves.decelerate, parent: _animController ?? AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration ?? 300)));
      _animOffset = Tween<Offset>(begin: widget.offset ?? const Offset(-0.45, 0.0), end: Offset.zero).animate(curve);
      if (mounted) {
        Future.delayed(Duration(milliseconds: widget.delay ?? 100), () {
          if (!(_animController?.isDisposed ?? false)) {
            _animController?.forward().orCancel;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _animController == null;
    widget.onAnimationDisposed?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _animController != null
        ? FadeTransition(
            opacity: _animController!,
            child: SlideTransition(
              position: _animOffset,
              child: widget.child,
            ),
          )
        : const Offstage();
  }
}
