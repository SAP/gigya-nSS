import 'package:json_annotation/json_annotation.dart';


part 'styles.g.dart';

@JsonSerializable(anyMap: true)
class DatePickerStyle {

  @JsonKey(defaultValue: '')
  String primaryColor;
  @JsonKey(defaultValue: '')
  String labelColor;
  @JsonKey(defaultValue: 'Enter Date')
  String labelText;

  DatePickerStyle({
    this.primaryColor,
    this.labelColor,
    this.labelText,
  });

  factory DatePickerStyle.fromJson(Map<String, dynamic> json) =>
      _$DatePickerStyleFromJson(json);

  Map<String, dynamic> toJson() => _$DatePickerStyleToJson(this);
}