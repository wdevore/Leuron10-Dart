// The neuron contains the Soma.
// It constructs all the components required to Load presets, reset, import
// and export, and collect samples.

import 'dart:math';

import '../stimulus/ibit_stream.dart';

import '../appstate.dart';
import 'neuron.dart';
import 'soma.dart';
import 'linear_synapse.dart';

class LinearNeuron extends Neuron {
  LinearNeuron();

  factory LinearNeuron.create() {
    return LinearNeuron()..soma = Soma();
  }

  /// Returns a spike
  @override
  int integrate(double t) {
    return soma.integrate(t);
  }

  /// Create and copy map presets into a synapse. This does not attach
  /// any stimulus. It simply create synapes so stimulus can be attached.
  @override
  void attachPresets(Map<String, dynamic> map, AppState appState) {
    int cnt = 0; // Use only a sub set of the presets.

    soma.dendrite.minStimulusId = genSynID;

    for (var synapse in map['synapses']) {
      if (cnt > soma.dendrite.synapseCntLimit - 1) {
        break;
      }

      soma.dendrite.addStimulus(
        LinearSynapse.create(appState, soma)
          ..excititory = synapse['excititory'] as bool
          ..w = synapse['w'] as double
          ..id = genSynID,
      );
      genSynID++;

      cnt++;
    }

    soma.dendrite.maxStimulusId = genSynID;
  }

  @override
  void attachNoise(List<IBitStream> noise, AppState appState) {
    // Create synapses to attach the noise stream to.
    Random rando = Random(36131);

    soma.dendrite.minNoiseId = genSynID;

    for (var i = 0; i < soma.dendrite.noiseCntLimit; i++) {
      soma.dendrite.addNoise(
        LinearSynapse.create(appState, soma)
          ..excititory = rando.nextDouble() > 0.3
          ..w = rando.nextDouble() * 8.0
          ..id = genSynID,
      );
      genSynID++;
    }

    soma.dendrite.maxNoiseId = genSynID;

    // Now attach noise stimulus
    soma.dendrite.attachNoise(noise);
  }

  @override
  void attachStimulus(List<IBitStream> stimuli) {
    // The synapses were created previously above in 'attachPresets'.
    // This will attach stimulus streams to those synapses.
    soma.dendrite.attachStimulus(stimuli);
  }

  @override
  void step() {}
}
