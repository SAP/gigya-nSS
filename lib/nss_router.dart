import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
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
      nssLogger.e('Failed to parse routing for name: ${settings.name}');
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => NssRenderingErrorWidget(
          message: 'Failed to parse desired route.\nPlease verify markup',
        ),
      );
    }

    if (shouldDismiss(nextRoute)) {
      return dismissEngine(settings);
    }
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => widgetFactory.createScreen(nextScreen(nextRoute)),
    );
  }

  @visibleForTesting
  String getNextRoute(String name) {
    if (name == null) {
      return null;
    }
    var urlSplit = name.split('/');
    if (urlSplit.length > 1) {
      var next = urlSplit[1];
      if (next.isEmpty) {
        return null;
      }
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
        return getNextRouteFromDefaultRouting(next);
      }
      String route = screenRouting[next];
      if (route == null) {
        // Search for route in default routing map.
        return getNextRouteFromDefaultRouting(next);
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

  MaterialPageRoute dismissEngine(settings) {
    if (config.isMock) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => Container(),
      );
    }
    try {
      channels.screenChannel.invokeMethod('dismiss');
    } on MissingPluginException catch (ex) {
      nssLogger.e('Missing channel connection: check mock state?');
    }
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Container(),
    );
  }

  @visibleForTesting
  Screen nextScreen(String nextRoute) {
    var screen = config.main.screens[nextRoute];
    screen.id = nextRoute;
    return screen;
  }
}
