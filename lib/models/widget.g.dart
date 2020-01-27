// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NSSWidget _$NSSWidgetFromJson(Map<String, dynamic> json) {
  return NSSWidget(
    _$enumDecodeNullable(_$WidgetTypeEnumMap, json['type']),
    json['textKey'] as String,
    children: (json['children'] as List)
        ?.map((e) =>
            e == null ? null : NSSWidget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    stack: _$enumDecodeNullable(_$AlignmentEnumMap, json['stack']),
  );
}

Map<String, dynamic> _$NSSWidgetToJson(NSSWidget instance) => <String, dynamic>{
      'type': _$WidgetTypeEnumMap[instance.type],
      'textKey': instance.textKey,
      'stack': _$AlignmentEnumMap[instance.stack],
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

const _$WidgetTypeEnumMap = {
  WidgetType.label: 'label',
  WidgetType.input: 'input',
  WidgetType.email: 'email',
  WidgetType.password: 'password',
  WidgetType.submit: 'submit',
};

const _$AlignmentEnumMap = {
  Alignment.vertical: 'vertical',
  Alignment.horizontal: 'horizontal',
};
