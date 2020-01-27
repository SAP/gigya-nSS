// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screen _$ScreenFromJson(Map<String, dynamic> json) {
  return Screen(
    json['id'] as String,
    json['stack'] as String,
    json['appBar'] as Map<String, dynamic>,
    (json['children'] as List)
        ?.map((e) =>
            e == null ? null : NSSWidget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ScreenToJson(Screen instance) => <String, dynamic>{
      'id': instance.id,
      'stack': instance.stack,
      'appBar': instance.appBar,
      'children': instance.children,
    };
