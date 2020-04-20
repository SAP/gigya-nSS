import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

/// Flutter application routing manager.
//TODO: The Router is currently hardcoded to work with Material routes only!
class Router {
  final NssConfig config;
  final NssChannels channels;
  final NssWidgetFactory widgetFactory;

  Router({
    @required this.config,
    @required this.channels,
    @required this.widgetFactory,
  });

  /// Generate next route given [RouteSettings] data provided from [Navigator].
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

  /// Determine next possible route according to provided [name] parameter.
  /// Parsed route name will then be matched with the correct markup routing value.
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

  /// Get the next route according to the markup default routing value.
  /// This will be used if a specific screen does not contain the required route value.
  String getNextRouteFromDefaultRouting(String name) {
    return config.main.defaultRouting[name];
  }

  /// Evaluate dismissal route indication.
  bool shouldDismiss(String nextRoute) {
    return nextRoute == 'dismiss';
  }

  /// Route and Notify the native controller that the engine need to be dismissed.
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

  /// Match the correct [Screen] instance to the [nextRoute] property.
  @visibleForTesting
  Screen nextScreen(String nextRoute) {
    var screen = config.main.screens[nextRoute];
    screen.id = nextRoute;
    return screen;
  }
}

enum RoutingAllowed {
  none,
  pendingRegistration
}

class RouteEvaluator {

  static RoutingAllowed allowedBy(int code) {
    switch (code) {
      case 206001:
        return RoutingAllowed.pendingRegistration;
    }

    return RoutingAllowed.none;
  }

}
