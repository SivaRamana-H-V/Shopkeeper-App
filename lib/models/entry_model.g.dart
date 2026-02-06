// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  id: json['id'] as String,
  customerId: json['customer_id'] as String,
  customerCode: json['customer_code'] as String?,
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$EntryStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'customer_code': instance.customerCode,
  'amount': instance.amount,
  'status': _$EntryStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$EntryStatusEnumMap = {
  EntryStatus.pending: 'pending',
  EntryStatus.approved: 'approved',
  EntryStatus.disputed: 'disputed',
};
