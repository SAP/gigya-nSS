
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/comm/channels.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/utils/platform_helper.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/widgets/components/errors.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

abstract class Router {
  final NssConfig? config;
  final NssChannels? channels;

  Router(this.config, this.channels);

  Route initialRoute(RouteSettings settings);

  Route getErrorRoute(RouteSettings settings, String message);

  Route emptyRoute(RouteSettings settings);

  Route screenRoute(RouteSettings settings, Screen screen);

  /// Determine next possible route according to provided [name] parameter.
  /// Parsed route name will then be matched with the correct markup routing value.
  String? getNextRoute(String? name) {
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
      Screen? screen = config!.markup!.screens![urlSplit[0]];
      if (screen == null) {
        // In this case we must display and error to the client.
        return null;
      }
      Map? screenRouting = screen.routes;
      if (screenRouting == null) {
        // Search for route in default routing map.
        return getNextRouteFromDefaultRouting(next);
      }
      String? route = screenRouting[next];
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
  String? getNextRouteFromDefaultRouting(String name) {
    return config!.markup!.routing!.defaultRouting![name];
  }

  /// Evaluate dismissal route indication.
  bool shouldDismiss(String nextRoute) {
    return nextRoute == '_dismiss';
  }

  /// Route and Notify the native controller that the engine need to be dismissed.
  Route dismissEngine(settings, method) {
    if (config!.isMock!) {
      return emptyRoute(settings);
    }
    try {
      channels!.screenChannel.invokeMethod(method);
    } on MissingPluginException catch (ex) {
      engineLogger!.e('Missing channel connection: check mock state?');
    }
    return emptyRoute(settings);
  }

  /// Evaluate dismissal route indication with canceled event.
  bool shouldCancel(String nextRoute) {
    return nextRoute == '_canceled';
  }

  /// Match the correct [Screen] instance to the [nextRoute] property.
  Screen? nextScreen(String? nextRoute) {
    var screen = config!.markup!.screens![nextRoute!];
    if (screen != null) {
      screen.id = nextRoute;
    }
    return screen;
  }

  /// Dynamic route generator.
  /// This is the main route generation method that is responsible for creating the
  /// correct route per settings.
  Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return initialRoute(settings);
    }

    var nextRoute = getNextRoute(settings.name);

    if (nextRoute == null) {
      engineLogger!.e('Failed to parse routing for name: ${settings.name}');
      return getErrorRoute(
          settings,
          'Failed to parse desired route: ${settings.name}.'
          '\nPlease verify markup and make sure your route exists and is written correctly.');
    }
    if (shouldCancel(nextRoute)) {
      return dismissEngine(settings, '_canceled');
    }
    if (shouldDismiss(nextRoute)) {
      return dismissEngine(settings, '_dismiss');
    }

    Screen? nextScreenObj = nextScreen(nextRoute);
    if (nextScreenObj == null) {
      return getErrorRoute(
          settings, 'Screen not found.\nPlease verify markup.');
    }

    return screenRoute(settings, nextScreenObj);
  }
}

/// Engine internal routing event class.
/// Used to group all relevant routing stream data before passing it to the
class RoutingEvent {
  final String route;
  final String pid;

  RoutingEvent(this.route, this.pid);
}

/// Allowed routing events.
enum RoutingAllowed {
  none,
  onPendingRegistration,
  onPendingEmailVerification,
  onLoginIdentifierExists
}

/// Route evaluator class is responsible for specific routing flows.
/// These flows are generally intended for recoverable errors.
class RouteEvaluator {
  /// Check for allowed routing given an error [code]
  static RoutingAllowed allowedBy(int? code) {
    switch (code) {
      case 206001:
        return RoutingAllowed.onPendingRegistration;
      case 206002:
        return RoutingAllowed.onPendingEmailVerification;
      case 403043:
        return RoutingAllowed.onLoginIdentifierExists;
    }
    return RoutingAllowed.none;
  }

  static List<String> engineRoutes = ['_canceled', '_dismiss'];

  /// Validate requested route. Only saved engine routes and provided screen names are valid.
  static bool validatedRoute(String route) {
    Markup? markup = NssIoc().use(NssConfig).markup;
    if (engineRoutes.contains(route)) return true;
    for (var screenName in markup!.screens!.keys) {
      if (screenName == route) return true;
    }
    return false;
  }
}

class PlatformRouter extends Router {
  final NssConfig? config;
  final NssChannels? channels;
  final WidgetCreationFactory? widgetFactory;

  PlatformRouter(this.config, this.channels, this.widgetFactory)
      : super(config, channels);

  bool _forceCupertino() {
    return config?.markup?.platformAware == true &&
        config?.markup?.platformAwareMode?.toLowerCase() == 'cupertino';
  }

  _platformRoute(RouteSettings settings, Widget destination) {
    if (config == null) return;

    // Default route style is set to Material.
    if (!config!.isPlatformAware) {
      return MaterialPageRoute(
          settings: settings, builder: (_) => destination);
    }

    // Cupertino is forced by web mode state.
    if (_forceCupertino()) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => destination);
    }

    // Old school if else.
    if (PlatformHelper.isCupertino()) {
      return CupertinoPageRoute(
          settings: settings, builder: (_) => destination);
    } else if (PlatformHelper.isMaterial()) {
      return MaterialPageRoute(
          settings: settings, builder: (_) => destination);
    }
  }

  @override
  Route initialRoute(RouteSettings settings) {
    var nextRoute = getNextRoute(config?.markup!.routing!.initial);
    Screen initial = nextScreen(nextRoute)!;
    WidgetCreationFactory factory = NssIoc().use(WidgetCreationFactory);
    Widget screen = factory.buildScreen(initial, {});
    return _platformRoute(settings, screen);
  }

  @override
  Route emptyRoute(RouteSettings settings) {
    return _platformRoute(settings, Container());
  }

  @override
  Route getErrorRoute(RouteSettings settings, String errorMessage) {
    return _platformRoute(
        settings, MaterialScreenRenderErrorWidget(errorMessage: errorMessage));
  }

  @override
  Route screenRoute(RouteSettings settings, Screen screen) {
    return _platformRoute(
        settings,
        widgetFactory!
            .buildScreen(screen, settings.arguments as Map<String, dynamic>?));
  }
}

