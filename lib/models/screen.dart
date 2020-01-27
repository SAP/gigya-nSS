import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen.g.dart';
@JsonSerializable()

class Screen {
  String id;
  String stack;
  Map<String, dynamic> appBar;
  List<NSSWidget> children;

  Screen(this.id, this.stack, this.appBar, this.children);

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);
  Map<String, dynamic> toJson() => _$ScreenToJson(this);

}