// A line equation is used to create a linear trace:
// y = mx+b
// m = slope = trace rate
// b = y intercept
// x = time
//
// When a spike arrives PSP jumps a fixed amplitude.
//
//        .
//        |\
//        | \
//        |  \
//---------   ------ 0
//|----- time ------|

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

import '../appstate.dart';
import '../misc/linear_trace.dart';
import 'soma.dart';
import 'synapse.dart';

class LinearSynapse extends Synapse {
  // Linear STDP traces
  LinearTrace potTrace = LinearTrace.createLinear(10.0, 5.0, 0.0);
  LinearTrace depTrace = LinearTrace.createLinear(5.0, 2.5, 0.0);
  LinearTrace depAPTrace = LinearTrace.createLinear(5.0, 1.5, 0.0);

  // Maths potent = Maths();
  // Maths depres = Maths();
  /// The time-mark at which a spike arrived at a synapse
  double synapseT = 0.0;

  /// Delta between soma spike time and current time.
  double dt = 0.0;

  /// The time-mark at which a spike arrived at the soma
  double somaT = 0.0;

  /// Surge is lerp(dt)
  double surgeDep = 0.0;
  double surgePot = 0.0;

  /// This provides a bit of change even if there is not spike
  /// on the synaptic input. This is random between 0.0 -> 1.0
  double bias = 0.0;
  double w = 0.0; // Weight

  /// Track weight min/max
  double wMax = 0.0;
  double wMin = 0.0;

  /// trace rate (value per 0.1ms)
  double m = 0.1;

  LinearSynapse();

  factory LinearSynapse.create(AppState appState, Soma soma) {
    LinearSynapse ls = LinearSynapse()
      ..appState = appState
      ..soma = soma;
    return ls;
  }

  @override
  void reset() {
    bias = rando.nextDouble();
    potTrace.stepSizeT = appState.properties.stepSize;
    depTrace.stepSizeT = appState.properties.stepSize;

    psp = 0.0;
    synapseT = 0.0;
    somaT = 0.0;
    wMax = 5.0;
    wMin = -5.0;
    surgeDep = 0.0;
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
  @override
  double integrate(double t) {
    bool updateWeight = false;

    // double dwLTD = 0.0;
    // double dwLTP = 0.0;

    // This is ISI and will always be positive because 't' is always greater.
    // As the ISI increases the influence on the weight decreases.
    // double dt = t - synapseT;
    double somaDt = t - somaT; // Pre/Post

    // There are two spikes we need to consider:
    // 1) Those arriving at a synapse
    // 2) The soma itself

    // The output of the stream is the input to this synapse.
    var synInput = stream.output();
    // ------------------------------------------------------------------
    // Synaptic spikes
    // ------------------------------------------------------------------
    if (synInput == 1) {
      // A spike has arrived on the input of this synapse.
      // Capture time of spike
      synapseT = t;
      dt = 0.0;
      potTrace.reset();
      depTrace.reset();

      // Bias simulates small fluctuations in the synapse's chemistry.
      // It introduces a small amount of noise.
      double r = rando.nextDouble();
      bias = r < 0.2 ? r : 0.0;

      updateWeight = true;
    }

    // ------------------------------------------------------------------
    // PSP
    // double uPot = potent.linearT(dt);
    // surgePot = potent.lerpT(uPot);
    // Map 'dt' from 0->1
    // double uDep = depres.linearT(dt);
    // surgeDep = depres.lerpT(uDep);
    // ------------------------------------------------------------------
    if (excititory) {
      surgePot = potTrace.update();
      psp = bias + surgePot;

      // Note: Dep can also occur when a synaptic spike occurs within the
      // STDP window; this window forms when the Soma generates an AP.
      if (soma.output == 1) {
        surgeDep = depAPTrace.update();
        psp += bias - surgeDep; // is inhibitory
      }
    } else {
      surgeDep = depTrace.update();
      psp = bias + surgeDep; // is inhibitory
    }

    // ------------------------------------------------------------------
    // Soma APs
    // ------------------------------------------------------------------
    if (soma.output == 1) {
      // The soma has generated an AP.
      depAPTrace.reset();

      // Capture time of spike
      somaT = t;
      // somaDt = 0.0;

      updateWeight = true;
    }

    // ------------------------------------------------------------------
    // Update weight if LTP/LTD was changed
    // The weight eventually traces to baseline but during this simulation
    // long term traces isn't implemented.
    // ------------------------------------------------------------------
    if (updateWeight) {
      // double newW = w + dwLTP - dwLTD;

      // Limit new 'w'. We don't want it unbounded.
    }

    // ------------------------------------------------------------------
    // Resultant value at 't'
    // ------------------------------------------------------------------
    // PSP is typically near or at Zero.
    valueAtT = psp * w;

    // --------------------------------------------------------
    // Collect this synapse' values at this time step
    // --------------------------------------------------------
    appState.samples.collectWeight(this, t, w);
    appState.samples.collectInput(this, t); // stimulus
    appState.samples.collectSurge(this, t);
    appState.samples.collectPsp(this, t);
    appState.samples.collectValue(this, t);

    return valueAtT;
  }
}
