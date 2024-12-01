import 'sample_list.dart';

class SamplesData {
  int queueDepth = 1000; // default
  final int synChannelCnt = 20;

  SampleList weights = SampleList();
  SampleList somaAxon = SampleList();

  // Inputs
  SampleList stimulus = SampleList();
  SampleList noise = SampleList();

  // A queue for each synapse
  SampleList surge = SampleList();

  SampleList psp = SampleList();

  SampleList valueAt = SampleList();

  SampleList preTraceSamples = SampleList();
}
