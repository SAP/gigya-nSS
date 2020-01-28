import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';
@JsonSerializable(anyMap: true)

// TODO: run script for build the models - `flutter pub run build_runner build`
class Main {
  Map<String, Screen> screens;

  Main(this.screens);

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
  Map<dynamic, dynamic> toJson() => _$MainToJson(this);

}