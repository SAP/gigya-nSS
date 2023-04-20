import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/ioc/ioc_mobile.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

import 'config.dart';
import 'models/markup.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // late final NssConfig? config;
  // late final NssChannels? channels;


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    MobileContainer().startEngine(asMock: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder (
      future: fetchMarkupAndSchema(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return createApp();
        else
          return Container();
      }
    );}


  Widget createApp() {
    return MaterialApp(
      // showSemanticsDebugger: true,
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      initialRoute: '/',
      onGenerateRoute: NssIoc().use(MaterialRouter).generateRoute,
    );
  }

  Future<void> fetchMarkupAndSchema() async {
    final NssConfig config = NssIoc().use(NssConfig);
    var fetchData = await _markupFromMock();
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    config!.markup = markup;
    config!.isPlatformAware = markup.platformAware ?? false;

    // Fetch and parse the schema if required in markup preference (and not in mock mode).
    // if (markup.useSchemaValidations! && !config!.isMock!) {
    //   engineLogger!.d(
    //       "startup widget: requesting schema (schemaValidations)",
    //       tag: Logger.dTag);
    //   var rawSchema = await widget.channels!.ignitionChannel
    //       .invokeMethod<Map<dynamic, dynamic>>('load_schema');
    //   var newSchema = {
    //     'profile': rawSchema['profileSchema']['fields'],
    //     'data': rawSchema['dataSchema']['fields'],
    //     'subscriptions': rawSchema['subscriptionsSchema']['fields'],
    //     'preferences': rawSchema['preferencesSchema']['fields']
    //   };
    //   config!.schema = newSchema;
    // }

    // Add default localization values that are needed (can be overridden by client).
    ErrorUtils().addDefaultStringValues(config!.markup!.localization!);
  }
  /// Fetch markup from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _markupFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/example.json');
    return jsonDecode(json);
  }

  /// Fetch markup from the running platform.
//   Future<Map<dynamic, dynamic>> _markupFromChannel() async {
// //    var channel = widget.channels.ignitionChannel as NssWebMethodChannel;
//     return widget.channels!.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>(
//         'ignition', {'version': widget.config!.version});
//   }


}
