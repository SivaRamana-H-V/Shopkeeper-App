// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: json['id'] as String,
  customerCode: json['customer_code'] as String,
  shopkeeperId: json['shopkeeper_id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  totalDue: (json['total_due'] as num?)?.toDouble(),
  token: json['token'] as String?,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'customer_code': instance.customerCode,
  'shopkeeper_id': instance.shopkeeperId,
  'name': instance.name,
  'phone': instance.phone,
  'total_due': instance.totalDue,
  'token': instance.token,
};
