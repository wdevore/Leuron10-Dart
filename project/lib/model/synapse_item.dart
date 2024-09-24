import 'package:json_annotation/json_annotation.dart';

part 'synapse_item.g.dart';

@JsonSerializable()
class SynapseItem {
  bool excititory = false;
  double w = 0;

  SynapseItem();

  factory SynapseItem.create() {
    SynapseItem synapse = SynapseItem();
    return synapse;
  }

  factory SynapseItem.fromJson(Map<String, dynamic> json) =>
      _$SynapseItemFromJson(json);
  Map<String, dynamic> toJson() => _$SynapseItemToJson(this);
}
