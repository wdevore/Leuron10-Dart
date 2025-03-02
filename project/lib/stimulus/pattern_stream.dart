import 'package:leuron10_dart/model/neuron_properties.dart';

import 'ibit_stream.dart';

/// A [PatternStream] generates a burst of spikes. Each burst is has a length
/// controlled by a count.
class PatternStream implements IBitStream {
  int outputSpike = 0;

  int frequency = 0;

  int phaseShift = 0;
  int _phaseCnt = 0;
  bool _phaseComplete = false;

  double period = 0.0;
  int _periodMilli = 0;
  int _periodCnt = 0;

  // Once the spike count exceeds the Burst length spikes are paused until the
  // IPI interval expires, then the next burst begins.
  bool _bursting = false;
  int burstCnt = 0;
  int burstLength = 0; // # of spikes in a burst

  @override
  BitStreamType btype;

  PatternStream(this.btype);

  factory PatternStream.create(int frequency, int phaseShift) {
    PatternStream ps = PatternStream(BitStreamType.pattern)
      ..frequency = frequency
      ..period = 1.0 / frequency
      ..phaseShift = phaseShift
      .._phaseComplete = phaseShift == 0
      ..reset();

    ps._periodMilli = (ps.period * 1000).toInt();

    return ps;
  }

  @override
  void configure({int? seed, double? lambda}) {
    // TODO: implement configure
  }

  @override
  int output() => outputSpike;

  @override
  void reset() {
    outputSpike = _phaseComplete ? 1 : 0;
    _phaseCnt = 0;
    _periodCnt = 0;
  }

  @override
  void step() {
    outputSpike = 0;

    // Spikes are generated during the burst phase.
    if (_bursting) {
    } else {
      // Cause phase delay
      if (!_phaseComplete) {
        if (_phaseCnt >= phaseShift) {
          // Phase shift completed, disable it.
          _phaseComplete = true;
          outputSpike = 1;
        } else {
          _phaseCnt += 1;
        }
      } else {
        if (_periodCnt >= _periodMilli) {
          // Period has spanned generate a spike.
          _periodCnt = 0; // Reset for next period
          outputSpike = 1;
        } else {
          _periodCnt++;
        }
      }
    }
  }

  @override
  void update(NeuronProperties model) {
    // TODO: implement update
  }
}
