import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'leuron_simulation.dart';
import 'model/neuron_properties.dart';
import 'model/app_properties.dart';
import 'model/synapse_presets.dart';
import 'samples/samples.dart';
import '../stimulus/ibit_stream.dart';
import '../stimulus/poisson_stream.dart';
import '../stimulus/stimulus_stream.dart';
import 'sim_components/neuron.dart';
import 'utils/io_utils.dart';

class AppState extends ChangeNotifier {
  late LeuronSimulation simulation;

  int seed = 5000;
  int seedInc = 5432;

  late Neuron neuron;

  final Samples samples = Samples.create();

  // Noise streams
  bool noiseEnabled = true;
  final List<IBitStream> noises = [];

  // ------- Stimulus --------------
  // expandedStimulus -> IBitStream -> synapse

  // Original stimulus unexpanded and only serves as a source
  // for expansion.
  bool stimulusEnabled = true;
  final List<List<int>> _stimulus = [];
  // Expanded stimulus feeds into the streams
  late List<List<int>> expandedStimulus = [];
  // Expanded stimulus feeds into the streams
  final List<IBitStream> stimuli = [];
  int stimulusStreamCnt = 0;

  late SynapsePresets synapsePresets;

  // Properties like: Duration, ranges
  late AppProperties properties;

  // Neuron model presets
  late NeuronProperties neuronProperties;

  late String dataPath;

  AppState() {
    simulation = LeuronSimulation.create(this);
  }

  factory AppState.create() => AppState();

  void update() => notifyListeners();

  void configure(String propertiesFile, String modelFile,
      String synapsePresetsFile) async {
    var filePath = p.join(Directory.current.path, propertiesFile);
    Map<String, dynamic>? map = await IoUtils.importData(filePath);
    if (map != null) {
      properties = AppProperties.fromJson(map);
    }

    // Some properties can be used immediately. This should be
    // set 'before' Samples is configured.
    samples.queueDepth = properties.queueDepth;
    samples.reset();

    filePath = p.join(Directory.current.path, modelFile);
    map = await IoUtils.importData(filePath);
    if (map != null) {
      neuronProperties = NeuronProperties.fromJson(map);
    }

    dataPath = p.join(Directory.current.path, 'data/');

    neuron = Neuron.create();

    // -----------------------------------------------------------------
    // First we create the Noise (Poisson) streams. Each stream will
    // be routed to a unique synapse. We need a collection of them so
    // we can exercise them on each simulation step.
    _buildNoise(seed);
    debugPrint("Poisson Noise streams created");

    _loadStimulus('stim_1.data');
    // Optionally expand stimulus here
    // expandStimulus(properties.stimulusScaler);
    debugPrint("Stimulus loaded created");

    _buildStimulusStreams();
    debugPrint("Streams built");

    // Load a default set of presets for synapes
    _loadSynapsePresets(synapsePresetsFile);
    debugPrint("Synapse presets loaded");

    neuron.attachNoise(noises, this);
    debugPrint("Noise attached to neuron");

    neuron.attachStimulus(stimuli);
    debugPrint("Stimulus attached to neuron");
  }

  void _buildNoise(int seed) {
    noises.clear();
    NeuronProperties np = neuronProperties;

    for (int i = 0; i < np.noiseCount; i++) {
      IBitStream noise =
          PoissonStream.create(seed, np.noiseLambda, np.poissonEventSpread);
      noises.add(noise);
      seed += seedInc;
    }
  }

  void _loadStimulus(String sourceStimulusFile) {
    final File file = File('$dataPath$sourceStimulusFile');

    List<String> lines = file.readAsLinesSync();
    // Each line is the same length
    int duration = lines[0].length;
    int stimulusScaler = properties.stimulusScaler;

    // The array size is duration + (duration * StimExpander)
    // For example, if duration is 10 and stim_scaler is 3 then
    // size of stimulus is 10 + (10*3) = 40
    // StimExpander thus becomes an expanding factor. For every bit in
    // the pattern we append StimExpander 0s.
    if (stimulusScaler == 0) {
      // Special case of 0 then duration is unchanged (i.e. reflected)
      stimulusScaler = 1;
    } else {
      duration *= stimulusScaler;
    }

    for (var pattern in lines) {
      List<int> expanded = List.filled(duration, 0);
      List<int> stim = [];

      int col = 0;
      List<String> spikes = pattern.split('');
      for (var c in spikes) {
        if (c == '|') {
          expanded[col] = 1;
          stim.add(1);
        } else {
          stim.add(0);
        }
        // Move col "past" the expanded positions.
        col += stimulusScaler.toInt();
      }

      _stimulus.add(stim);
      expandedStimulus.add(expanded);

      stimulusStreamCnt++;
    }
  }

  expandStimulus(int scaler) {
    // Reset expanded data
    expandedStimulus = [];

    // All channels are the same length, pick 0
    int duration = _stimulus[0].length * scaler;

    // Iterate each channel and expand it.
    for (var stim in _stimulus) {
      List<int> expanded = List.filled(duration, 0);
      int col = 0;
      for (var spike in stim) {
        if (spike == 1) {
          expanded[col] = 1;
        }
        // Move col "past" the expanded positions.
        col += scaler;
      }
      expandedStimulus.add(expanded);
    }
  }

  /// [presetFile] could be 'synapse_preset_1.json'
  void _loadSynapsePresets(String presetFile) {
    String synPath = '${dataPath}synapses/';

    String path = '$synPath$presetFile';

    final File file = File(path);
    String json = file.readAsStringSync();

    try {
      if (json.isNotEmpty) {
        Map<String, dynamic> map = jsonDecode(json);
        synapsePresets = SynapsePresets.fromJson(map);
        // Load presets into simulation model, but doesn't attach stimulus.
        neuron.attachPresets(map, this);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Load stimulus first
  void _buildStimulusStreams() {
    // -------- Load Stimulus Streams
    for (int i = 0; i < stimulusStreamCnt; i++) {
      List<int> stimList = expandedStimulus[i];

      StimulusStream ss =
          StimulusStream.create(stimList, neuronProperties.hertz);

      stimuli.add(ss);
    }
  }
}
