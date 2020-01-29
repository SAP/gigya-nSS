import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidget {
  NssWidgetType type;
  String textKey;
  NssAlignment stack;
  List<NssWidget> children;

  NssWidget(this.type, this.textKey, {this.children, this.stack});

  factory NssWidget.fromJson(Map<String, dynamic> json) => _$NssWidgetFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetToJson(this);
}
