import 'package:leuron10_dart/stimulus/ibit_stream.dart';

import 'synapse.dart';

class Dendrite {
  /// Max number of synapses from the presets
  final double synapseCntLimit = 10;
  final double noiseCntLimit = 10;

  List<Synapse> noise = [];
  List<Synapse> stimulus = [];

  void addStimulus(Synapse syn) {
    stimulus.add(syn);
  }

  void addNoise(Synapse syn) {
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

    for (Synapse synapse in stimulus) {
      double sum = synapse.integrate(t);
      psp += sum;
    }

    for (Synapse synapse in noise) {
      double sum = synapse.integrate(t);
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
