import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/ioc/ioc_web.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   color: Colors.white,
    //   initialRoute: '/',
    //   onGenerateRoute: NssIoc().use(MaterialRouter).generateRoute,
    // );

    return PlatformProvider(
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

  @override
  void initState() {
    super.initState();
    WebContainer().startEngine();
  }
}
