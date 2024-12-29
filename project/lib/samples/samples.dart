import 'sample_list.dart';
import 'samples_data.dart';
import '../sim_components/linear_synapse.dart';
import '../sim_components/soma.dart';
import '../sim_components/synapse.dart';
import '../stimulus/ibit_stream.dart';

/// Captures all data generated by the simulation: Soma and Synapses.
class Samples {
  // Synaptic data. There are N synapses and each is tracked
  // with their own collection.
  // Rendering the queue is based on a sub-window of data.

  /// queue depths are controlled by app_properties.queueDepth
  late int queueDepth; // default
  final int synChannelCnt = 20;
  final int noiseChannelCnt = 10;
  late int stimulusChannelCnt;

  SamplesData samplesData = SamplesData();

  Samples();

  factory Samples.create(int queueDepth) {
    Samples sam = Samples()..queueDepth = queueDepth;
    return sam;
  }

  void init() {
    List<SampleList> lists = samplesData.lists;
    // ----------------------------------------------------------------
    // lists[SamplesIndex.somaAxon.index]
    //   ..reset()
    //   ..init(1, queueDepth);

    samplesData.somaAxon.reset();
    samplesData.somaAxon.init(1, queueDepth);

    // ----------------------------------------------------------------
    samplesData.noise.reset();
    samplesData.noise.init(noiseChannelCnt, queueDepth);

    // ----------------------------------------------------------------
    samplesData.stimulus.reset();
    samplesData.stimulus.init(stimulusChannelCnt, queueDepth);

    // ----------------------------------------------------------------
    samplesData.surge.reset();
    samplesData.surge.init(synChannelCnt, queueDepth);

    // ----------------------------------------------------------------
    samplesData.psp.reset();
    samplesData.psp.init(synChannelCnt, queueDepth);

    // ----------------------------------------------------------------
    samplesData.valueAt.reset();
    samplesData.valueAt.init(synChannelCnt, queueDepth);

    lists[SamplesIndex.weights.index]
      ..reset()
      ..init(synChannelCnt, queueDepth);

    lists[SamplesIndex.preTrace.index]
      ..reset()
      ..init(synChannelCnt, queueDepth);
    lists[SamplesIndex.postY2Trace.index]
      ..reset()
      ..init(synChannelCnt, queueDepth);
    lists[SamplesIndex.postY1Trace.index]
      ..reset()
      ..init(synChannelCnt, queueDepth);
  }

  void collectSomaAP(Soma soma, double t) {
    samplesData.somaAxon.addSample(
      t,
      0,
      soma.output.toDouble(),
    );
  }

  // Collects a sample from the running synapse not
  // the persistance model
  void collectWeight(Synapse synapse, double t, double value) {
    samplesData.lists[SamplesIndex.weights.index].addSample(
      t,
      synapse.id,
      value,
    );
  }

  void collectInput(Synapse synapse, double t) {
    IBitStream stream = synapse.stream;

    if (stream.btype == BitStreamType.stimulus ||
        stream.btype == BitStreamType.frequency) {
      samplesData.stimulus.addSample(
        t,
        synapse.id - synapse.soma.dendrite.minStimulusId,
        stream.output().toDouble(),
      );
    } else {
      samplesData.noise.addSample(
        t,
        synapse.id - synapse.soma.dendrite.minNoiseId,
        stream.output().toDouble(),
      );
    }
  }

  void collectSurge(LinearSynapse synapse, double t) {
    samplesData.surge.addSample(
      t,
      synapse.id,
      synapse.excititory ? synapse.surgePot : synapse.surgeDep,
    );
  }

  void collectPsp(Synapse synapse, double t) {
    samplesData.psp.addSample(
      t,
      synapse.id,
      synapse.psp,
    );
  }

  void collectPreTrace(Synapse synapse, double t, double value) {
    samplesData.lists[SamplesIndex.preTrace.index].addSample(
      t,
      synapse.id,
      value,
    );
  }

  void collectPostY2Trace(Synapse synapse, double t, double value) {
    samplesData.lists[SamplesIndex.postY2Trace.index].addSample(
      t,
      synapse.id,
      value,
    );
  }

  void collectPostY1Trace(Synapse synapse, double t, double value) {
    samplesData.lists[SamplesIndex.postY1Trace.index].addSample(
      t,
      synapse.id,
      value,
    );
  }

  void collectValue(Synapse synapse, double t) {
    samplesData.valueAt.addSample(
      t,
      synapse.id,
      synapse.valueAtT,
    );
  }
}
