import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_properties.g.dart';

@JsonSerializable()
class AppProperties with ChangeNotifier {
  int _rangeStart = 0;
  int _rangeWidth = 0;
  int _queueDepth = 0;

  String sourceStimulus = '';
  int _stimulusScaler = 0;
  int _duration = 0;
  double _softAcceleration = 0.0;
  double _softCurve = 2; // 1.0 = linear, 2.0 = parabola
  int patternFrequency = 0;
  double _stepSize = 0.0;
  bool graphSurge = false;
  bool graphPsp = false;
  bool graphValueAt = false;

  AppProperties();

  factory AppProperties.create() {
    AppProperties config = AppProperties();
    return config;
  }

  factory AppProperties.fromJson(Map<String, dynamic> json) =>
      _$AppPropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$AppPropertiesToJson(this);

  void update() {
    notifyListeners();
  }

  // ---------------------------
  set softAcceleration(double v) {
    _softAcceleration = v;
    notifyListeners();
  }

  double get softAcceleration => _softAcceleration;

  // ---------------------------
  set softCurve(double v) {
    _softCurve = v;
    notifyListeners();
  }

  double get softCurve => _softCurve;

  // ---------------------------
  set stimulusScaler(int v) {
    _stimulusScaler = v;
    notifyListeners();
  }

  int get stimulusScaler => _stimulusScaler;

  // -----------------------------------
  set duration(int v) {
    _duration = v;
    notifyListeners();
  }

  int get duration => _duration;

  // -----------------------------------
  set rangeStart(int v) {
    _rangeStart = v;
    notifyListeners();
  }

  int get rangeStart => _rangeStart;
  // -----------------------------------
  set rangeWidth(int v) {
    _rangeWidth = v;
    notifyListeners();
  }

  int get rangeWidth => _rangeWidth;

  // -----------------------------------
  set queueDepth(int v) {
    _queueDepth = v;
    notifyListeners();
  }

  int get queueDepth => _queueDepth;

  // ---------------------------
  set stepSize(double v) {
    _stepSize = v;
  }

  double get stepSize => _stepSize;

  // // ---------------------------
  // set graphSurge(bool v) {
  //   _graphSurge = v;
  // }

  // bool get graphSurge => _graphSurge;

  // // ---------------------------
  // set graphPsp(bool v) {
  //   _graphPsp = v;
  // }

  // bool get graphPsp => _graphPsp;
}
