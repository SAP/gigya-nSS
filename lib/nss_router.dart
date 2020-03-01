import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class Router {
  final NssConfig config;
  final NssChannels channels;
  final NssWidgetFactory widgetFactory;

  Router({
    @required this.config,
    @required this.channels,
    @required this.widgetFactory,
  });

  Route<dynamic> generateRoute(RouteSettings settings) {
    var nextRoute = getNextRoute(settings.name);

    if (nextRoute == null) {
      //TODO: Should show a rendering error for the client.
      nssLogger.e('Failed to parse routing for name: ${settings.name}');
    }

    if (shouldDismiss(nextRoute)) {
      return dismissEngine();
    }

    return MaterialPageRoute(builder: (_) => widgetFactory.createScreen(nextScreen(nextRoute)));
  }

  String getNextRoute(String name) {
    var urlSplit = name.split('/');
    if (urlSplit.length > 1) {
      // Look for routing in the routing map of the screen.
      // If value does not exist use default routing.
      Screen screen = config.main.screens[urlSplit[0]];
      if (screen == null) {
        // In this case we must display and error to the client.
        return null;
      }
      Map screenRouting = screen.routing;
      if (screenRouting == null) {
        // Search for route in default routing map.
        return getNextRouteFromDefaultRouting(urlSplit[1]);
      }
      String route = screenRouting[urlSplit[1]];
      if (route == null) {
        // Search for route in default routing map.
        return getNextRouteFromDefaultRouting(urlSplit[1]);
      }
      return route;
    }
    return urlSplit[0];
  }

  String getNextRouteFromDefaultRouting(String name) {
    return config.main.defaultRouting[name];
  }


  bool shouldDismiss(String nextRoute) {
    return nextRoute == 'dismiss';
  }

  MaterialPageRoute dismissEngine() {
    if (config.isMock) {
      return MaterialPageRoute(builder: (_) => Container());
    }
    try {
      channels.screenChannel.invokeMethod('dismiss');
    } on MissingPluginException catch (ex) {
      nssLogger.e('Missing channel connection: check mock state?');
    }
    return MaterialPageRoute(builder: (_) => Container());
  }

  Screen nextScreen(String nextRoute) {
    var screen = config.main.screens[nextRoute];
    screen.id = nextRoute;
    return screen;
  }

}
