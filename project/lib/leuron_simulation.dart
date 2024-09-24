// Each step in our simulation moves time forward by 0.1ms

import 'appstate.dart';
import 'sim_components/neuron.dart';

class LeuronSimulation {
  late AppState appState;

  bool running = false;

  // How long the simulation runs in milliseconds (Not used at the moment)
  // int duration = 10;
  // When value reachs duration simulation stops.
  // int millisecondsTotal = 0;

  //  Time clocks:
  // [loopRate] controls simulation delay loop in 1ms sizes.
  int loopRate = 1; // N-ms

  /// Sub millisecond step size
  double stepRate = 0.1; // simulation clock 0.1ms = 100us
  // simTime is millisecond counts
  double simTime = 0;
  // Counts 1 millisecond
  // double oneMillisecondCnt = 0.0;

  LeuronSimulation();

  factory LeuronSimulation.create(AppState appState) {
    LeuronSimulation ls = LeuronSimulation()
      ..appState = appState
      ..configure()
      ..reset();
    return ls;
  }

  void configure() {}

  void reset() {
    simTime = 0.0;
    // millisecondsTotal = 0;
    // oneMillisecondCnt = 0.0;
  }

  void start() => running = true;

  void stop() => running = false;

  void run() async {
    Duration delayDuration = Duration(milliseconds: loopRate);

    Future.doWhile(() async {
      // Perform a single step of the simulation.
      bool durationExceeded = simulate();

      if (durationExceeded) {
        return false;
      }

      simTime += 0.1;

      // oneMillisecondCnt += 0.1;
      // if (oneMillisecondCnt > 0.9) {
      //   oneMillisecondCnt = 0.0;
      //   millisecondsTotal++;
      // }

      // Triggers display update
      appState.update();

      await Future.delayed(delayDuration);

      return running;
    });
  }

  /// Returns 'true' when duration exceeded
  bool simulate() {
    // Perform 1 integration step
    appState.neuron.integrate(simTime);

    // I originally intended a fixed duration. Instead the simulation
    // runs continously and all the graphs scroll.
    // return millisecondsTotal > duration;

    return false;
  }
}
