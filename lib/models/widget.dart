import 'package:gigya_native_screensets_engine/nss_injection.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidgetData {
  NssWidgetType type;
  String textKey;
  NssAlignment stack;
  List<NssWidgetData> children;

  NssWidgetData(this.type, this.textKey, {this.children, this.stack});

  factory NssWidgetData.fromJson(Map<String, dynamic> json) => _$NssWidgetFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetToJson(this);
}
