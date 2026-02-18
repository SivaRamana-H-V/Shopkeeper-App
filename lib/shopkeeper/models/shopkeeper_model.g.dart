// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopkeeper_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shopkeeper _$ShopkeeperFromJson(Map<String, dynamic> json) => Shopkeeper(
  id: json['id'] as String,
  username: json['username'] as String,
  shopName: json['shop_name'] as String,
);

Map<String, dynamic> _$ShopkeeperToJson(Shopkeeper instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'shop_name': instance.shopName,
    };
