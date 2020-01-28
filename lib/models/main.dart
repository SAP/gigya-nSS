import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

@JsonSerializable(anyMap: true)
class Main {
  Map<String, Screen> screens;

  Main(this.screens);

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);

  Map<String, dynamic> toJson() => _$MainToJson(this);
}
