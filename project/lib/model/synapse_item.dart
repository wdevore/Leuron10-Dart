import 'package:json_annotation/json_annotation.dart';

part 'synapse_item.g.dart';

@JsonSerializable()
class SynapseItem {
  int iD = -1;

  bool excititory = false;
  double w = 0;
  // See reference: #2
  // epsilonJ = 1 - exp(-(tJ^n - tJ^(n-1)) / toaJ)
  double efficacyTao = 0.0; // taoI

  SynapseItem();

  factory SynapseItem.create() {
    SynapseItem synapse = SynapseItem();
    return synapse;
  }

  factory SynapseItem.fromJson(Map<String, dynamic> json) =>
      _$SynapseItemFromJson(json);
  Map<String, dynamic> toJson() => _$SynapseItemToJson(this);
}
