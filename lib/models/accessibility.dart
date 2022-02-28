import 'package:json_annotation/json_annotation.dart';

part 'accessibility.g.dart';

/// Accessibility extension object.
/// Adds/overrides basic semantics tree for label/hint.
@JsonSerializable(anyMap: true)
class Accessibility {
  @JsonKey(defaultValue: '')
  String? label;
  @JsonKey(defaultValue: '')
  String? hint;

  Accessibility({
    this.label,
    this.hint,
  });

  factory Accessibility.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilityToJson(this);
}
