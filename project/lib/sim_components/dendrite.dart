import 'package:leuron10_dart/stimulus/ibit_stream.dart';

import 'linear_synapse.dart';

class Dendrite {
  /// Max number of synapses from the presets
  final double synapseCntLimit = 10;
  final double noiseCntLimit = 10;

  List<LinearSynapse> noise = [];
  List<LinearSynapse> stimulus = [];

  int minNoiseId = -1;
  int maxNoiseId = -1;
  int minStimulusId = -1;
  int maxStimulusId = -1;

  void addStimulus(LinearSynapse syn) {
    stimulus.add(syn);
  }

  void addNoise(LinearSynapse syn) {
    noise.add(syn);
  }

  void reset() {
    for (var s in stimulus) {
      s.reset();
    }
    for (var n in noise) {
      n.reset();
    }
  }

  /// Returns 'psp'.
  double integrate(double t) {
    double psp = 0.0;
    double sum = 0.0;

    for (LinearSynapse synapse in stimulus) {
      sum = synapse.integrate(t);
      psp += sum;
    }

    for (LinearSynapse synapse in noise) {
      sum = synapse.integrate(t);
      psp += sum;
    }

    return psp;
  }

  /// Stimulus should be added before stimulus.
  void attachNoise(List<IBitStream> noises) {
    int index = 0;
    for (LinearSynapse n in noise) {
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
