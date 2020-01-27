import 'package:flutter/cupertino.dart';
import 'package:gigya_native_screensets_engine/models/widget_bank.dart';
import 'package:gigya_native_screensets_engine/ui/widget_factory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';
@JsonSerializable()

class NSSWidget {
  WidgetBank type;
  String textKey;
  String stack;
  List<NSSWidget> children;

  NSSWidget(this.type, this.textKey, { this.children , this.stack });

  factory NSSWidget.fromJson(Map<String, dynamic> json) => _$NSSWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$NSSWidgetToJson(this);

}