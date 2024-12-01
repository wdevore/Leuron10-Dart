// The soma can spike based on incoming spikes. The spikes arrive at synapses.
// Action potential: https://www.britannica.com/science/action-potential
//
// When a spike arrives

import '../appstate.dart';
import 'dendrite.dart';

class Soma {
  // The threshold indicates when a spike occurs. When the soma's charge
  // potential reachs the threshold a spike is generated.
  double threshold = 0.0;

  // After a spike the soma enters into a Refactory Period. For our simulation
  // that period is around 1ms or 10 steps.
  // Refactory period

  // Post synaptic potential
  // This value has a decay rate measured in milliseconds
  // It is the total sum of all synaptic PSPs.
  double psp = 0.0;

  int _spike = 0;
  late Dendrite dendrite;

  Soma();

  factory Soma.create(AppState appState) {
    Soma s = Soma()..dendrite = Dendrite.create(appState);
    return s;
  }

  int get output => _spike;

  set spike(int v) => _spike = v;

  /// Returns a spike
  int integrate(double t) {
    double psp = dendrite.integrate(t);

    return 0;
  }
}
