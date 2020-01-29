import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
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
        Provider<NssRegistryBloc>(
          create: (_) => NssRegistryBloc(),
        ),
      ],
      child: NssIgnitionWidget(
        layoutScreenSet: (Main main, String initialRoute) {
          return NssLayoutBuilder(initialRoute).render(main.screens);
        },
        useMockData: true,
      ),
    );
  }
}
