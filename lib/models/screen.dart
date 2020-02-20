import 'package:gigya_native_screensets_engine/models/route.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen.g.dart';

@JsonSerializable(anyMap: true)
class Screen {
  String id;
  String flow;
  @JsonKey(name: 'stack')
  NssAlignment align;
  Map<String, dynamic> appBar;
  List<NssWidgetData> children;
  Routing routing;

  Screen(this.id, this.flow, this.align, this.children, this.routing, {this.appBar});

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}
