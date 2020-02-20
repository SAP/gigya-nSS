import 'package:json_annotation/json_annotation.dart';

part 'route.g.dart';

@JsonSerializable(anyMap: true)
class Routing {
  Map<String, Route> routes;

  Routing(this.routes);

  factory Routing.fromJson(Map<String, dynamic> json) => _$RoutingFromJson(json);
}

@JsonSerializable(anyMap: true)
class Route {
  String route;

  Route(this.route);

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
}
