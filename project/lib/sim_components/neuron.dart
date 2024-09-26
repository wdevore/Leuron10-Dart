// The neuron contains the Soma.
// It constructs all the components required to Load presets, reset, import
// and export, and collect samples.

import 'dart:math';

import 'package:leuron10_dart/stimulus/ibit_stream.dart';

import '../appstate.dart';
import 'soma.dart';
import 'synapse.dart';

class Neuron {
  late Soma soma;
  // Incrementing IDs
  int genSynID = 0;

  Neuron();

  factory Neuron.create() {
    return Neuron()..soma = Soma();
  }

  /// Returns a spike
  int integrate(double t) {
    return soma.integrate(t);
  }

  /// Create and copy map presets into a synapse. This does not attach
  /// any stimulus. It simply create synapes so stimulus can be attached.
  void attachPresets(Map<String, dynamic> map, AppState appState) {
    int cnt = 0; // Use only a sub set of the presets.
    genSynID = 0;

    for (var synapse in map['synapses']) {
      if (cnt > soma.dendrite.synapseCntLimit - 1) {
        break;
      }

      soma.dendrite.addStimulus(
        Synapse(appState, soma)
          ..excititory = synapse['excititory'] as bool
          ..w = synapse['w'] as double
          ..id = genSynID,
      );
      genSynID++;

      cnt++;
    }
  }

  void attachNoise(List<IBitStream> noise, AppState appState) {
    // Create synapses to attach the noise stream to.
    Random rando = Random(36131);
    genSynID = 0;
    for (var i = 0; i < soma.dendrite.noiseCntLimit; i++) {
      soma.dendrite.addNoise(
        Synapse(appState, soma)
          ..excititory = rando.nextDouble() > 0.3
          ..w = rando.nextDouble() * 8.0
          ..id = genSynID,
      );
      genSynID++;
    }

    // Now attach noise stimulus
    soma.dendrite.attachNoise(noise);
  }

  void attachStimulus(List<IBitStream> stimuli) {
    // The synapses were created previously above in 'attachPresets'.
    // This will attach stimulus streams to those synapses.
    soma.dendrite.attachStimulus(stimuli);
  }

  void step() {}
}
