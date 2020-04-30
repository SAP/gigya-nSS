import 'package:gigya_native_screensets_engine/platform/factory.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen.g.dart';

@JsonSerializable(anyMap: true)
class Screen {
  String id;
  String action;
  NssStack stack;
  Map<String, dynamic> appBar;
  List<NssWidgetData> children;
  @JsonKey(name: 'routing')
  Map<String, String> routes;

  Screen(this.id, this.action, this.stack, this.children, {this.appBar, this.routes});

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}
