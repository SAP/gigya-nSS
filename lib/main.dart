import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NssContainer().startEngine();
  }
}
