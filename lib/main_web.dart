import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/ioc/ioc_web.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'comm/web_channel.dart';
import 'config.dart';
import 'models/markup.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     color: Colors.white,
  //     initialRoute: '/',
  //     onGenerateRoute: NssIoc().use(MaterialRouter).generateRoute,
  //   );
  // }

  @override
  void initState() {
    super.initState();
    WebContainer().startEngine();
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
    var fetchData = await _markupFromChannel(config!.version);
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    config!.markup = markup;
    // config!.isPlatformAware = markup.platformAware ?? false;

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
    //ErrorUtils().addDefaultStringValues(config!.markup!.localization!);
  }


/// Fetch markup from the running platform.
  Future<Map<dynamic, dynamic>> _markupFromChannel(version) async {
    final NssWebMethodChannel ignitionChannel = NssIoc().use(NssChannels).ignitionChannel;

    return ignitionChannel.invokeMethod<Map<dynamic, dynamic>>(
        'ignition', {'version': version});
  }


}
