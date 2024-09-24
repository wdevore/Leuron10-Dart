// The neuron contains the Soma.
// It constructs all the components required to Load presets, reset, import
// and export, and collect samples.

import 'package:leuron10_dart/stimulus/ibit_stream.dart';

import '../appstate.dart';
import 'soma.dart';
import 'synapse.dart';

class Neuron {
  late Soma soma;

  Neuron();

  factory Neuron.create() {
    return Neuron()..soma = Soma();
  }

  /// Returns a spike
  int integrate(double t) {
    return soma.integrate(t);
  }

  void loadPresets(Map<String, dynamic> map, AppState appState) {
    int cnt = 0; // Use only a sub set of the presets.
    for (var synapse in map['synapses']) {
      if (cnt > soma.dendrite.synapseCntLimit - 1) {
        break;
      }
      soma.dendrite.addStimulus(
        Synapse(appState, soma)
          ..excititory = synapse['excititory'] as bool
          ..w = synapse['w'] as double,
      );

      cnt++;
    }
  }

  void attachNoise(List<IBitStream> noise) {
    soma.dendrite.attachNoise(noise);
  }

  void attachStimulus(List<IBitStream> stimuli) {
    soma.dendrite.attachStimulus(stimuli);
  }
}
