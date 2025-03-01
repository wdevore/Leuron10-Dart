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
      .._phaseComplete = phaseShift == 0
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
    outputSpike = _phaseComplete ? 1 : 0;
    _phaseCnt = 0;
    _periodCnt = 0;
  }

  void changePhase(int phaseShift) {
    phaseShift = phaseShift;
    _phaseComplete = phaseShift == 0;
    reset();
  }

  void changeFrequency(int frequency) {
    frequency = frequency;
    if (frequency > 0) {
      period = 1.0 / frequency;
      _periodMilli = (period * 1000).toInt();
      reset();
    }
  }

  void setPhase(int shift) {
    phaseShift = shift;
    _phaseComplete = shift == 0;
    reset();
  }

  @override
  step() {
    outputSpike = 0;

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

  @override
  update(NeuronProperties model) {}

  @override
  configure({int? seed, double? lambda}) {}

  @override
  BitStreamType btype;
}
