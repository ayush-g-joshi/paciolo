
class TaxRegimeModel {

  TaxRegimeModel({
    required this.id,
    required this.value,
  });

  String id;
  String value;

  factory TaxRegimeModel.fromJson(Map<String, dynamic> json) => TaxRegimeModel(
    id: json["id"] == null ? null : json["id"],
    value: json["value"] == null ? null : json["value"],

  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "value": value == null ? null : value,
  };
}