import 'dart:math';

class Maths {
  double minM = 0.0;
  double maxM = 0.0;

  /// [t] is between 0 -> 1
  double lerpT(double t) {
    return minM * (1.0 - t) + maxM * t;
  }

  /// Map [t] to 0->1 range based on min/max
  double linearT(double t) {
    if (minM == maxM) return t;

    if (maxM < minM) {
      double tmp = maxM;
      maxM = minM;
      minM = tmp;
    }

    if (minM < 0.0) {
      return 1.0 - (t - maxM) / (minM - maxM);
    }

    return (t - minM) / (maxM - minM);
  }

  /// Lerp returns a the value between min and max given t = 0->1
  /// Typically used in conjunction with random generators
  static double lerp(double min, double max, double t) {
    return min * (1.0 - t) + max * t;
  }

  // Linear returns 0->1 for a "value" between min and max.
  // Generally used to map from view-space to unit-space
  static double linear(double min, double max, double value) {
    if (min == max) return value;

    if (max < min) {
      double tmp = max;
      max = min;
      min = tmp;
    }

    if (min < 0.0) {
      return 1.0 - (value - max) / (min - max);
    }

    return (value - min) / (max - min);
  }

  // MapSampleToUnit from sample-space to unit-space where unit-space is 0->1
  static double mapSampleToUnit(double v, double min, double max) {
    return linear(min, max, v);
  }

  // MapUnitToWindow from unit-space to window-space
  static double mapUnitToWindow(double v, double min, double max) {
    return lerp(min, max, v);
  }

  // MapWindowToLocal = graph-space
  static (double, double) mapWindowToLocal(
      double x, double y, double offsetX, double offsetY) {
    return (offsetX + x, offsetY + y);
  }

  static (int, int) calcRange(int queueDepth, int rangeWidth, int rangeStart) {
    final int rangeStartHalt = queueDepth - rangeWidth;

    rangeStart = min(rangeStartHalt, rangeStart);

    int rangeEnd = rangeStart + rangeWidth;
    // The end can't exceed queueDepth
    rangeEnd = min(rangeEnd, queueDepth);

    return (rangeStart, rangeEnd);
  }
}
