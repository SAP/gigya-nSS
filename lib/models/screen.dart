import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:json_annotation/json_annotation.dart';

import 'appbar.dart';

part 'screen.g.dart';

@JsonSerializable(anyMap: true)
class Screen {
  String id;
  String action;
  @JsonKey(defaultValue: NssStack.vertical)
  NssStack stack;
  AppBar appBar;
  List<NssWidgetData> children;
  @JsonKey(name: 'routing')
  Map<String, String> routes;
  Map<String, dynamic> style;

  Screen(this.id, this.action, this.stack, this.children, {this.appBar, this.routes});

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}
