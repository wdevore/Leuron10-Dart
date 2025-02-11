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

import 'dart:math';

import '../appstate.dart';
import '../misc/exponential_trace.dart';
import 'soma.dart';
import 'synapse.dart';

class TripletSynapse extends Synapse {
  // STDP traces. There are a total of 3 traces: 1 pre and 2 posts
  ExponentialTrace preTrace = ExponentialTrace.create(40.0, 1.0);

  /// 'Fast' = y1, toa+
  ExponentialTrace postY1Trace =
      ExponentialTrace.create(20.0, 1.0); // Tao1 < Tao2
  /// 'Slow' = y2, toaY
  ExponentialTrace postY2Trace = ExponentialTrace.create(70.0, 1.0);

  /// This provides a bit of change even if there is not spike
  /// on the synaptic input. This is random between 0.0 -> 1.0
  ///
  /// **TODO** file note about *bias* in docs
  /// Bias shifts the sigmoid function left/right.
  /// The sigmoid function maps values from double to unit space (0,1) non
  /// linearly.
  // double bias = 0.0;

  double tp = 0.0;

  // ---------------------------------------------------------
  // Detectors of presynaptic and postsynaptic events
  // Values are between (0,1)
  // ---------------------------------------------------------
  // r1T = r2T when a new pre-spike arrives.
  /// Pre: x_j time marked at the moment a synaptic spike arrive
  double r1T = 0.0;

  /// "Fast" Post. yi_1
  double o1T = 0.0;

  /// "Fast" Post previous
  double o1TP = 0.0;

  double efficacyTao = 0.0;

  TripletSynapse();

  factory TripletSynapse.create(AppState appState, Soma soma) {
    TripletSynapse ls = TripletSynapse()
      ..appState = appState
      ..soma = soma
      ..wMin = -5.0
      ..wMax = 5.0;
    // appState.synapsePresets.synapses[0].efficacyTao
    return ls;
  }

  @override
  void reset() {
    super.reset();
    // bias = rando.nextDouble();

    // Set all markers to waaaaay back in the past. This way
    // all exponentials equate to zero.
    r1T = double.negativeInfinity;
    o1TP = double.negativeInfinity;
    o1T = double.negativeInfinity;
    tp = 0.0;
    preTrace.reset();
    postY1Trace.reset();
    postY2Trace.reset();
  }

  /// Returns (E/I)PSP. [t] steps at a rate of 0.1ms.
  @override
  double integrate(double t) {
    // We only update the weight if a spike or AP event occurs.
    bool updateWeight = false;

    // There are two spikes we need to consider:
    // 1) Those arriving at a synapse
    // 2) The soma itself (AP)

    // ------------------------------------------------------------------
    // Synaptic spikes
    // ------------------------------------------------------------------
    // The output of the stream is the input to this synapse.
    int synInput = stream.output();

    // Presynaptic spike?
    if (synInput == 1) {
      // A spike has arrived on the input of this synapse.

      // Update the trace's new internal value based on the previous spike mark
      // and the current mark.
      // We need t-r1T to determine where on the current trace the spike
      // occurred. With that value we can add the surge value (i.e is 1.0) on:
      // new_surge = current_value + 1.0
      preTrace.update(t);

      // t - r1T This trace is read during an AP or sampling
      r1T = t; // New mark

      updateWeight = true;
    }

    // Triplet:
    // Note: we could move this calculation inside the 'if' statement below
    // , however, for visual perpuposes we need each time step value.
    // The new feature of the rule is that LTP is induced by a triplet effect:
    // the weight change is proportional to the value of the presynaptic trace
    // xj evaluated at the moment of a postsynaptic spike and also to the slow
    // postsynaptic trace yi2 remaining from previous postsynaptic spikes.
    // (I.E.): we read the presynaptic trace AND the Slow trace at time marked
    // by the post AP.

    // Partial Pair:
    // The update of the weight 'w' at the moment of a presynaptic spike is
    // proportional to the momentary value of the (post) fast trace yi_1.
    // Evaluated at the moment of a presynaptic spike.
    /// LTD is induced as in the standard STDP pair model, i.e. the weight
    /// change is proportional to the value of the fast postsynaptic trace yi1
    /// evaluated at the moment of a presynaptic spike. [2]
    /// LTD is induced at very low frequencies, from (0.1Hz < 20Hz)
    // NOTE: this read belongs in the soma spike if statement above, but it is
    //       here for continuous sampling.
    // Read fast-Post value
    double dwPairLTD = dependency(w) * postY1Trace.read(t - o1T);

    // ------------------------------------------------------------------
    // Soma APs
    // ------------------------------------------------------------------
    // Somatic AP?
    // ti_f- indicates that the function slow:yi_2 is to be evaluated
    // *before* it is incremented due to the postsynaptic spike at ti_f
    // NOTE: this read belongs in the soma spike if statement below, but it is
    //       here for continuous sampling.
    // Read slow-post prior
    // LTP = dep(w) * pre_expo(f) * slow_expo(f-)
    //               = w       xj(f)                    yi_2(f-)
    // !!!!!!!!!! should o1T be tp !!!!!!!##########
    double dwPairLTP = w * preTrace.read(t - o1T) * postY2Trace.read(t - o1TP);

    if (soma.output == 1) {
      // The soma has generated an AP. Note: the soma's threshold varies in
      // relation to the soma AP Rate. TODO Higher rates mean what? It is
      // supposed to influence the threshold. Higher rates may mean we raise the
      // threshold to just under the average max???

      // This is read during a presynaptic spikes and we perform update after
      // reading above.
      postY1Trace.update(t);

      // and previous Post
      postY2Trace.update(t);

      // Capture and track both time-marks
      //            pre
      //             |
      //     |-----------------|
      //    PrevPost       Current post
      //      o1TP            o1T
      o1TP = o1T; // track previous post.
      o1T = t;

      updateWeight = true;
    }

    // ------------------------------------------------------------------
    // Update weight if LTP/LTD was changed
    // ------------------------------------------------------------------
    if (updateWeight) {
      var nw = dwPairLTP - dwPairLTD;

      w += excititory ? nw : -nw;
      w = dependency(w);
    }

    // --------------------------------------------------------
    // Collect this synapse' values at this time step
    // --------------------------------------------------------
    appState.samples.collectInput(this, t); // stimulus
    appState.samples.collectWeight(this, t, w);
    appState.samples.collectPreTrace(this, t, preTrace.readDt(t));
    appState.samples.collectPostY1Trace(this, t, postY1Trace.readDt(t));
    appState.samples.collectPostY2Trace(this, t, postY2Trace.readDt(t));

    tp = t;
    return w;
  }

  double dependency(double w) {
    // Limit new 'w'. We don't want it unbounded.
    // Soft or Hard bounds
    switch (bounding) {
      case WeightBounding.hard:
        w = max(min(w, wMax), wMin);
        break;
      case WeightBounding.soft:
        // TODO Bounding: Soft
        break;
    }
    return w;
  }

  // Efficacy is based on both the spike proximity and distance from soma
  double efficacy(double dt) {
    // TODO add distance feature.
    return 1.0 - exp(-dt / efficacyTao);
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
