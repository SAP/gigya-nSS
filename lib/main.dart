import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/initialization.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/registry.dart';
import 'package:gigya_native_screensets_engine/ui/rendering.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

@pragma('vm:entry-point')
void launch() => {};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EngineRegistry>(
          create: (_) => EngineRegistry(),
        ),
      ],
      child: EngineInitializationWidget(
        layoutScreenSet: (Main main) {
          return NSSLayoutBuilder('login').render(main.screens);
        },
      ),
    );
  }
}
