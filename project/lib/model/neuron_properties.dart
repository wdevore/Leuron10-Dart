import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'neuron_properties.g.dart';

@JsonSerializable()
class NeuronProperties with ChangeNotifier {
  int synapses = 1;
  int _activeSynapse = 1;

  // If Hertz = 0 then stimulus is distributed as poisson.
  // Hertz is = cycles per second (or 1000ms per second)
  // 10Hz = 10 applied in 1000ms or every 100ms = 1000/10Hz
  // This means a stimulus is generated every 100ms which also means the
  // Inter-spike-interval (ISI) is fixed at 100ms
  int _hertz = 0;

  double _poissonPatternMax = 0;
  double _poissonPatternMin = 0;

  // Firing rate = spikes over an interval of time or
  // Poisson events per interval of time.
  // For example, spikes in a 1 sec span.

  // Poisson stream Lambda
  // The interval between bursts: IPI
  double _noiseLambda = 0;
  int _noiseCount = 0;
  int _poissonEventSpread = 0;

  double threshold = 0.0;
  double refractoryPeriod = 0.0;

  NeuronProperties();

  factory NeuronProperties.create() {
    NeuronProperties neuron = NeuronProperties();
    return neuron;
  }

  factory NeuronProperties.fromJson(Map<String, dynamic> json) =>
      _$NeuronPropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$NeuronPropertiesToJson(this);

  // ----------------------------------------------------------------
  // State management
  // ----------------------------------------------------------------
  set activeSynapse(int v) {
    _activeSynapse = v;
    notifyListeners();
  }

  int get activeSynapse => _activeSynapse;

  // -----------------------------------
  set hertz(int v) {
    _hertz = v;
    notifyListeners();
  }

  int get hertz => _hertz;

  // -----------------------------------
  set noiseLambda(double v) {
    _noiseLambda = v;
    notifyListeners();
  }

  double get noiseLambda => _noiseLambda;

  // -----------------------------------
  set noiseCount(int v) {
    _noiseCount = v;
    notifyListeners();
  }

  int get noiseCount => _noiseCount;

  // -----------------------------------
  set poissonPatternMin(double v) {
    _poissonPatternMin = v;
    notifyListeners();
  }

  double get poissonPatternMin => _poissonPatternMin;

  // -----------------------------------
  set poissonPatternMax(double v) {
    _poissonPatternMax = v;
    notifyListeners();
  }

  double get poissonPatternMax => _poissonPatternMax;

  // -----------------------------------
  set poissonEventSpread(int v) {
    _poissonEventSpread = v;
    notifyListeners();
  }

  int get poissonEventSpread => _poissonEventSpread;
}
