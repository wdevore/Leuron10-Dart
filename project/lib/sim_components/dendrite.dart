import '../appstate.dart';
import '../stimulus/ibit_stream.dart';

import 'synapse.dart';

class Dendrite {
  /// Max number of synapses from the presets
  late int synapseCntLimit;
  final double noiseCntLimit = 10;

  List<Synapse> noise = [];
  List<Synapse> stimulus = [];

  int minNoiseId = -1;
  int maxNoiseId = -1;
  int minStimulusId = -1;
  int maxStimulusId = -1;

  Dendrite();

  factory Dendrite.create(AppState appState) {
    Dendrite d = Dendrite();
    d.synapseCntLimit = appState.properties.stimulusSynapses;
    return d;
  }
  void addStimulus(Synapse syn) {
    stimulus.add(syn);
  }

  void addNoise(Synapse syn) {
    noise.add(syn);
  }

  void reset() {
    for (Synapse s in stimulus) {
      s.reset();
    }
    for (Synapse n in noise) {
      n.reset();
    }
  }

  /// Returns 'psp'.
  double integrate(double t) {
    double psp = 0.0;
    double sum = 0.0;

    for (Synapse synapse in stimulus) {
      sum = synapse.integrate(t);
      psp += sum;
    }

    for (Synapse synapse in noise) {
      sum = synapse.integrate(t);
      psp += sum;
    }

    return psp;
  }

  /// Stimulus should be added before stimulus.
  void attachNoise(List<IBitStream> noises) {
    int index = 0;
    for (Synapse n in noise) {
      // if (index > synapseCntLimit - 1) {
      //   break;
      // }
      n.attachStream(noises[index++]);
    }
  }

  /// Stimulus should be added after noise.
  void attachStimulus(List<IBitStream> stimuli) {
    int index = 0;
    for (var synapse in stimulus) {
      if (index > synapseCntLimit - 1) {
        break;
      }
      synapse.attachStream(stimuli[index++]);
    }
  }
}
