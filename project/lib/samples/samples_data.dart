import 'sample_list.dart';

enum SamplesIndex {
  weights,
  somaAxon,
  stimulus,
  noise,
  surge,
  psp,
  valueAt,
  preTrace,
  postY2Trace,
  postY1Trace,
}

class SamplesData {
  int queueDepth = 1000; // default
  final int synChannelCnt = 20;
  final int listCnt = 10;

  SampleList somaAxon = SampleList();

  // Inputs
  SampleList stimulus = SampleList();
  SampleList noise = SampleList();

  // A queue for each synapse
  SampleList surge = SampleList();

  SampleList psp = SampleList();

  SampleList valueAt = SampleList();

  List<SampleList> lists = [];

  SamplesData() {
    for (SamplesIndex _ in SamplesIndex.values) {
      lists.add(SampleList());
    }
  }
}
