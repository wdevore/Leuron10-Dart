import 'dart:collection';
import 'dart:math';

import 'value_sample.dart';

class SampleList {
  List<ListQueue<ValueSample>> samples = []; // Input stimulus
  // Track vertical scaling by capturing the Min and Max range
  double minV = double.infinity;
  double maxV = double.negativeInfinity;

  void init(int channelCnt, int queueDepth) {
    clear();
    for (var i = 0; i < channelCnt; i++) {
      var listQueue = ListQueue<ValueSample>(queueDepth);
      for (var i = 0; i < queueDepth; i++) {
        listQueue.add(ValueSample());
      }
      samples.add(listQueue);
    }
  }

  void reset() {
    minV = double.infinity;
    maxV = double.negativeInfinity;
    clear();
  }

  void clear() {
    samples.clear();
  }

  void add(ListQueue<ValueSample> listQueue) {
    samples.add(listQueue);
  }

  ListQueue<ValueSample> sample(int id) => samples[id];

  void addSample(double t, int id, double value) {
    minV = min(minV, value);
    maxV = max(maxV, value);

    ValueSample ss = ValueSample()
      ..id = id
      ..t = t
      ..v = value;

    ListQueue<ValueSample> smple = samples[id];

    smple
      ..removeFirst()
      ..addLast(ss);
  }
}
