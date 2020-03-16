import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:json_annotation/json_annotation.dart';

part 'markup.g.dart';

@JsonSerializable(anyMap: true)
class Markup {
  Map<String, Screen> screens;
  String initialRoute;
  Map<String, String> defaultRouting;

  Markup(this.screens, this.initialRoute, this.defaultRouting);

  factory Markup.fromJson(Map<String, dynamic> json) => _$MarkupFromJson(json);

  Map<String, dynamic> toJson() => _$MarkupToJson(this);
}
