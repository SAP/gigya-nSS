// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Main _$MainFromJson(Map<String, dynamic> json) {
  return Main(
    (json['screens'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Screen.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$MainToJson(Main instance) => <String, dynamic>{
      'screens': instance.screens,
    };
