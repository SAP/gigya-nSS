import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      initialRoute: '/',
      onGenerateRoute: NssIoc().use(MaterialRouter).generateRoute,
    );
  }

  @override
  void initState() {
    super.initState();
    NssContainer().startEngine(asMock: true);
  }
}
