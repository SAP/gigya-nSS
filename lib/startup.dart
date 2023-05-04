import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class StartupWidget extends StatefulWidget {
  @override
  _StartupWidgetState createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  Widget build(BuildContext context) {
    return buildInitialScreen();
  }
}

/// Build and display the initial screen when platform data is available.
/// //TODO: Currently hard coded to Material only.
Widget buildInitialScreen() {
  // Reference required factory and route.
  MaterialRouter router = NssIoc().use(MaterialRouter);
  final NssConfig config = NssIoc().use(NssConfig);

  var nextRoute = router.getNextRoute(config.markup!.routing!.initial);
  Screen initial = router.nextScreen(nextRoute)!;
  MaterialWidgetFactory factory = NssIoc().use(MaterialWidgetFactory);

  // Build screen and trigger native display.
  Widget screen = factory.buildScreen(initial, {});
  return screen;
}

