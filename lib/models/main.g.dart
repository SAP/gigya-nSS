// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Main _$MainFromJson(Map<String, dynamic> json) {
  return Main(
    (json['screens'] as List)
        ?.map((e) =>
            e == null ? null : Screen.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$MainToJson(Main instance) => <String, dynamic>{
      'screens': instance.screens,
    };
