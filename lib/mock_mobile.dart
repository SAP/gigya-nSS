import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/ioc/ioc_mobile.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
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
    return PlatformProvider(
      settings: PlatformSettingsData
        (platformStyle: PlatformStyleData(android: showCupertino() ? PlatformStyle.Cupertino : PlatformStyle.Material)),
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
    var fetchData = await _markupFromMock();
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    config.markup = markup;
    config.platformAwareMode = markup.platformAwareMode ?? 'material';

    // Add default localization values that are needed (can be overridden by client).
    ErrorUtils().addDefaultStringValues(config.markup!.localization!);
  }
  /// Fetch markup from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _markupFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/example.json');
    return jsonDecode(json);
  }

  bool showCupertino(){
    final NssConfig config = NssIoc().use(NssConfig);
    return true;
    return config.markup?.platformAware == true && config.markup?.platformAwareMode?.toLowerCase() == 'cupertino';
  }
}
