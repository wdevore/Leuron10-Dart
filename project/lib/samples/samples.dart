import 'dart:collection';
import 'dart:math';

import 'package:leuron10_dart/sim_components/synapse.dart';
import 'package:leuron10_dart/stimulus/ibit_stream.dart';

import '../sim_components/soma.dart';
import 'input_sample.dart';
import 'soma_sample.dart';
import 'synapse_sample.dart';

/// Captures all data generated by the simulation: Soma and Synapses.
class Samples {
  // Synaptic data. There are N synapses and each is tracked
  // with their own collection.
  // Rendering the queue is based on a sub-window of data.

  /// queue depths are controlled by app_properties.queueDepth
  int queueDepth = 1000; // default
  final int synChannelCnt = 20;
  final int noiseChannelCnt = 10;
  final int stimulusChannelCnt = 10;
  List<ListQueue<SynapseSample>> synSamples = []; // Output
  List<ListQueue<InputSample>> noiseSamples = []; // Input noise
  List<ListQueue<InputSample>> stimulusSamples = []; // Input stimulus

  List<SomaSample> somaSamples = [];

  // Track vertical scaling by capturing the Min and Max range
  double somaPspMin = 0.0;
  double somaPspMax = 0.0;

  double synapsePspMin = 0.0;
  double synapsePspMax = 0.0;
  double synapseWeightMin = 0.0;
  double synapseWeightMax = 0.0;

  Samples();

  factory Samples.create() {
    Samples sam = Samples()..reset();
    return sam;
  }

  void reset() {
    somaSamples.clear();

    synSamples.clear();
    for (var i = 0; i < synChannelCnt; i++) {
      var listQueue = ListQueue<SynapseSample>(queueDepth);
      for (var i = 0; i < queueDepth; i++) {
        listQueue.add(SynapseSample());
      }
      synSamples.add(listQueue);
    }

    noiseSamples.clear();
    for (var i = 0; i < noiseChannelCnt; i++) {
      var listQueue = ListQueue<InputSample>(queueDepth);
      for (var i = 0; i < queueDepth; i++) {
        listQueue.add(InputSample());
      }
      noiseSamples.add(listQueue);
    }

    stimulusSamples.clear();
    for (var i = 0; i < stimulusChannelCnt; i++) {
      var listQueue = ListQueue<InputSample>(queueDepth);
      for (var i = 0; i < queueDepth; i++) {
        listQueue.add(InputSample());
      }
      stimulusSamples.add(listQueue);
    }

    somaPspMin = 1000000000000.0;
    somaPspMax = -1000000000000.0;
  }

  void collectSoma(Soma soma, double t) {
    somaPspMin = min(somaPspMin, soma.psp);
    somaPspMax = max(somaPspMax, soma.psp);

    somaSamples.add(SomaSample()
      ..t = t
      ..psp = soma.psp
      ..output = soma.output);
  }

  // Collects a sample from the running synapse not
  // the persistance model
  void collectSynapse(Synapse synapse, int id, double t) {
    // Check if a channel is already in play. Create a new channel if not.
    // if (synSamples.isEmpty || synSamples[id] == null) {
    //   synSamples[id] = ListQueue(queueDepth);
    // }

    synapsePspMin = min(synapsePspMin, synapse.psp);
    synapsePspMax = max(synapsePspMax, synapse.psp);
    synapseWeightMin = min(synapseWeightMin, synapse.w);
    synapseWeightMax = max(synapseWeightMax, synapse.w);

    SynapseSample ss = SynapseSample()
      ..t = t
      ..id = synapse.id
      ..weight = synapse.w
      ..psp = synapse.psp
      // Input is either Noise or Stimulus
      ..input = synapse.stream.output();

    // The queue is of fixed size. Remove 'first' then add to 'last'.
    synSamples[id]
      ..removeFirst()
      ..addLast(ss);
  }

  void collectInput(double t, int id, IBitStream stream) {
    InputSample ss = InputSample()
      ..t = t
      ..input = stream.output();
    ListQueue<InputSample> sample;

    if (stream.btype == BitStreamType.stimulus) {
      // The queue is of fixed size. Remove 'first' then add to 'last'.
      sample = stimulusSamples[id];
    } else {
      sample = noiseSamples[id];
    }

    sample
      ..removeFirst()
      ..addLast(ss);
  }
}
