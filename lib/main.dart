import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NssIgnitionWidget(
      worker: IgnitionWorker(),
      useMockData: true,
    );
  }
}
