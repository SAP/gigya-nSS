import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:json_annotation/json_annotation.dart';

import 'appbar.dart';

part 'screen.g.dart';

@JsonSerializable(anyMap: true)
class Screen {
  String? id;
  String? action;
  @JsonKey(defaultValue: NssStack.vertical)
  NssStack stack;
  NssAlignment? alignment;
  AppBar? appBar;
  List<NssWidgetData>? children;
  @JsonKey(name: 'routing')
  Map<String, String>? routes;
  @JsonKey(defaultValue: {})
  Map<String, dynamic>? style;
  @JsonKey(defaultValue: NssShowOnlyFields.none)
  NssShowOnlyFields? showOnlyFields;


  Screen(this.id, this.action, this.stack, this.alignment, this.children, {this.appBar, this.routes, this.showOnlyFields});

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}
