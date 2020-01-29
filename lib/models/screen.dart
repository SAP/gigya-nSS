import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen.g.dart';

@JsonSerializable(anyMap: true)
class Screen {
  String id;
  NssAlignment stack;
  Map<String, dynamic> appBar;
  List<NssWidget> children;

  Screen(this.id, this.stack, this.children, {this.appBar});

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}
