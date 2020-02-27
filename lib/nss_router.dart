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

    if (shouldDismiss(nextRoute)) {
      return dismissEngine();
    }
    return MaterialPageRoute(builder: (_) => widgetFactory.createScreen(nextScreen(nextRoute)));
  }

  String getNextRoute(String name) {
    var urlSplit = name.split('/');
    return urlSplit.length > 1 ? config.main.routing[urlSplit[0]].routes[urlSplit[1]] : urlSplit[0];
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
