import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'synapse_item.dart';

part 'synapse_presets.g.dart';

@JsonSerializable()
class SynapsePresets with ChangeNotifier {
  List<SynapseItem> synapses = [];

  SynapsePresets();

  factory SynapsePresets.create() {
    SynapsePresets synapse = SynapsePresets();
    return synapse;
  }

  factory SynapsePresets.fromJson(Map<String, dynamic> json) =>
      _$SynapsePresetsFromJson(json);
  Map<String, dynamic> toJson() => _$SynapsePresetsToJson(this);

  void update() => notifyListeners();
}
