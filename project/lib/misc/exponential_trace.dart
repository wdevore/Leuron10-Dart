import 'dart:math';

import 'trace.dart';

// Reference:
// [1] a-triplet-spike-timing-dependent-plasticity-model-generalizes-the-bienenstock-cooper-munro-rule.pdf
//     Page 2, section [3]
// [2] Phenomenological models of synaptic plasticity based on spike timing.pdf
//
// Pair forms:
// " A2+ * exp(-dt / tao+)"
// "-A2- * exp( dt / tao-)"
// where dt = tpost - tpre
//
// Triplet form:
// "A3+ * exp(-dt1 / tao+) * exp(-dt2 / taoy)"
// where (dt1 and dt2) >= 0
//   and dt1 = tpost1 - tpre
//   and dt2 = tpost1 - tpost2

class ExponentialTrace extends Trace {
  double tao = 0.0;
  double _a = 0.0; // A+ or A- (aka surge)
  double scale = 0.0;

  ExponentialTrace();

  factory ExponentialTrace.create(double tao) {
    ExponentialTrace d = ExponentialTrace()..tao = tao;
    return d;
  }

  @override
  void reset({double stepSizeT = 0.0}) {
    scale = _a;
  }

  /// Accumulates
  void update(double dt) {
    // This is additive instead of constant.
    // As each spike arrives the scale jumps by 'A' amount.
    scale = _a * expo(dt);
  }

  double expo(double dt) {
    // TODO clamp dt to >= 0
    //
    //     ________/\_________
    //  -inf        0      +inf
    return exp(dt.abs() / tao).abs();
  }

  /// Yields a value between 0.0 and *Scale*
  /// As [dt] decreases the output moves towards *Scale*
  double read(double dt) {
    return scale * expo(dt);
  }

  set a(double v) {
    _a = v;
    scale = _a;
  }
}
