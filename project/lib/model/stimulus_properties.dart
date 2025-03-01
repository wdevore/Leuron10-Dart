import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stimulus_properties.g.dart';

@JsonSerializable()
class PatternProperties with ChangeNotifier {
  int period = 0;
  int iPIInterval = 0;
  int burstLength = 0;

  PatternProperties();

  factory PatternProperties.create() {
    PatternProperties pattern = PatternProperties();
    return pattern;
  }

  factory PatternProperties.fromJson(Map<String, dynamic> json) =>
      _$PatternPropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PatternPropertiesToJson(this);

  // ----------------------------------------------------------------
  // State management
  // ----------------------------------------------------------------
  // set activeSynapse(int v) {
  //   _activeSynapse = v;
  //   notifyListeners();
  // }

  // int get activeSynapse => _activeSynapse;
}

@JsonSerializable()
class StimulusProperties with ChangeNotifier {
  String lTPorlTD = '';
  int phaseShift = 0;
  PatternProperties ltp;
  PatternProperties ltd;

  StimulusProperties(this.ltp, this.ltd);

  factory StimulusProperties.create(
      PatternProperties ltp, PatternProperties ltd) {
    StimulusProperties stimulus = StimulusProperties(ltp, ltd);
    return stimulus;
  }

  factory StimulusProperties.fromJson(Map<String, dynamic> json) =>
      _$StimulusPropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$StimulusPropertiesToJson(this);

  // ----------------------------------------------------------------
  // State management
  // ----------------------------------------------------------------
  // set activeSynapse(int v) {
  //   _activeSynapse = v;
  //   notifyListeners();
  // }

  // int get activeSynapse => _activeSynapse;
}
