import 'package:json_annotation/json_annotation.dart';

part 'appbar.g.dart';

@JsonSerializable(anyMap: true)
class AppBar {
  String textKey;
  @JsonKey(defaultValue: {})
  Map<String, dynamic> style;

  AppBar(this.textKey, {this.style});

  factory AppBar.fromJson(Map<String, dynamic> json) => _$AppBarFromJson(json);

  Map<String, dynamic> toJson() => _$AppBarToJson(this);
}