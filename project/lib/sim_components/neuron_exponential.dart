// The neuron contains the Soma.
// It constructs all the components required to Load presets, reset, import
// and export, and collect samples.

import '../stimulus/ibit_stream.dart';
import '../appstate.dart';
import 'neuron.dart';
import 'soma.dart';
import 'triplet_synapse.dart';

class ExponentialNeuron extends Neuron {
  ExponentialNeuron();

  factory ExponentialNeuron.create(AppState appState) {
    return ExponentialNeuron()..soma = Soma.create(appState);
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

    // soma.dendrite.minStimulusId = genSynID;

    for (var synapse in map['synapses']) {
      if (cnt > soma.dendrite.synapseCntLimit - 1) {
        break;
      }

      soma.dendrite.addStimulus(
        TripletSynapse.create(appState, soma)
          ..excititory = synapse['excititory'] as bool
          ..w = synapse['w'] as double
          ..initialW = synapse['w'] as double
          ..id = synapse['iD'] as int, // genSynID
      );
      // genSynID++;

      cnt++;
    }

    // soma.dendrite.maxStimulusId = genSynID;

    // Find min/max Ids
    soma.dendrite.stimulus.sort((a, b) => a.id.compareTo(b.id));
    int len = soma.dendrite.stimulus.length;
    soma.dendrite.minStimulusId = soma.dendrite.stimulus[0].id;
    soma.dendrite.maxStimulusId = soma.dendrite.stimulus[len - 1].id;
  }

  void reset() {
    // TODO reset stimulus streams
    soma.reset();
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
