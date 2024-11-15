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

// Notes:
// In order to detect post-pre and post-pre-post we need to track at least two
// time marks and then rotate/shift them as new spikes arrive. For example,
// r1 is initialized to -100000000.0
// The first spike arrives and r1 = spike time.
// Second spike arrives, r2 = r1 then r1 = new spike time.
//
// Reading trace values:
// When a post spike occurs we read the current trace value from a previous
// synaptic spike.

import '../appstate.dart';
import '../misc/exponential_trace.dart';
import 'soma.dart';
import 'synapse.dart';

class TripletSynapse extends Synapse {
  // STDP traces. There are a total of 3 traces: 1 pre and 2 posts
  ExponentialTrace preTrace = ExponentialTrace.create(4.0);
  ExponentialTrace postR1Trace = ExponentialTrace.create(5.0); // Tao1 < Tao2
  ExponentialTrace postR2Trace = ExponentialTrace.create(7.0);

  /// This provides a bit of change even if there is not spike
  /// on the synaptic input. This is random between 0.0 -> 1.0
  ///
  /// **TODO** file note about *bias* in docs
  /// Bias shifts the sigmoid function left/right.
  /// The sigmoid function maps values from double to unit space (0,1) non
  /// linearly.
  double bias = 0.0;

  /// Track weight min/max
  double wMax = 0.0;
  double wMin = 0.0;

  // ---------------------------------------------------------
  // Detectors of presynaptic and postsynaptic events
  // Values are between (0,1)
  // ---------------------------------------------------------
  // r1 = r2 when a new pre-spike arrives.
  /// Pre
  double r1 = 0.0;

  /// This time mark is--by definition--older than r1
  double r2 = 0.0;

  /// "Fast" Post.
  double o1 = 0.0;

  /// "Slow" Post. This time mark is--by definition--older than o1
  double o2 = 0.0;

  TripletSynapse();

  factory TripletSynapse.create(AppState appState, Soma soma) {
    TripletSynapse ls = TripletSynapse()
      ..appState = appState
      ..soma = soma;
    return ls;
  }

  @override
  void reset() {
    super.reset();
    bias = rando.nextDouble();
    wMax = 5.0;
    wMin = -5.0;
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
  // Integration's goal is to determine a value to return to the soma. This value
  // can be positive (potentiation)(PO) or negative (depression)(DE).
  //
  // 'w':
  // 'w's weight is either increased or decreased. To change its value requires
  // repeated synaptic spikes within a given time window. Both the spike rate
  // and relative position to a Soma spike are used to control the weight
  // change.

  /// Returns (E/I)PSP. [t] steps at a rate of 0.1ms.
  @override
  double integrate(double t) {
    bool updateWeight = false;

    double dwLTD = 0.0;
    double dt = 0.0;

    // There are two spikes we need to consider:
    // 1) Those arriving at a synapse
    // 2) The soma itself (AP)

    // ------------------------------------------------------------------
    // Synaptic spikes
    // ------------------------------------------------------------------
    // The output of the stream is the input to this synapse.
    var synInput = stream.output();
    if (synInput == 1) {
      // A spike has arrived on the input of this synapse.
      // Capture and track both time-marks
      r1 = r2; // Preserve previous time
      r2 = t; // Pre

      // The update of the weight 'w' at the moment of a presynaptic spike is
      // proportional to the momentary value of the (post) fast trace yi_1.
      // post - pre;
      dt = o1 - t;
      preTrace.update();

      updateWeight = true;
    }

    dwLTD = preTrace.trace(dt);

    // ------------------------------------------------------------------
    // Soma APs
    // ------------------------------------------------------------------
    if (soma.output == 1) {
      // The soma has generated an AP.
      // depAPTrace.reset();

      // Capture and track both time-marks
      o1 = o2; // Preserve previous time
      o2 = t;

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
    // appState.samples.collectSynapse(this, t);
    // appState.samples.collectInput(this, t); // stimulus
    // appState.samples.collectSurge(this, t);
    // appState.samples.collectPsp(this, t);
    // appState.samples.collectValue(this, t);

    return valueAtT;
  }
}

      // Bias simulates small fluctuations in the synapse's chemistry.
      // It introduces a small amount of noise.
      // double r = rando.nextDouble();
      // bias = r < 0.2 ? r : 0.0;

    // ------------------------------------------------------------------
    // PSP
    // ------------------------------------------------------------------
    // if (excititory) {
    //   // Update traces
    //   surgePot = potTrace.update(0.0);
    //   psp = bias + surgePot;

    //   // Note: Dep can also occur when a synaptic spike occurs within the
    //   // STDP window; this window forms when the Soma generates an AP.
    //   if (soma.output == 1) {
    //     surgeDep = depAPTrace.update(0.0);
    //     psp += bias - surgeDep; // is inhibitory
    //   }
    // } else {
    //   surgeDep = depTrace.update(0.0);
    //   psp = bias + surgeDep; // is inhibitory
    // }
