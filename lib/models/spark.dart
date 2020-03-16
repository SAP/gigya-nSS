import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spark.g.dart';

@JsonSerializable(anyMap: true)
class Spark {
  bool platformAware;
  Markup markup;

  Spark(this.platformAware, this.markup);

  factory Spark.fromJson(Map<String, dynamic> json) => _$SparkFromJson(json);

  Map<String, dynamic> toJson() => _$SparkToJson(this);
}
