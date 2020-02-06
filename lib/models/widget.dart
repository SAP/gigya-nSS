import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidgetData {
  String id;
  NssWidgetType type;
  String textKey;
  NssAlignment stack;
  List<NssWidgetData> children;
  String api;

  NssWidgetData(this.textKey, {this.type, this.id, this.children, this.stack, this.api});

  factory NssWidgetData.fromJson(Map<String, dynamic> json) => _$NssWidgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetDataToJson(this);

}

