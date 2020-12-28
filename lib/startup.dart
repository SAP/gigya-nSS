import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

import 'comm/communications.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class StartupWidget extends StatefulWidget {
  final NssConfig config;
  final NssChannels channels;

  const StartupWidget({Key key, this.config, this.channels}) : super(key: key);

  @override
  _StartupWidgetState createState() => _StartupWidgetState();
}

class _StartupWidgetState extends State<StartupWidget> {
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: fetchMarkupAndSchema(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return buildInitialScreen();
          }
          return Container(
            color: Colors.transparent,
          );
        });
  }

  /// Build and display the initial screen when platfom data is available.
  /// //TODO: Currently hard coded to Material only.
  Widget buildInitialScreen() {
    // Reference required factory and route.
    MaterialRouter router = NssIoc().use(MaterialRouter);
    var nextRoute = router.getNextRoute(widget.config.markup.routing.initial);
    Screen initial = router.nextScreen(nextRoute);
    MaterialWidgetFactory factory = NssIoc().use(MaterialWidgetFactory);

    // Build screen and trigger native display.
    Widget screen = factory.buildScreen(initial, {});
    return screen;
  }

  /// Fetch and propagate the required data injected from the platform.
  /// Markup is required in order to correctly run the engine.
  /// Schema is optional and is markup dependant.
  Future<bool> fetchMarkupAndSchema() async {
    var fetchData = widget.config.isMock ? await _markupFromMock() : await _markupFromChannel();
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    widget.config.markup = markup;
    widget.config.isPlatformAware = markup.platformAware ?? false;

    // Fetch and parse the schema if required in markup preference (and not in mock mode).
    if (markup.useSchemaValidations && !widget.config.isMock) {
      var rawSchema =
          await widget.channels.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>('load_schema');
      var newSchema = {
        'profile': rawSchema['profileSchema']['fields'],
        'data': rawSchema['dataSchema']['fields'],
        'subscriptions': rawSchema['subscriptionsSchema']['fields'],
        'preferences': rawSchema['preferencesSchema']['fields']
      };
      widget.config.schema = newSchema;
    }

    // Add default localization values that are needed (can be overriden by client).
    ErrorUtils().addDefultStringValues(widget.config.markup.localization);
    return true;
  }

  /// Fetch markup from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _markupFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/example.json');
    return jsonDecode(json);
  }

  /// Fetch markup from the running platfrom.
  Future<Map<dynamic, dynamic>> _markupFromChannel() async {
//    var channel = widget.channels.ignitionChannel as NssWebMethodChannel;
    return widget.channels.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>('ignition');
  }
}
