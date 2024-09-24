import '../model/neuron_properties.dart';

enum BitStreamType {
  noise,
  stimulus,
}

abstract class IBitStream {
  late BitStreamType btype;

  configure({int? seed, double? lambda});
  reset();
  int output();
  step();
  update(NeuronProperties model);
}
