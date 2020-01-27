// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screen _$ScreenFromJson(Map<String, dynamic> json) {
  return Screen(
    json['id'] as String,
    _$enumDecodeNullable(_$AlignmentEnumMap, json['stack']),
    (json['children'] as List)
        ?.map((e) =>
            e == null ? null : NSSWidget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    appBar: json['appBar'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$ScreenToJson(Screen instance) => <String, dynamic>{
      'id': instance.id,
      'stack': _$AlignmentEnumMap[instance.stack],
      'appBar': instance.appBar,
      'children': instance.children,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AlignmentEnumMap = {
  Alignment.vertical: 'vertical',
  Alignment.horizontal: 'horizontal',
};
