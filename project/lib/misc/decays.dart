import 'dart:math';

class Decays {
  double duration = 0.0;
  double from = 0.0;
  double to = 0.0;
  double steps = 0.0;
  double decrement = 0.0;
  double value = 0.0;

  Decays();

  factory Decays.create(double duration, double from, double to) {
    Decays d = Decays()
      ..duration = duration
      ..from = from
      ..to = to;
    return d;
  }

  void reset(double stepSizeT) {
    steps = duration / stepSizeT;
    decrement = from / steps;
    value = from;
  }

  double update() {
    value -= decrement;
    value = max(value, to);
    return value;
  }
}
