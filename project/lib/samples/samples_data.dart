import 'dart:collection';

import 'input_sample.dart';
import 'sample_list.dart';
import 'synapse_sample.dart';

class SamplesData {
  int queueDepth = 1000; // default
  final int synChannelCnt = 20;

  List<ListQueue<SynapseSample>> synSamples = []; // Output
  List<ListQueue<InputSample>> noiseSamples = []; // Input noise
  List<ListQueue<InputSample>> stimulusSamples = []; // Input stimulus

  SampleList somaAxon = SampleList();
  // List<SomaSample> somaSamples = [];

  // A queue for each synapse
  SampleList surge = SampleList();

  SampleList psp = SampleList();

  SampleList valueAt = SampleList();

  SampleList preTraceSamples = SampleList();

  void init() {
    // surge.init(synChannelCnt, queueDepth);
    // psp.init(synChannelCnt, queueDepth);
    // valueAt.init(synChannelCnt, queueDepth);
    preTraceSamples.init(synChannelCnt, queueDepth);
  }
}
