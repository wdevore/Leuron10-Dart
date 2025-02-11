// The soma can spike based on incoming spikes. The spikes arrive at synapses.
// Action potential: https://www.britannica.com/science/action-potential
//
// When a spike arrives

import '../appstate.dart';
import 'dendrite.dart';

class Soma {
  late AppState appState;

  // The threshold indicates when a spike occurs. When the soma's charge
  // potential reachs the threshold a spike is generated.
  double threshold = 0.0;

  // After a spike the soma enters into a Refactory Period. For our simulation
  // that period is around 1ms or 10 steps.
  // Refactory period
  double refractoryCnt = 0.0;
  double refractoryPeriod = 3;
  bool refractoryState = false;

  // Post synaptic potential
  // This value has a decay rate measured in milliseconds
  // It is the total sum of all synaptic PSPs.
  double psp = 0.0;

  int _spike = 0;
  late Dendrite dendrite;

  Soma();

  factory Soma.create(AppState appState) {
    Soma s = Soma()
      ..dendrite = Dendrite.create(appState)
      ..appState = appState
      ..refractoryPeriod = appState.neuronProperties.refractoryPeriod
      ..threshold = appState.neuronProperties.threshold;
    return s;
  }

  void reset() {
    dendrite.reset();

    refractoryState = false;
    refractoryCnt = 0;
  }

  int get output => _spike;

  set spike(int v) => _spike = v;

  /// Returns a spike
  int integrate(double t) {
    psp = dendrite.integrate(t);

    // Soma only spikes and then drops immediately
    _spike = 0;

    if (refractoryState) {
      // this algorithm should be the same as for the synapse or at least very
      // close.
      if (refractoryCnt >= refractoryPeriod) {
        refractoryState = false;
        refractoryCnt = 0;
        // print('Refractory ended at ($t)\n');
      } else {
        refractoryCnt++;
      }
    } else {
      // The dendrite will return a value that affects the soma.
      // print('$t : $psp');
      if (psp > threshold) {
        refractoryState = true;

        // We set immediately because we are simulating a single neuron.
        _spike = 1;
      }
    }

    appState.samples.collectSomaAP(this, t);
    appState.samples.collectSomaPsp(this, t);

    return _spike;
  }
}
