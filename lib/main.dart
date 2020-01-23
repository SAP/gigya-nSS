import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/init.dart';
import 'package:gigya_native_screensets_engine/registry.dart';
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
        layout: (map) {
          //TODO Use the layout builder to create the screen
          return Container(
            child: Center(
              child: Text('sdsd'),
            ),
          );
        },
        useMockData: true,
      ),
    );
  }
}
