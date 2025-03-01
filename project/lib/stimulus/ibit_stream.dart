import '../model/neuron_properties.dart';

enum BitStreamType {
  noise,
  stimulus,
  frequency,
  pattern,
}

abstract class IBitStream {
  late BitStreamType btype;

  void configure({int? seed, double? lambda});
  void reset();
  int output();
  void step();
  void update(NeuronProperties model);
}
