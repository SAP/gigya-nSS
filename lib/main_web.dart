import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/ioc/ioc_web.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'config.dart';
import 'models/markup.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return PlatformProvider(
      settings: PlatformSettingsData
        (platformStyle: PlatformStyleData(android: isCupertino() ? PlatformStyle.Cupertino : PlatformStyle.Material)),
      builder: (context) => PlatformApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        onGenerateRoute: NssIoc().use(MaterialRouter).generateRoute,
      ),
    );
  }

  Future<void> fetchMarkupAndSchema() async {
    final NssConfig config = NssIoc().use(NssConfig);
    var fetchData = await _markupFromChannel(config.version);
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    config.markup = markup;
  }

  /// Fetch markup from the running platform.
  Future<Map<dynamic, dynamic>> _markupFromChannel(version) async {
    final NssChannels channels = NssIoc().use(NssChannels);

    return channels!.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>(
        'ignition', {'version': version});
  }

  bool isCupertino(){
    final NssConfig config = NssIoc().use(NssConfig);
    return config.markup?.platformAware == true && config.markup?.platformAwareMode?.toLowerCase() == 'cupertino';
  }


}
