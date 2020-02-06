import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NssIgnitionWidget(
      layoutScreenSet: (Main main, String initialRoute) {
        return NssLayoutBuilder(initialRoute).render(main.screens);
      },
      //TODO: Set this value as false when building frameworks!!
      useMockData: true,
    );
  }
}
