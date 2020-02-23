//TODO: Placeholder class for dynamic routing generation using "onGenerateRoute" option.
//TODO: reference: "https://medium.com/flutter-community/clean-navigation-in-flutter-using-generated-routes-891bd6e000df"
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';

class Router {
  final Main main;

  Router({@required this.main});

  Route<dynamic> generateRoute(RouteSettings settings) {
    var urlSplit = settings.name.split('/');
    var nextRoute = urlSplit.length > 1 ? main.routing[urlSplit[0]].routes[urlSplit[1]] : urlSplit[0];

    if (nextRoute == 'dismiss') {
      registry.channels.mainChannel.invokeMethod('dismiss');
      return null;
    }

    var screen = main.screens[nextRoute];
    screen.id = nextRoute;
    return MaterialPageRoute(builder: (_) => NssScreenBuilder(screen).build());
  }
}
