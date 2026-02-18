import 'package:json_annotation/json_annotation.dart';

part 'shopkeeper_model.g.dart';

@JsonSerializable()
class Shopkeeper {
  final String id;
  final String username;
  @JsonKey(name: 'shop_name')
  final String shopName;

  Shopkeeper({
    required this.id,
    required this.username,
    required this.shopName,
  });

  factory Shopkeeper.fromJson(Map<String, dynamic> json) =>
      _$ShopkeeperFromJson(json);
  Map<String, dynamic> toJson() => _$ShopkeeperToJson(this);
}
