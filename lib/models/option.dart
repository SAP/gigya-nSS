import 'package:json_annotation/json_annotation.dart';

part 'option.g.dart';

@JsonSerializable(anyMap: true)
class NssOption {
  @JsonKey(name: 'default')
  bool defaultValue;
  String value;
  String textKey;

  NssOption({
    this.defaultValue,
    this.value,
    this.textKey,
  });

  factory NssOption.fromJson(Map<String, dynamic> json) => _$NssOptionFromJson(json);

  Map<String, dynamic> toJson() => _$NssOptionToJson(this);
}
