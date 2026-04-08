import 'package:flutter/animation.dart';

extension AnimationExtension on AnimationController {
  bool get isDisposed {
    return toStringDetails().toLowerCase().contains('dispose');
  }

  TickerFuture? reverseDispose({double? from}) {
    if (!isDisposed) {
      return reverse(from: from);
    }
    return null;
  }
}

extension AnimationNullExtension on AnimationController? {
  bool get isDisposed {
    if (this == null) {
      return false;
    }
    return this!.toStringDetails().toLowerCase().contains('dispose');
  }

  TickerFuture? reverseDispose({double? from}) {
    if (this == null) {
      return null;
    }
    if (!isDisposed) {
      return this!.reverse(from: from);
    }
    return null;
  }
}
