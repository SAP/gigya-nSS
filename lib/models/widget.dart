import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidgetData {
  String bind;
  NssWidgetType type;
  String textKey;
  @JsonKey(defaultValue: NssStack.vertical)
  NssStack stack;
  NssAlignment alignment;
  List<NssWidgetData> children;
  String api;
  dynamic defaultValue;
  @JsonKey(defaultValue: false)
  bool expand;
  List<NssOption> options;
  @JsonKey(defaultValue: {})
  Map<String, dynamic> style;
  String theme;
  Map<String, dynamic> validations;

  NssWidgetData({
    this.textKey,
    this.type,
    this.bind,
    this.stack,
    this.alignment,
    this.children,
    this.api,
    this.defaultValue,
    this.expand,
    this.options,
    this.style,
    this.theme,
    this.validations,
  });

  factory NssWidgetData.fromJson(Map<String, dynamic> json) => _$NssWidgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetDataToJson(this);

  bool boolDefaultValue() => defaultValue as bool;
}
