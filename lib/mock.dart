import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/injector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NssContainer().startEngine(asMock: true);
  }
}
