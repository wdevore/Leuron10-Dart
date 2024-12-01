import '../model/neuron_properties.dart';
import 'ibit_stream.dart';

/// A bitstream that generates spikes at a fixed frequency (i.e. a spike
/// every period).
/// A phase delay can be added to offset a stream from others.
class FrequencyStream implements IBitStream {
  int outputSpike = 0;

  int frequency = 0;
  double period = 0.0;

  /// How much delay (in milliseconds) before a first spike is generated.
  int phaseShift = 0;
  int _phaseCnt = 0;
  bool _phaseComplete = false;
  int _periodMilli = 0;
  int _periodCnt = 0;

  FrequencyStream(this.btype);

  factory FrequencyStream.create(int frequency, int phaseShift) {
    FrequencyStream ps = FrequencyStream(BitStreamType.frequency)
      ..frequency = frequency
      ..period = 1.0 / frequency
      ..phaseShift = phaseShift
      ..reset();

    ps._periodMilli = (ps.period * 1000).toInt();

    return ps;
  }

  @override
  int output() {
    return outputSpike;
  }

  @override
  reset() {
    outputSpike = 0;
    _phaseCnt = 0;
    _periodCnt = 0;
  }

  @override
  step() {
    outputSpike = 0;

    // Cause phase delay
    if (phaseShift > 0 && !_phaseComplete) {
      if (_phaseCnt >= phaseShift) {
        // Phase delay, disable it.
        _phaseComplete = true;
      }
      _phaseCnt += 1;
    } else if (_phaseComplete) {
      if (_periodCnt >= _periodMilli) {
        // Period has spanned generate a spike.
        _periodCnt = 0; // Reset for next period
        outputSpike = 1;
      } else {
        _periodCnt++;
      }
    }
  }

  @override
  update(NeuronProperties model) {}

  @override
  configure({int? seed, double? lambda}) {}

  @override
  BitStreamType btype;
}
