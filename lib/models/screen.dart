import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/ui/rendering.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen.g.dart';
@JsonSerializable()

class Screen {
  String id;
  Alignment stack;
  Map<dynamic, dynamic> appBar;
  List<NSSWidget> children;

  Screen(this.id, this.stack, this.children, { this.appBar });

  factory Screen.fromJson(Map<dynamic, dynamic> json) => _$ScreenFromJson(json);
  Map<String, dynamic> toJson() => _$ScreenToJson(this);

}