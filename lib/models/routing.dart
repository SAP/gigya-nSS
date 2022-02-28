import 'package:json_annotation/json_annotation.dart';

part 'routing.g.dart';

@JsonSerializable(anyMap: true)
class Routing {
  String? initial;
  @JsonKey(name: 'default')
  Map<String, String>? defaultRouting;

  Routing({this.initial, this.defaultRouting});

  factory Routing.fromJson(Map<String, dynamic> json) => _$RoutingFromJson(json);

  Map<String, dynamic> toJson() => _$RoutingToJson(this);
}
