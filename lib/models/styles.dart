import 'package:json_annotation/json_annotation.dart';


part 'styles.g.dart';

@JsonSerializable(anyMap: true)
class DatePickerStyle {

  @JsonKey(defaultValue: '')
  String primaryColor;
  String fontColor;
  int fontSize;

  DatePickerStyle({
    this.primaryColor,
    this.fontColor,
    this.fontSize,
  });

  factory DatePickerStyle.fromJson(Map<String, dynamic> json) =>
      _$DatePickerStyleFromJson(json);

  Map<String, dynamic> toJson() => _$DatePickerStyleToJson(this);
}