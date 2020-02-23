import 'package:json_annotation/json_annotation.dart';

part 'routing.g.dart';

@JsonSerializable(anyMap: true)
class Routing {
  Map<String, String> routes;

  Routing(this.routes);

  factory Routing.fromJson(Map<String, dynamic> json) => _$RoutingFromJson(json);

  Map<String, dynamic> toJson() => _$RoutingToJson(this);
}
