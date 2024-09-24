// Stimulus streams are typically streams sourced from a file
// during developement. In practice though, stimulus comes from
// actual stimulus sources such as images, INs or other neuron
//
// When patterns are emitted there is gap (aka interval) between pattern
// The Inter-Pattern-Interval (IPI) can form several ways:
// 1) Randomly with a minimum interval size.
// 2) Regularly based on a frequency (Hz). IPI is implied via the frequency.
// 3) Poisson distributed IPI.

import '../model/neuron_properties.dart';
import 'ibit_stream.dart';

class StimulusStream implements IBitStream {
  List<int> pattern = [];

  // Inter-Pattern-Interval (IPI)
  int ipi = 0;

  // How often the pattern in presented (in Hertz)
  int frequency = 0;

  // Sub duration count
  int count = 0;

  bool presentingPattern = false;
  int bitIdx = 0;

  // Example Format:
  // ....|.     <-- A pattern is just a single row
  // ...|..
  // |..|..
  // .|....
  // ....|.
  // ....|.
  // |.....
  // .....|
  // ..|...
  // .|....

  StimulusStream(this.btype);

  factory StimulusStream.create(List<int> pattern, int frequency) {
    StimulusStream ss = StimulusStream(BitStreamType.stimulus);

    int patternLength = pattern.length;
    // frequency = patterns/second or pattern/1000ms
    double milliseconds = 1000.0; // convert to milliseconds
    double period = 1.0 / frequency.toDouble();

    ss
      ..pattern = pattern
      ..frequency = frequency
      ..ipi = (period * milliseconds).round() - patternLength
      ..reset();

    return ss;
  }

  @override
  reset() {
    count = 0;
    presentingPattern = true;
    bitIdx = 0;
  }

  // Step ...
  // frequency is specified in Hz, for example if Hz = 10 then the pattern
  // is presented every 1/10 of a second or every 100m If the TimeScale
  // is 100us then presentation can be thought of as 10000u
  // The time layout is as follows:
  // |---------- 1 presentation ---------|---------- 2 presentation ---------|...
  // |----- Pattern -----|----- IPI -----|----- Pattern -----|----- IPI -----|...
  //
  // If the frequency is 10Hz (period 100ms) and the pattern length is 30ms
  // then cycle layout is as follows:
  // |30ms pattern|70ms IPI|30ms pattern|70ms IPI|30ms pattern|70ms IPI|...
  //
  // step should be called only once for the pattern and NOT for each synapse.
  @override
  step() {
    count--;

    if (presentingPattern) {
      if (count <= 0) {
        // Reset counter to IPI
        count = ipi;
        presentingPattern = false;
      } else {
        bitIdx++;
      }
    } else {
      if (count <= 0) {
        // Reset counter to Pattern
        count = pattern.length;
        // Reset pattern for next presentation
        bitIdx = 0;
        presentingPattern = true;
      }
    }
  }

  @override
  int output() {
    if (presentingPattern) {
      return pattern[bitIdx];
    }

    return 0;
  }

  // NOT-IMPLEMENTED: Update changes the stream's properties
  @override
  update(NeuronProperties model) {
    // conData, _ := mod.Data().(*model.ConfigJSON)
  }

  @override
  configure({int? seed, double? lambda}) {
    // TODO: implement configure
    throw UnimplementedError();
  }

  @override
  BitStreamType btype;
}
