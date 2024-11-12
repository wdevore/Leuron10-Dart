import 'dart:math';

import '../appstate.dart';
import '../stimulus/ibit_stream.dart';
import 'soma.dart';

// -- Memory
// Short-term potentiation (STP) and long-term potentiation (LTP) plasticity
// are both synaptic states that affect the strength of neuronal connections.
// Long/Short term plasticity (LTP/STP).

// ----STP ----
// ranges from milliseconds to minutes.
// STP is sometimes present in the CA3-CA1 synapses in the hippocampus,
// where it traces into LTP. STP modulates the frequency response of synaptic
// transmission, while LTP preserves the fidelity.
// A temporary change in synaptic strength that lasts milliseconds to seconds.
// STP is a meta-stable state that traces exponentially and can be obscured
// by LTP. STP is involved in cognitive functions like speech recognition,
// working memory, and spatial orientation.

// ----LTP ----
// LTP ranges from 10s of minutes, hours, days or years.
// A stable change in synaptic strength that can last for hours, days, or even
// years. LTP is a cellular model of learning and memory that's generally
// related to the formation of long-term memory.

// We can either start two traceing values or
// Lerp on a line formed from two points (default):
// Point 1: (t, surge)
// Point 2: (N, 0)       where N = 5ms(Dep) or 10ms(Poten)
// Once we have a trace-line we can interpolate 'dt' on the line.

// Efficacy [2] 4.2.2 Suppression:
// They observed that in triplet protocols of the form pre-post-pre, as long as
// the intervals between the spikes were reasonably short (< 15 ms), the timing
// of the pre–post pair was a better predictor for the change in the synaptic
// strength than either the timing of the post–pre pair or of both timings
// taken together. Similarly, in post–pre–post protocols, the timing of the
// first post-pre pairing was the best predictor for the change of synaptic
// strength. On the basis of this observation, they proposed a model in which
// the synaptic weight change is not just dependent on the timing of a spike
// pair, but also on the efficacy of the spikes.

abstract class Synapse {
  Random rando = Random();
  late AppState appState;
  late Soma soma;

  int id = 0;

  // Here are some characteristics of PSPs:
  // Types: PSPs can be excitatory or inhibitory. EPSPs increase the likelihood
  // of an action potential, while IPSPs decrease it.
  // Magnitude: The magnitude of a PSP depends on the amount of neurotransmitter
  // released and the number of receptors on the membrane.
  //
  // Duration: PSPs have a transient duration of about 15–20 milliseconds.
  // trace: PSPs trace with distance and time.
  // PSPs actually decrease or increase the probability that the postsynaptic
  // cell will generate an action potential.
  // PSPs are called excitatory (or EPSPs) if they increase the likelihood of
  // a postsynaptic action potential occurring, and inhibitory (or IPSPs) if
  // they decrease this likelihood.
  double psp = 0.0;

  /// "excititory" indicates that the synapse is either
  /// IPSP (false) or EPSP (true)
  bool excititory = false;

  /// The weight is dynamically adjusted during the simulation.
  double w = 0.0; // Weight

  /// The value at time T base on 'w' and psp
  double valueAtT = 0.0;

  // The stream (aka Merger) that feeds into this synapse
  late IBitStream stream;

  /// Attach a stimulus input stream
  void attachStream(IBitStream stream) {
    this.stream = stream;
  }

  void reset() {
    psp = 0.0;
    valueAtT = 0.0;
  }

  // STDP (LTP/LTD):
  // Repeated presynaptic spike arrival a few milliseconds before postsynaptic
  // action potentials leads in many synapse types to Long-Term Potentiation
  // (LTP) of the synapses. Thus any spikes that arrive before the Neuron spikes
  // are seen as contributing to the neuron spike which means they promoted
  // Potententiation.
  // Whereas repeated spike arrival after postsynaptic spikes leads to
  // Long-Term Depression (LTD) of the same synapse. Thus any spikes arriving
  // after the neuron spike are seen as not contributing to Potentiation.
  //
  // We don't want 'w' rapidly accelerating in either direction.
  // And we also want to maintain 'w's value for extended periods of time
  // before it begins to trace, generally over a of 5-10ms, before traceing to
  // zero. The idea is that 'w' should remain at a given value before forgetting.
  //
  // Integrations goal is to determine a value to return to the soma. This value
  // can be positive (potentiation)(PO) or negative (depression)(DE).
  //
  // 'w':
  // 'w's weight is either increased or decreased. To change its value requires
  // repeated synaptic spikes within a given time window. Both the spike rate
  // and relative position to a Soma spike are used to control the weight
  // change.

  /// Returns PSP. [t] steps at a rate of 0.1ms.
  double integrate(double t);
}
