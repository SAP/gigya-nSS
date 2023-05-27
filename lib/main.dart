import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/comm/data_initializer.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'config.dart';
import 'ioc/ioc_mobile.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MobileContainer().startEngine();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DataInitializer().getRequiredDataForEngineInitialization(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return createApp();
          else
            return Container();
        });
  }

  /// Check platform awareness state.
  bool isPlatformAware() {
    final NssConfig config = NssIoc().use(NssConfig);
    return config.markup?.platformAware == true;
  }

  /// Create main application.
  Widget createApp() {
    return PlatformProvider(
      settings: PlatformSettingsData(
          platformStyle: PlatformStyleData(
              ios: isPlatformAware()
                  ? PlatformStyle.Cupertino
                  : PlatformStyle.Material)),
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
}
