import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidgetData {
  String bind;
  NssWidgetType type;
  String textKey;
  NssStack stack;
  NssAlignment alignment;
  List<NssWidgetData> children;
  String api;

  NssWidgetData({this.textKey, this.type, this.bind, this.stack, this.alignment, this.children, this.api});

  factory NssWidgetData.fromJson(Map<String, dynamic> json) => _$NssWidgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetDataToJson(this);

  bool hasChildren() => children != null;
}
