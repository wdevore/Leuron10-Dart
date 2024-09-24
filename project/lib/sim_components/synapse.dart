// A line equation is used to create a linear decay:
// y = mx+b
// m = slope = decay rate
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
// where it decays into LTP. STP modulates the frequency response of synaptic
// transmission, while LTP preserves the fidelity.
// A temporary change in synaptic strength that lasts milliseconds to seconds.
// STP is a meta-stable state that decays exponentially and can be obscured
// by LTP. STP is involved in cognitive functions like speech recognition,
// working memory, and spatial orientation.

// ----LTP ----
// LTP ranges from 10s of minutes, hours, days or years.
// A stable change in synaptic strength that can last for hours, days, or even
// years. LTP is a cellular model of learning and memory that's generally
// related to the formation of long-term memory.

import 'dart:math';

import '../appstate.dart';
import '../misc/maths.dart';
import '../stimulus/ibit_stream.dart';
import 'soma.dart';

class Synapse {
  Random rando = Random();
  AppState appState;
  Soma soma;

  int id = 0;

  // Here are some characteristics of PSPs:
  // Types: PSPs can be excitatory or inhibitory. EPSPs increase the likelihood
  // of an action potential, while IPSPs decrease it.
  // Magnitude: The magnitude of a PSP depends on the amount of neurotransmitter
  // released and the number of receptors on the membrane.
  //
  // Duration: PSPs have a transient duration of about 15–20 milliseconds.
  // Decay: PSPs decay with distance and time.
  // PSPs actually decrease or increase the probability that the postsynaptic
  // cell will generate an action potential.
  // PSPs are called excitatory (or EPSPs) if they increase the likelihood of
  // a postsynaptic action potential occurring, and inhibitory (or IPSPs) if
  // they decrease this likelihood.
  double psp = 0.0;

  /// Linear STDP decays
  Maths potent = Maths();
  Maths depres = Maths();

  /// "excititory" indicates that the synapse is either
  /// IPSP (false) or EPSP (true)
  bool excititory = false;

  // TODO description here.
  double surge = 0.0;

  /// This provides a bit of change even if there is not spike
  /// on the synaptic input. This is random between 0.0 -> 1.0
  double bias = 0.0;
  double w = 0.0; // Weight

  /// The time-mark at which a spike arrived at a synapse
  double synapseT = 0.0;

  /// The time-mark at which a spike arrived at the soma
  double somaT = 0.0;

  /// Track weight min/max
  double wMax = 0.0;
  double wMin = 0.0;

  /// Decay rate (value per 0.1ms)
  double m = 0.1;

  /// Delta between soma spike time and current time.
  double dt = 0.0;

  Synapse(this.appState, this.soma);

  // The stream (aka Merger) that feeds into this synapse
  late IBitStream stream;

  /// Attach a stimulus input stream
  void attachStream(IBitStream stream) {
    this.stream = stream;
  }

  void reset() {
    bias = rando.nextDouble();
    psp = 0.0;
    synapseT = 0.0;
    somaT = 0.0;
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
  // before it begins to decay, generally over a of 5-10ms, before decaying to
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

  /// Returns PSP
  double integrate(double t) {
    // The value at time T base on 'w' and psp
    double valueAtT = 0.0;

    bool updateWeight = false;

    double dwLTD = 0.0;
    double dwLTP = 0.0;
    double dt = t - synapseT;

    // There are two spikes we need to consider:
    // 1) Those arriving at a synapse
    // 2) The soma itself

    // The output of the stream is the input to this synapse.
    var synInput = stream.output();
    if (synInput == 1) {
      // A spike has arrived on the input to this synapse.
      // We can either start two decaying values or
      // Lerp on a line formed from two points (default):
      // (t, surge) -> (N, 0) where N = 5ms(Dep) or 10ms(Poten)
      // Once we have a decay-line we can interpolate 'dt' on the line.

      // Capture time of spike
      // synapseT = t;

      // dt >= 0 if the spike arrived after the soma spike.
      //dt = somaT - t;
      synapseT = t;

      if (dt < 0.0) {
        surge = potent.lerpT(-dt);
      } else {
        surge = depres.lerpT(dt);
      }

      // Bias simulates small fluctuations in the synapse's chemistry.
      // It introduces a small amount of noise.
      double r = rando.nextDouble();
      bias = r < 0.2 ? r : 0.0;

      updateWeight = true;
    }

    if (excititory) {
      psp = bias + surge;
    } else {
      psp = bias - surge; // is inhibitory
    }

    if (soma.output == 1) {
      // The soma has generated an AP.

      // Capture time of spike
      somaT = t;

      updateWeight = true;
    }

    // Update weight if LTP/LTD was changed
    // The weight eventually decays to baseline but during this simulation
    // long term decays isn't implemented.
    if (updateWeight) {
      double newW = w + dwLTP - dwLTD;

      // Limit new 'w'. We don't want it unbounded.
    }

    // PSP is typically near or at Zero.
    if (excititory) {
      valueAtT = psp * w;
    } else {
      valueAtT = -psp * w; // is inhibitory
    }

    // --------------------------------------------------------
    // Collect this synapse' values at this time step
    appState.samples.collectSynapse(this, id, t);

    // collect Input stimulus
    appState.samples.collectInput(t, id, stream);

    return valueAtT;
  }
}
