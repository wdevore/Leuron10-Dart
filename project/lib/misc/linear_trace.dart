import 'dart:math';
import 'package:leuron10_dart/misc/trace.dart';

class LinearTrace extends Trace {
  double stepSizeT = 0.0;
  double duration = 0.0;
  double from = 0.0;
  double to = 0.0;
  double steps = 0.0;
  double decrement = 0.0;

  LinearTrace();

  factory LinearTrace.createLinear(double duration, double from, double to) {
    LinearTrace d = LinearTrace()
      ..duration = duration
      ..from = from
      ..to = to;
    return d;
  }

  @override
  void reset() {
    steps = duration / stepSizeT;
    decrement = from / steps;
    value = from;
  }

  double update() {
    var v = value;
    value -= decrement;
    value = max(value, to);
    return v;
  }
}
