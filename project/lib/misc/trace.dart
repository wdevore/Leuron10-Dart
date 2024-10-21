import 'dart:math';

abstract class Trace {
  double duration = 0.0;
  double from = 0.0;
  double to = 0.0;
  double steps = 0.0;
  double decrement = 0.0;
  double value = 0.0;

  Trace();

  factory Trace.createLinear(double duration, double from, double to) {
    Trace d = LinearTrace()
      ..duration = duration
      ..from = from
      ..to = to;
    return d;
  }

  void reset(double stepSizeT);
  double update();
}

class LinearTrace extends Trace {
  @override
  void reset(double stepSizeT) {
    steps = duration / stepSizeT;
    decrement = from / steps;
    value = from;
  }

  @override
  double update() {
    var v = value;
    value -= decrement;
    value = max(value, to);
    return v;
  }
}
