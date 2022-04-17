import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class StartupWidget extends StatefulWidget {
  final NssConfig? config;
  final NssChannels? channels;

  const StartupWidget({Key? key, this.config, this.channels}) : super(key: key);

  @override
  _StartupWidgetState createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: fetchMarkupAndSchema(),
        builder: (context, snapshot) {
          engineLogger!.d(
              "startup widget: connection state ${snapshot.connectionState}",
              tag: Logger.dTag);
          if (snapshot.connectionState == ConnectionState.done) {
            return buildInitialScreen();
          }
          return Container(
            color: Colors.transparent,
          );
        });
  }

  /// Build and display the initial screen when platform data is available.
  /// //TODO: Currently hard coded to Material only.
  Widget buildInitialScreen() {
    // Reference required factory and route.
    MaterialRouter router = NssIoc().use(MaterialRouter);
    var nextRoute =
        router.getNextRoute(widget.config!.markup!.routing!.initial);
    Screen initial = router.nextScreen(nextRoute)!;
    MaterialWidgetFactory factory = NssIoc().use(MaterialWidgetFactory);

    // Build screen and trigger native display.
    Widget screen = factory.buildScreen(initial, {});
    return screen;
  }

  /// Fetch and propagate the required data injected from the platform.
  /// Markup is required in order to correctly run the engine.
  /// Schema is optional and is markup dependant.
  Future<void> fetchMarkupAndSchema() async {
    var fetchData = widget.config!.isMock!
        ? await _markupFromMock()
        : await _markupFromChannel();
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    widget.config!.markup = markup;
    widget.config!.isPlatformAware = markup.platformAware ?? false;

    // Fetch and parse the schema if required in markup preference (and not in mock mode).
    if (markup.useSchemaValidations! && !widget.config!.isMock!) {
      engineLogger!.d(
          "startup widget: requesting schema (schemaValidations)",
          tag: Logger.dTag);
      var rawSchema = await widget.channels!.ignitionChannel
          .invokeMethod<Map<dynamic, dynamic>>('load_schema');
      var newSchema = {
        'profile': rawSchema['profileSchema']['fields'],
        'data': rawSchema['dataSchema']['fields'],
        'subscriptions': rawSchema['subscriptionsSchema']['fields'],
        'preferences': rawSchema['preferencesSchema']['fields']
      };
      widget.config!.schema = newSchema;
    }

    // Add default localization values that are needed (can be overridden by client).
    ErrorUtils().addDefaultStringValues(widget.config!.markup!.localization!);
  }

  /// Fetch markup from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _markupFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/example.json');
    return jsonDecode(json);
  }

  /// Fetch markup from the running platform.
  Future<Map<dynamic, dynamic>> _markupFromChannel() async {
//    var channel = widget.channels.ignitionChannel as NssWebMethodChannel;
    return widget.channels!.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>(
        'ignition', {'version': widget.config!.version});
  }
}
