import 'dart:convert';
import 'dart:io';

/// Laser/Path Polisher (Dart)
///
/// Converts: [x1,y1,x2,y2,...]  ->  [[x,y],[x,y],...]
/// with "fine polishing" using Catmull-Rom spline resampling (smooth + densified).
///
/// Great for robot route / laser-like paths before drawing on canvas.
class LaserPathPolisher {
  LaserPathPolisher._();

  static LaserPathPolisher instance = LaserPathPolisher._();

  /// Higher = smoother/denser (8–20 is a good range)
  int samplesPerSegment = 12;

  /// Optional: drop tiny jitter points.
  /// If two consecutive points are closer than this distance, the new one is skipped.
  /// Set 0.0 to disable.
  double minDistance = 0.0;

  /// Simple point struct
  static const double _half = 0.5;

  /// Main API: flat list -> polished list of [x,y] pairs
  List<List<double>> polish(List<double> flat) {
    final base = _flatToPoints(flat);
    if (base.length < 2) return const [];

    final cleaned = (minDistance > 0.0) ? _dedupeByDistance(base, minDistance) : base;
    if (cleaned.length < 4) {
      return cleaned.map((p) => [p.x, p.y]).toList(growable: false);
    }

    final smooth = _smoothPathCatmullRom(cleaned, samplesPerSegment);
    return smooth.map((p) => [p.x, p.y]).toList(growable: false);
  }

  /// If you want points output instead of List<List<double>>
  List<Pt> polishPoints(List<double> flat) {
    final base = _flatToPoints(flat);
    final cleaned = (minDistance > 0.0) ? _dedupeByDistance(base, minDistance) : base;
    if (cleaned.length < 4) return cleaned;
    return _smoothPathCatmullRom(cleaned, samplesPerSegment);
  }

  /// Unpolish while IGNORING smoothing (no target count needed).
  ///
  /// Our Catmull-Rom implementation always includes the original knot points at
  /// fixed intervals:
  /// - For each segment we add samples for t = 0..(n-1)/n
  /// - When t == 0, catmullRom(...) returns p1 exactly (an original point)
  ///
  /// Therefore, the smoothed output contains the original points at indices:
  ///   0, samplesPerSegment, 2*samplesPerSegment, ... plus the final last point.
  ///
  /// This returns a flat list [x1,y1,x2,y2,...] containing only those knot points.
  List<List<double>> unpolishPairs(List<dynamic> mainPairs) {
    List<List<double>> pairs = [];
    for (var allPoints in mainPairs) {
      List<double> pointsList = [];
      for (var points in (allPoints as List<dynamic>)) {
        pointsList.add(double.parse(double.parse(points.toString()).toStringAsFixed(2)));
      }
      pairs.add(pointsList);
    }
    return pairs;
  }

  String compressString(String input) {
    final bytes = utf8.encode(input);
    final compressed = gzip.encode(bytes);
    return base64Encode(compressed);   // store as text
  }

  String decompressString(String compressedBase64) {
    final compressed = base64Decode(compressedBase64);
    final bytes = gzip.decode(compressed);
    return utf8.decode(bytes);
  }

  // -------------------- Internals --------------------

  List<Pt> _flatToPoints(List<double> flat) {
    final pts = <Pt>[];
    for (var i = 0; i < flat.length - 1; i += 2) {
      pts.add(Pt(flat[i], flat[i + 1]));
    }
    return pts;
  }

  List<Pt> _dedupeByDistance(List<Pt> points, double minDist) {
    if (points.isEmpty) return points;

    final out = <Pt>[points.first];
    var last = points.first;

    for (var i = 1; i < points.length; i++) {
      final p = points[i];
      final dx = p.x - last.x;
      final dy = p.y - last.y;
      final d = (dx * dx + dy * dy).sqrt();
      if (d >= minDist) {
        out.add(p);
        last = p;
      }
    }
    return out;
  }

  List<Pt> _smoothPathCatmullRom(List<Pt> points, int samplesPerSegment) {
    // Pad endpoints so spline starts/ends nicely
    final padded = <Pt>[
      points.first,
      ...points,
      points.last,
    ];

    final out = <Pt>[];
    // For each segment, generate samples
    for (var i = 0; i < padded.length - 3; i++) {
      final p0 = padded[i];
      final p1 = padded[i + 1];
      final p2 = padded[i + 2];
      final p3 = padded[i + 3];

      for (var s = 0; s < samplesPerSegment; s++) {
        final t = s / samplesPerSegment;
        out.add(_catmullRom(p0, p1, p2, p3, t));
      }
    }

    // Ensure final point is exact
    out.add(points.last);
    return out;
  }

  Pt _catmullRom(Pt p0, Pt p1, Pt p2, Pt p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    final x = _half * ((2.0 * p1.x) + (-p0.x + p2.x) * t + (2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 + (-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3);

    final y = _half * ((2.0 * p1.y) + (-p0.y + p2.y) * t + (2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 + (-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3);

    return Pt(x, y);
  }
}

/// Tiny Point class like your Kotlin data class.
class Pt {
  final double x;
  final double y;

  const Pt(this.x, this.y);
}

/// Small helper: sqrt on double without importing dart:math everywhere.
extension _Sqrt on double {
  double sqrt() {
    // dart:math is fine too; this keeps it lightweight.
    // If you prefer, replace with: return math.sqrt(this);
    return (this).toNumSqrt();
  }

  double toNumSqrt() {
    // Newton-Raphson
    if (this <= 0) return 0;
    var x = this;
    var r = x;
    for (var i = 0; i < 12; i++) {
      r = 0.5 * (r + x / r);
    }
    return r;
  }
}
