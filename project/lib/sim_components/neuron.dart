// The neuron contains the Soma.
// It constructs all the components required to Load presets, reset, import
// and export, and collect samples.

import '../stimulus/ibit_stream.dart';
import '../appstate.dart';
import 'soma.dart';

abstract class Neuron {
  late Soma soma;
  // Incrementing IDs
  int genSynID = 0;

  Neuron();

  /// Returns a spike
  int integrate(double t);

  /// Create and copy map presets into a synapse. This does not attach
  /// any stimulus. It simply create synapes so stimulus can be attached.
  void attachPresets(Map<String, dynamic> map, AppState appState);

  void attachNoise(List<IBitStream> noise, AppState appState) {}

  void attachStimulus(List<IBitStream> stimuli) {}

  void step() {}
}
